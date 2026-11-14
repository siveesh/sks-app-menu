import Foundation
import XCTest
@testable import MenuCore

final class PreferencesStoreTests: XCTestCase, @unchecked Sendable {
    func directory() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: url) }
        return url
    }
    func testRoundTripAndBackupRecovery() async throws {
        let dir = try directory()
        let store = PreferencesStore(directory: dir)
        var doc = CatalogDocument()
        doc.categories = [AppCategory(id: "custom", name: "Creative", isBuiltIn: false)]
        try await store.save(doc)
        doc.categories[0].name = "Studio"
        try await store.save(doc)
        let loaded = try await store.load()
        XCTAssertEqual(loaded.categories[0].name, "Studio")
        try Data("broken".utf8).write(to: dir.appendingPathComponent("catalog.json"))
        do { _ = try await store.load(); XCTFail("Corrupt input accepted") } catch {}
        do { try await store.save(CatalogDocument()); XCTFail("Recovery state overwritten") } catch {}
        try await store.restoreBackup()
        let recovered = try await store.load()
        XCTAssertEqual(recovered.categories[0].name, "Creative")
        XCTAssertTrue(try FileManager.default.contentsOfDirectory(atPath: dir.path).contains { $0.hasPrefix("catalog-archive-") })
    }
    func testNewerSchemaPreservedAndExplicitResetArchives() async throws {
        let dir = try directory()
        let url = dir.appendingPathComponent("catalog.json")
        let original = Data("{\"schemaVersion\":99,\"apps\":[],\"categories\":[]}".utf8)
        try original.write(to: url)
        let store = PreferencesStore(directory: dir)
        do { _ = try await store.load(); XCTFail("Newer schema accepted") } catch {}
        do { try await store.save(CatalogDocument()); XCTFail("Newer schema overwritten") } catch {}
        XCTAssertEqual(try Data(contentsOf: url), original)
        try await store.archiveAndReset()
        let clean = try await store.load()
        XCTAssertTrue(clean.apps.isEmpty)
        XCTAssertEqual(clean.schemaVersion, 1)
    }
    func testInvalidReferencesRejectedWithoutOverwriting() async throws {
        let dir = try directory()
        let url = dir.appendingPathComponent("catalog.json")
        let data = Data("{\"schemaVersion\":1,\"apps\":[],\"categories\":[{\"id\":\"x\",\"name\":\"\",\"isBuiltIn\":false}]}".utf8)
        try data.write(to: url)
        do { _ = try await PreferencesStore(directory: dir).load(); XCTFail("Invalid category accepted") } catch {}
        XCTAssertEqual(try Data(contentsOf: url), data)
    }
    func testApplicationOverridesSurviveNewStoreInstance() async throws {
        let dir = try directory()
        let app = AppRecord(url: URL(fileURLWithPath: "/Applications/Photo.app"), name: "Photo", hidden: true, categoryOverride: "studio")
        let doc = CatalogDocument(apps: [app], categories: [AppCategory(id: "studio", name: "Studio")])
        try await PreferencesStore(directory: dir).save(doc)
        let reopened = try await PreferencesStore(directory: dir).load()
        XCTAssertEqual(reopened.apps[0].id, app.id)
        XCTAssertTrue(reopened.apps[0].hidden)
        XCTAssertEqual(reopened.apps[0].categoryOverride, "studio")
    }
    func testExternalCorruptionCannotBeSavedOver() async throws {
        let dir = try directory()
        let store = PreferencesStore(directory: dir)
        _ = try await store.load()
        let original = Data("invalid".utf8)
        let url = dir.appendingPathComponent("catalog.json")
        try original.write(to: url)
        do { try await store.save(CatalogDocument()); XCTFail("External damage overwritten") } catch {}
        XCTAssertEqual(try Data(contentsOf: url), original)
    }
    func testWriteFailureDoesNotReportSuccess() async throws {
        let dir = try directory()
        let blocker = dir.appendingPathComponent("file")
        try Data().write(to: blocker)
        do { try await PreferencesStore(directory: blocker).save(CatalogDocument()); XCTFail("Write should fail") } catch {}
    }
}
