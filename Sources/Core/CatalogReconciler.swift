import Foundation

public enum CatalogReconciler {
    /// Match physical identity and canonical location before considering unique moves.
    /// Always reconcile against the current preferences snapshot, never a scan-start copy.
    public static func merge(existing: [AppRecord], scan: ScanResult) -> [AppRecord] {
        var matches: [Int: Int] = [:]
        var usedApps = Set<Int>()
        let newPaths = scan.apps.map { DiscoveryService.canonicalPath($0.url) }
        let oldPaths = existing.map { DiscoveryService.canonicalPath($0.url) }
        // Each key is evaluated once, and duplicate keys on either side are left
        // unmatched. This avoids order-dependent ownership and quadratic I/O.
        func assignUnique(oldKey: (Int) -> String?, newKey: (Int) -> String?) {
            var oldGroups: [String: [Int]] = [:]
            var newGroups: [String: [Int]] = [:]
            for index in existing.indices where matches[index] == nil {
                if let key = oldKey(index) { oldGroups[key, default: []].append(index) }
            }
            for index in scan.apps.indices where !usedApps.contains(index) {
                if let key = newKey(index) { newGroups[key, default: []].append(index) }
            }
            for (key, oldIndices) in oldGroups where oldIndices.count == 1 {
                guard let newIndices = newGroups[key], newIndices.count == 1 else { continue }
                matches[oldIndices[0]] = newIndices[0]
                usedApps.insert(newIndices[0])
            }
        }
        assignUnique(oldKey: { existing[$0].fileIdentifier }, newKey: { scan.apps[$0].fileIdentifier })
        assignUnique(oldKey: { index in
            guard let data = existing[index].bookmark else { return nil }
            var stale = false
            guard let resolved = try? URL(resolvingBookmarkData: data, options: [.withoutUI, .withoutMounting], relativeTo: nil, bookmarkDataIsStale: &stale) else { return nil }
            return DiscoveryService.canonicalPath(resolved)
        }, newKey: { newPaths[$0] })
        assignUnique(oldKey: { oldPaths[$0] }, newKey: { newPaths[$0] })
        func failed(_ old: AppRecord) -> Bool { scan.failedRoots.contains { DiscoveryService.isInside(old.url, root: $0) } }
        // Count unmatched rows only: one missing copy can move while a second
        // stays installed. An unverified row never qualifies as a missing copy.
        let oldIDs = Dictionary(grouping: existing.indices.filter { matches[$0] == nil }, by: { existing[$0].bundleIdentifier ?? "" })
        let newIDs = Dictionary(grouping: scan.apps.indices.filter { !usedApps.contains($0) }, by: { scan.apps[$0].bundleIdentifier ?? "" })
        for (identifier, oldIndices) in oldIDs where !identifier.isEmpty && oldIndices.count == 1 {
            guard let newIndices = newIDs[identifier], newIndices.count == 1,
                  let oldIndex = oldIndices.first, !failed(existing[oldIndex]),
                  let newIndex = newIndices.first else { continue }
            matches[oldIndex] = newIndex
            usedApps.insert(newIndex)
        }
        var result = existing.enumerated().map { index, old in
            var updated = old
            guard let newIndex = matches[index] else {
                updated.availability = failed(old) ? .unverified : .missing
                return updated
            }
            let fresh = scan.apps[newIndex]
            updated.url = fresh.url; updated.name = fresh.name
            updated.bundleIdentifier = fresh.bundleIdentifier; updated.version = fresh.version
            updated.automaticCategory = fresh.automaticCategory
            updated.bookmark = fresh.bookmark ?? old.bookmark
            updated.fileIdentifier = fresh.fileIdentifier ?? old.fileIdentifier
            updated.isManual = old.isManual || fresh.isManual
            updated.availability = .available
            return updated
        }
        for index in scan.apps.indices where !usedApps.contains(index) {
            let fresh = scan.apps[index]
            result.append(AppRecord(url: fresh.url, name: fresh.name, bundleIdentifier: fresh.bundleIdentifier, version: fresh.version, automaticCategory: fresh.automaticCategory, bookmark: fresh.bookmark, fileIdentifier: fresh.fileIdentifier, isManual: fresh.isManual))
        }
        return result
    }
}
