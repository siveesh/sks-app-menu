import Foundation

public enum DiscoveryError: Error, LocalizedError, Sendable {
    case invalidApplication(String)
    case backgroundApplication

    public var errorDescription: String? {
        switch self {
        case .invalidApplication(let reason): return reason
        case .backgroundApplication: return "This application runs as an agent or in the background. Add it explicitly if desired."
        }
    }
}

/// A synchronous, cancellable scanner. Its caller owns background scheduling.
/// Only metadata is read; installed bundles are never executed or modified.
public struct DiscoveryService: Sendable {
    public init() {}

    public func scan(roots: [URL], manualURLs: [URL] = [], excluding: URL? = nil) throws -> ScanResult {
        try Task.checkCancellation()
        let manager = FileManager.default
        var result = ScanResult()
        var positions: [String: Int] = [:]
        var filePositions: [String: Int] = [:]
        var visitedDirectories = Set<String>()
        let excludedPath = excluding.map(Self.canonicalPath)
        let excludedIdentity = excluding.flatMap(Self.fileIdentity)
        func add(_ app: DiscoveredApp) {
            let path = Self.canonicalPath(app.url)
            guard path != excludedPath, app.fileIdentifier == nil || app.fileIdentifier != excludedIdentity else { return }
            if let index = positions[path] ?? app.fileIdentifier.flatMap({ filePositions[$0] }) {
                if app.isManual { result.apps[index].isManual = true }
                return
            }
            positions[path] = result.apps.count
            if let identity = app.fileIdentifier { filePositions[identity] = result.apps.count }
            result.apps.append(app)
        }
        func failed(_ root: URL, _ error: Error) {
            if !result.failedRoots.contains(root) { result.failedRoots.append(root) }
            result.warnings.append("Some applications could not be verified under \(root.path): \(error.localizedDescription)")
        }
        let keys: Set<URLResourceKey> = [.isDirectoryKey, .isSymbolicLinkKey, .isAliasFileKey, .isPackageKey, .isHiddenKey]
        for root in roots {
            try Task.checkCancellation()
            do {
                let values = try root.resourceValues(forKeys: keys)
                guard values.isSymbolicLink != true, values.isAliasFile != true else {
                    result.warnings.append("Skipped linked application folder: \(root.path)")
                    continue
                }
                guard values.isDirectory == true else {
                    failed(root, DiscoveryError.invalidApplication("The scan root is not a folder."))
                    continue
                }
                if root.pathExtension.lowercased() == "app" {
                    do { add(try inspect(url: root)) }
                    catch DiscoveryError.backgroundApplication { }
                    catch { result.warnings.append("Skipped invalid or inaccessible application \(root.path): \(error.localizedDescription)") }
                    continue
                }
                if values.isPackage == true { continue }
            } catch {
                let ns = error as NSError
                if ns.domain == NSCocoaErrorDomain && ns.code == NSFileReadNoSuchFileError { continue }
                failed(root, error)
                continue
            }
            var pending = [root]
            while let folder = pending.popLast() {
                try Task.checkCancellation()
                guard visitedDirectories.insert(Self.canonicalPath(folder)).inserted else { continue }
                let children: [URL]
                do { children = try manager.contentsOfDirectory(at: folder, includingPropertiesForKeys: Array(keys), options: [.skipsHiddenFiles]) }
                catch { failed(root, error); continue }
                for child in children {
                    try Task.checkCancellation()
                    let values: URLResourceValues
                    do { values = try child.resourceValues(forKeys: keys) }
                    catch { failed(root, error); continue }
                    guard values.isSymbolicLink != true, values.isAliasFile != true, values.isHidden != true else { continue }
                    if child.pathExtension.lowercased() == "app" {
                        do { add(try inspect(url: child)) }
                        catch DiscoveryError.backgroundApplication { /* Explicit Add remains available. */ }
                        catch {
                            result.warnings.append("Skipped invalid or inaccessible application \(child.path): \(error.localizedDescription)")
                            let ns = error as NSError
                            if ns.domain == NSCocoaErrorDomain && ns.code == NSFileReadNoPermissionError { failed(root, error) }
                        }
                        // Every .app is a boundary, including malformed bundles.
                        continue
                    }
                    if values.isDirectory == true && values.isPackage != true { pending.append(child) }
                }
            }
        }
        for url in manualURLs {
            try Task.checkCancellation()
            do {
                var app = try inspect(url: url, allowBackground: true)
                app.isManual = true
                if let metadata = try? Self.metadata(at: app.url), Self.isBackground(metadata) {
                    result.warnings.append("\(app.name) is an agent or background application and may not show a window.")
                }
                add(app)
            } catch {
                result.warnings.append("Could not verify manually added application \(url.path): \(error.localizedDescription)")
                // Preserve a denied/offline manual entry as unverified instead of missing.
                let ns = error as NSError
                if ns.domain == NSCocoaErrorDomain && ns.code != NSFileReadNoSuchFileError { failed(url, error) }
            }
        }
        result.apps.sort {
            let comparison = $0.name.localizedStandardCompare($1.name)
            return comparison == .orderedSame ? $0.url.path < $1.url.path : comparison == .orderedAscending
        }
        try Task.checkCancellation()
        return result
    }

    public func inspect(url: URL, allowBackground: Bool = false) throws -> DiscoveredApp {
        try Task.checkCancellation()
        guard url.isFileURL else { throw DiscoveryError.invalidApplication("Choose a local application bundle.") }
        var target = url
        if (try target.resourceValues(forKeys: [.isAliasFileKey])).isAliasFile == true {
            target = try URL(resolvingAliasFileAt: target, options: [.withoutUI, .withoutMounting])
        }
        target = target.resolvingSymlinksInPath().standardizedFileURL
        guard target.pathExtension.lowercased() == "app",
              try target.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true else {
            throw DiscoveryError.invalidApplication("Choose an .app application bundle.")
        }
        let info = try Self.metadata(at: target)
        guard info["CFBundlePackageType"] as? String == "APPL" else {
            throw DiscoveryError.invalidApplication("This bundle does not declare the APPL application type.")
        }
        guard let executableName = Self.nonempty(info["CFBundleExecutable"] as? String),
              !executableName.contains("/"), executableName != ".", executableName != ".." else {
            throw DiscoveryError.invalidApplication("This application has no valid executable name.")
        }
        let executable = target.appendingPathComponent("Contents/MacOS").appendingPathComponent(executableName).resolvingSymlinksInPath()
        // Executable symlinks must also remain inside the selected bundle.
        guard Self.isInside(executable, root: target),
              (try? executable.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile) == true,
              FileManager.default.isExecutableFile(atPath: executable.path) else {
            throw DiscoveryError.invalidApplication("This application has no usable executable.")
        }
        guard allowBackground || !Self.isBackground(info) else { throw DiscoveryError.backgroundApplication }
        return DiscoveredApp(
            url: target,
            name: Self.nonempty(info["CFBundleDisplayName"] as? String) ?? Self.nonempty(info["CFBundleName"] as? String) ?? target.deletingPathExtension().lastPathComponent,
            bundleIdentifier: Self.nonempty(info["CFBundleIdentifier"] as? String),
            version: Self.nonempty(info["CFBundleShortVersionString"] as? String) ?? Self.nonempty(info["CFBundleVersion"] as? String) ?? "",
            automaticCategory: CategoryResolver.category(for: info["LSApplicationCategoryType"] as? String),
            bookmark: try? target.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil),
            fileIdentifier: Self.fileIdentity(target)
        )
    }

    private static func metadata(at url: URL) throws -> [String: Any] {
        let infoURL = url.appendingPathComponent("Contents/Info.plist")
        let size = try infoURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
        guard size <= 2_000_000 else { throw DiscoveryError.invalidApplication("The application metadata is too large.") }
        let data = try Data(contentsOf: infoURL, options: [.mappedIfSafe])
        guard let info = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            throw DiscoveryError.invalidApplication("The application metadata is malformed.")
        }
        return info
    }

    private static func isBackground(_ info: [String: Any]) -> Bool {
        ["LSBackgroundOnly", "LSUIElement"].contains { key in
            if let number = info[key] as? NSNumber { return number.boolValue }
            return ["1", "true", "yes"].contains((info[key] as? String)?.lowercased() ?? "")
        }
    }

    private static func nonempty(_ value: String?) -> String? {
        guard let value, !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        return value
    }

    static func canonicalPath(_ url: URL) -> String { url.resolvingSymlinksInPath().standardizedFileURL.path }
    static func isInside(_ url: URL, root: URL) -> Bool {
        let path = canonicalPath(url), prefix = canonicalPath(root)
        return path == prefix || path.hasPrefix(prefix.hasSuffix("/") ? prefix : prefix + "/")
    }
    private static func fileIdentity(_ url: URL) -> String? {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
              let inode = attrs[.systemFileNumber] as? NSNumber,
              let device = attrs[.systemNumber] as? NSNumber else { return nil }
        let volumeUUID = try? url.resourceValues(forKeys: [.volumeUUIDStringKey]).volumeUUIDString
        return "\(volumeUUID ?? device.stringValue):\(inode.stringValue)"
    }
}
