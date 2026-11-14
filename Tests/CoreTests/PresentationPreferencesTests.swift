import Foundation
import XCTest
@testable import MenuCore

final class PresentationPreferencesTests: XCTestCase, @unchecked Sendable {
    // Losing the new optional block on encode would silently drop user choices.
    func testNewCatalogWritesDefaultPresentationBlock() throws {
        let data = try JSONEncoder().encode(CatalogDocument())
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let presentation = try XCTUnwrap(json["presentation"] as? [String: Any])
        XCTAssertEqual(presentation["showInDock"] as? Bool, false)
        XCTAssertEqual(presentation["launcherDensity"] as? String, "comfortable")
        XCTAssertEqual(json["schemaVersion"] as? Int, 1)
    }

    // Silently ignoring a malformed block would allow the protected file to be replaced.
    func testMalformedPresentationBlockIsRejected() throws {
        for block in ["true", "[]", "17", "\"comfortable\""] {
            let data = Data("{\"schemaVersion\":1,\"apps\":[],\"categories\":[],\"presentation\":\(block)}".utf8)
            XCTAssertThrowsError(try JSONDecoder().decode(CatalogDocument.self, from: data), block)
        }
    }

    func testMalformedIndividualPresentationValuesAreRejected() throws {
        for block in ["{\"showInDock\":\"true\"}", "{\"showInDock\":1}", "{\"launcherDensity\":false}", "{\"launcherDensity\":7}", "{\"launcherDensity\":[]}"] {
            let data = Data("{\"schemaVersion\":1,\"apps\":[],\"categories\":[],\"presentation\":\(block)}".utf8)
            XCTAssertThrowsError(try JSONDecoder().decode(CatalogDocument.self, from: data), block)
        }
    }
}

extension PresentationPreferencesTests {
    private var legacyCatalog: Data {
        Data(#"{"schemaVersion":1,"apps":[{"id":"1D9D75F8-CA5A-4C91-9985-88099A4FDE6D","url":"file:///Applications/Photo.app","name":"Photo","bundleIdentifier":"com.example.photo","version":"2.1","automaticCategory":"graphics","bookmark":"AQID","fileIdentifier":"volume-file-42","isManual":true,"hidden":true,"categoryOverride":"studio","availability":"unverified"}],"categories":[{"id":"studio","name":"Studio","isBuiltIn":false}]}"#.utf8)
    }

    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: url) }
        return url
    }

    func testLegacySchemaOnePreservesAllRecordsAndDefaultsPresentation() throws {
        let decoded = try JSONDecoder().decode(CatalogDocument.self, from: legacyCatalog)
        XCTAssertEqual(decoded.schemaVersion, 1)
        XCTAssertEqual(decoded.presentation, PresentationPreferences(showInDock: false, launcherDensity: .comfortable))
        XCTAssertEqual(decoded.apps, [AppRecord(
            id: try XCTUnwrap(UUID(uuidString: "1D9D75F8-CA5A-4C91-9985-88099A4FDE6D")),
            url: URL(fileURLWithPath: "/Applications/Photo.app"), name: "Photo", bundleIdentifier: "com.example.photo",
            version: "2.1", automaticCategory: "graphics", bookmark: Data([1, 2, 3]), fileIdentifier: "volume-file-42",
            isManual: true, hidden: true, categoryOverride: "studio", availability: .unverified
        )])
        XCTAssertEqual(decoded.categories, [AppCategory(id: "studio", name: "Studio", isBuiltIn: false)])
        XCTAssertEqual(try JSONDecoder().decode(CatalogDocument.self, from: JSONEncoder().encode(decoded)), decoded)
    }

    func testAbsentNullAndPartialPresentationUseSafeDefaults() throws {
        let cases: [(String, Bool, LauncherDensity)] = [
            ("null", false, .comfortable), ("{}", false, .comfortable),
            (#"{"showInDock":true}"#, true, .comfortable),
            (#"{"launcherDensity":"compact"}"#, false, .compact),
            (#"{"showInDock":null,"launcherDensity":null}"#, false, .comfortable)
        ]
        for (block, showInDock, density) in cases {
            let data = Data("{\"schemaVersion\":1,\"apps\":[],\"categories\":[],\"presentation\":\(block)}".utf8)
            let document = try JSONDecoder().decode(CatalogDocument.self, from: data)
            XCTAssertEqual(document.presentation.showInDock, showInDock, block)
            XCTAssertEqual(document.presentation.launcherDensity, density, block)
        }
    }

    func testUnknownStringDensityDefaultsWithoutLosingDockChoice() throws {
        let data = Data(#"{"schemaVersion":1,"apps":[],"categories":[],"presentation":{"showInDock":true,"launcherDensity":"future-density"}}"#.utf8)
        let document = try JSONDecoder().decode(CatalogDocument.self, from: data)
        XCTAssertTrue(document.presentation.showInDock)
        XCTAssertEqual(document.presentation.launcherDensity, .comfortable)
        XCTAssertEqual(try JSONDecoder().decode(LauncherDensity.self, from: Data(#""future-density""#.utf8)), .comfortable)
        XCTAssertThrowsError(try JSONDecoder().decode(LauncherDensity.self, from: Data("7".utf8)))
    }

    func testAllDensityChoicesRoundTripThroughExistingStore() async throws {
        let directory = try temporaryDirectory()
        var document = try JSONDecoder().decode(CatalogDocument.self, from: legacyCatalog)
        let originalApps = document.apps
        let originalCategories = document.categories
        for density in LauncherDensity.allCases {
            document.presentation = PresentationPreferences(showInDock: true, launcherDensity: density)
            try await PreferencesStore(directory: directory).save(document)
            let loaded = try await PreferencesStore(directory: directory).load()
            XCTAssertEqual(loaded.presentation, document.presentation)
            XCTAssertEqual(loaded.apps, originalApps)
            XCTAssertEqual(loaded.categories, originalCategories)
            XCTAssertEqual(loaded.schemaVersion, 1)
        }
        let data = try Data(contentsOf: directory.appendingPathComponent("catalog.json"))
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let block = try XCTUnwrap(json["presentation"] as? [String: Any])
        XCTAssertEqual(block["showInDock"] as? Bool, true)
        XCTAssertEqual(block["launcherDensity"] as? String, "spacious")
    }

    func testLegacyBackupRestoresRecordsWithDefaultPresentation() async throws {
        let directory = try temporaryDirectory()
        let file = directory.appendingPathComponent("catalog.json")
        try legacyCatalog.write(to: file)
        let store = PreferencesStore(directory: directory)
        var document = try await store.load()
        document.presentation = PresentationPreferences(showInDock: true, launcherDensity: .spacious)
        try await store.save(document)
        try Data("broken".utf8).write(to: file)
        do { _ = try await store.load(); XCTFail("Corrupt catalog was accepted") } catch {}
        try await store.restoreBackup()
        let restored = try await store.load()
        XCTAssertEqual(restored, try JSONDecoder().decode(CatalogDocument.self, from: legacyCatalog))
        XCTAssertEqual(restored.presentation, PresentationPreferences())
    }

    func testMalformedPresentationProtectsOriginalStoreFromSaving() async throws {
        let directory = try temporaryDirectory()
        let file = directory.appendingPathComponent("catalog.json")
        let original = Data(#"{"schemaVersion":1,"apps":[],"categories":[],"presentation":{"showInDock":"yes"}}"#.utf8)
        try original.write(to: file)
        let store = PreferencesStore(directory: directory)
        do { _ = try await store.load(); XCTFail("Malformed presentation was accepted") } catch {}
        do { try await store.save(CatalogDocument()); XCTFail("Protected catalog was overwritten") } catch {}
        XCTAssertEqual(try Data(contentsOf: file), original)
        XCTAssertFalse(FileManager.default.fileExists(atPath: directory.appendingPathComponent("catalog-backup.json").path))
    }

    func testExistingRequiredCatalogFieldsRemainStrict() throws {
        for json in [
            #"{"apps":[],"categories":[]}"#,
            #"{"schemaVersion":1,"categories":[]}"#,
            #"{"schemaVersion":1,"apps":[]}"#,
            #"{"schemaVersion":null,"apps":[],"categories":[]}"#,
            #"{"schemaVersion":1,"apps":null,"categories":[]}"#,
            #"{"schemaVersion":1,"apps":[],"categories":null}"#,
            #"{"schemaVersion":1,"apps":{},"categories":[]}"#,
            #"{"schemaVersion":1,"apps":[],"categories":[{}]}"#,
            #"{"schemaVersion":1,"apps":[{}],"categories":[]}"#
        ] {
            XCTAssertThrowsError(try JSONDecoder().decode(CatalogDocument.self, from: Data(json.utf8)), json)
        }
    }
}
