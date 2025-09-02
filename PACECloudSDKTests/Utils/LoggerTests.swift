//
//  LoggerTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class LoggerTests: XCTestCase {
    private let dateFormatter: DateFormatter = .init(formatString: "yyyy-MM-dd HH:mm:ss.SSS")
    private let fileDateFormatter: DateFormatter = .init(formatString: "yyyy-MM-dd")
    private let logFileSuffix = "_pace_development_logs.txt"

    override func setUp(completion: @escaping (Error?) -> Void) {
        // Setup SDK first and then delete logs
        PACECloudSDK.shared.setup(with: .init(apiKey: "",
                                              clientId: "unit-test-dummy",
                                              geoDatabaseMode: .disabled,
                                              environment: .development,
                                              isRedirectSchemeCheckEnabled: false,
                                              persistLogs: true))

        PACECloudSDK.shared.setLogLevel(to: .info)
        deleteLogs()
        completion(nil)
    }

    func testDeleteLogs() {
        TestLogger.i("Logging Test 1")
        TestLogger.i("Logging Test 2")
        TestLogger.i("Logging Test 3")

        let logs: [String] = ["\(dateString(daysAgo: 1)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 2)) [PACECloudSDK_TEST] IMPORT LOG 2"]

        importLogs(logs)
        deleteLogs()

        XCTAssertEqual(exportedLogs(), [])
        XCTAssertEqual(debugBundleFileNumber(), 0)
    }

    func testFileCountMultipleDaysOrderedConsecutive() {
        TestLogger.i("Logging Test 1")
        TestLogger.i("Logging Test 2")
        TestLogger.i("Logging Test 3")

        let logs: [String] = ["\(dateString(daysAgo: 1)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 2)) [PACECloudSDK_TEST] IMPORT LOG 2"]

        importLogs(logs)
        XCTAssertEqual(debugBundleFileNumber(), 3)
    }

    func testFileCountMultipleDaysOrderedGap() {
        TestLogger.i("Logging Test 1")
        TestLogger.i("Logging Test 2")
        TestLogger.i("Logging Test 3")

        let logs: [String] = ["\(dateString(daysAgo: 1)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 3)) [PACECloudSDK_TEST] IMPORT LOG 2"]

        importLogs(logs)
        XCTAssertEqual(debugBundleFileNumber(), 3)
    }

    func testFileCountMultipleDaysUnorderedConsecutive() {
        TestLogger.i("Logging Test 1")
        TestLogger.i("Logging Test 2")
        TestLogger.i("Logging Test 3")

        let logs: [String] = ["\(dateString(daysAgo: 2)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 1)) [PACECloudSDK_TEST] IMPORT LOG 2",
                              "\(dateString(daysAgo: 3)) [PACECloudSDK_TEST] IMPORT LOG 3"]

        importLogs(logs)
        XCTAssertEqual(debugBundleFileNumber(), 4)
    }

    func testFileCountMultipleDaysUnorderedGap() {
        TestLogger.i("Logging Test 1")
        TestLogger.i("Logging Test 2")
        TestLogger.i("Logging Test 3")

        let logs: [String] = ["\(dateString(daysAgo: 2)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 1)) [PACECloudSDK_TEST] IMPORT LOG 2",
                              "\(dateString(daysAgo: 4)) [PACECloudSDK_TEST] IMPORT LOG 3"]

        importLogs(logs)
        XCTAssertEqual(debugBundleFileNumber(), 4)
    }

    func testFileCountMultipleDaysOneWeekAgo() {
        let logs: [String] = ["\(dateString(daysAgo: 8)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 10)) [PACECloudSDK_TEST] IMPORT LOG 2",
                              "\(dateString(daysAgo: 13)) [PACECloudSDK_TEST] IMPORT LOG 3"]

        deleteLogs() // Delete logs again right before importing
        importLogs(logs)
        XCTAssertEqual(debugBundleFileNumber(), 3)
    }

    func testFileCountMultipleDaysOneWeekAgoExceedingMaxNumberOfFiles() {
        let logs: [String] = ["\(dateString(daysAgo: 8)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 12)) [PACECloudSDK_TEST] IMPORT LOG 2",
                              "\(dateString(daysAgo: 9)) [PACECloudSDK_TEST] IMPORT LOG 3",
                              "\(dateString(daysAgo: 11)) [PACECloudSDK_TEST] IMPORT LOG 4",
                              "\(dateString(daysAgo: 15)) [PACECloudSDK_TEST] IMPORT LOG 5",
                              "\(dateString(daysAgo: 13)) [PACECloudSDK_TEST] IMPORT LOG 6"]

        deleteLogs() // Delete logs again right before importing
        importLogs(logs)
        XCTAssertEqual(debugBundleFileNumber(), 4)
    }

    func testFileCountExceedingMaxNumberOfFilesOrderedConsecutive() {
        TestLogger.i("Logging Test 1")
        TestLogger.i("Logging Test 2")
        TestLogger.i("Logging Test 3")

        let logs: [String] = ["\(dateString(daysAgo: 1)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 2)) [PACECloudSDK_TEST] IMPORT LOG 2",
                              "\(dateString(daysAgo: 3)) [PACECloudSDK_TEST] IMPORT LOG 3",
                              "\(dateString(daysAgo: 4)) [PACECloudSDK_TEST] IMPORT LOG 4",
                              "\(dateString(daysAgo: 5)) [PACECloudSDK_TEST] IMPORT LOG 5"]

        deleteLogs() // Delete logs again right before importing
        importLogs(logs)
        XCTAssertEqual(debugBundleFileNumber(), 4)
    }

    func testFileCountExceedingMaxNumberOfFilesOrderedGap() {
        TestLogger.i("Logging Test 1")
        TestLogger.i("Logging Test 2")
        TestLogger.i("Logging Test 3")

        let logs: [String] = ["\(dateString(daysAgo: 2)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 4)) [PACECloudSDK_TEST] IMPORT LOG 2",
                              "\(dateString(daysAgo: 5)) [PACECloudSDK_TEST] IMPORT LOG 3",
                              "\(dateString(daysAgo: 7)) [PACECloudSDK_TEST] IMPORT LOG 4",
                              "\(dateString(daysAgo: 9)) [PACECloudSDK_TEST] IMPORT LOG 5"]

        deleteLogs() // Delete logs again right before importing
        importLogs(logs)
        XCTAssertEqual(debugBundleFileNumber(), 4)
    }

    func testFileCountExceedingMaxNumberOfFilesUnorderedConsecutive() {
        TestLogger.i("Logging Test 1")
        TestLogger.i("Logging Test 2")
        TestLogger.i("Logging Test 3")

        let logs: [String] = ["\(dateString(daysAgo: 2)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 1)) [PACECloudSDK_TEST] IMPORT LOG 2",
                              "\(dateString(daysAgo: 3)) [PACECloudSDK_TEST] IMPORT LOG 3",
                              "\(dateString(daysAgo: 5)) [PACECloudSDK_TEST] IMPORT LOG 4",
                              "\(dateString(daysAgo: 4)) [PACECloudSDK_TEST] IMPORT LOG 5"]

        deleteLogs() // Delete logs again right before importing
        importLogs(logs)
        XCTAssertEqual(debugBundleFileNumber(), 4)
    }

    func testFileCountExceedingMaxNumberOfFilesUnorderedGap() {
        TestLogger.i("Logging Test 1")
        TestLogger.i("Logging Test 2")
        TestLogger.i("Logging Test 3")

        let logs: [String] = ["\(dateString(daysAgo: 4)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 2)) [PACECloudSDK_TEST] IMPORT LOG 2",
                              "\(dateString(daysAgo: 7)) [PACECloudSDK_TEST] IMPORT LOG 3",
                              "\(dateString(daysAgo: 5)) [PACECloudSDK_TEST] IMPORT LOG 4",
                              "\(dateString(daysAgo: 9)) [PACECloudSDK_TEST] IMPORT LOG 5"]

        deleteLogs() // Delete logs again right before importing
        importLogs(logs)
        XCTAssertEqual(debugBundleFileNumber(), 4)
    }

    func testExportedLogsMultipleDaysOrderedConsecutive() {
        let logs: [String] = ["\(dateString(daysAgo: 0)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 0)) [PACECloudSDK_TEST] IMPORT LOG 2",
                              "\(dateString(daysAgo: 1)) [PACECloudSDK_TEST] IMPORT LOG 3",
                              "\(dateString(daysAgo: 2)) [PACECloudSDK_TEST] IMPORT LOG 4"]

        deleteLogs() // Delete logs again right before importing
        importLogs(logs)
        XCTAssertEqual(exportedLogs(), [logs[3], logs[2], logs[0], logs[1]])
    }

    func testExportedLogsMultipleDaysOrderedGap() {
        let logs: [String] = ["\(dateString(daysAgo: 0)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 0)) [PACECloudSDK_TEST] IMPORT LOG 2",
                              "\(dateString(daysAgo: 1)) [PACECloudSDK_TEST] IMPORT LOG 3",
                              "\(dateString(daysAgo: 3)) [PACECloudSDK_TEST] IMPORT LOG 4"]

        deleteLogs() // Delete logs again right before importing
        importLogs(logs)
        XCTAssertEqual(exportedLogs(), [logs[3], logs[2], logs[0], logs[1]])
    }

    func testExportedLogsMultipleDaysUnorderedConsecutive() {
        let logs: [String] = ["\(dateString(daysAgo: 1)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 0)) [PACECloudSDK_TEST] IMPORT LOG 2",
                              "\(dateString(daysAgo: 0)) [PACECloudSDK_TEST] IMPORT LOG 3",
                              "\(dateString(daysAgo: 2)) [PACECloudSDK_TEST] IMPORT LOG 4"]

        deleteLogs() // Delete logs again right before importing
        importLogs(logs)
        XCTAssertEqual(exportedLogs(), [logs[3], logs[0], logs[1], logs[2]])
    }

    func testExportedLogsMultipleDaysUnorderedGap() {
        let logs: [String] = ["\(dateString(daysAgo: 1)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 0)) [PACECloudSDK_TEST] IMPORT LOG 2",
                              "\(dateString(daysAgo: 3)) [PACECloudSDK_TEST] IMPORT LOG 3",
                              "\(dateString(daysAgo: 0)) [PACECloudSDK_TEST] IMPORT LOG 4"]

        deleteLogs() // Delete logs again right before importing
        importLogs(logs)
        XCTAssertEqual(exportedLogs(), [logs[2], logs[0], logs[1], logs[3]])
    }

    func testExportedLogsMultipleDaysOneWeekAgo() {
        let logs: [String] = ["\(dateString(daysAgo: 8)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 13)) [PACECloudSDK_TEST] IMPORT LOG 2",
                              "\(dateString(daysAgo: 10)) [PACECloudSDK_TEST] IMPORT LOG 3"]

        importLogs(logs)
        XCTAssertEqual(exportedLogs(), [logs[1], logs[2], logs[0]])
    }

    func testMaxFileSize() {
        let dateString = dateFormatter.string(from: Date())
        let testLogs = String(repeating: "\(dateString) TEST\n", count: 1_000).components(separatedBy: "\n")

        importLogs(testLogs)

        guard let fileName = debugBundleFiles().first else {
            XCTFail()
            return
        }

        let logsEntries = debugBundleLogs(for: fileName)
        let bytes = logsEntries.map { $0.data(using: .utf8)?.bytes.count ?? 0 }.reduce(0, +)

        XCTAssertTrue(bytes <= 2000)
    }

    func testSortLogsMultipleDaysUnorderedGap() {
        let today = Date()
        let logs: [String] = ["\(dateFormatter.string(from: Date(timeIntervalSince1970: today.timeIntervalSince1970 + 1))) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 2)) [PACECloudSDK_TEST] IMPORT LOG 2",
                              "\(dateFormatter.string(from: Date(timeIntervalSince1970: today.timeIntervalSince1970 + 3))) [PACECloudSDK_TEST] IMPORT LOG 3",
                              "\(dateFormatter.string(from: Date(timeIntervalSince1970: today.timeIntervalSince1970 + 2))) [PACECloudSDK_TEST] IMPORT LOG 4",
                              "\(dateString(daysAgo: 4)) [PACECloudSDK_TEST] IMPORT LOG 5"]
        importLogs(logs)
        XCTAssertEqual(exportedLogs(), [logs[4], logs[1], logs[0], logs[3], logs[2]])
    }

    func testFileNames() {
        TestLogger.i("Logging Test 1")
        TestLogger.i("Logging Test 2")
        TestLogger.i("Logging Test 3")

        let logs: [String] = ["\(dateString(daysAgo: 3)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 1)) [PACECloudSDK_TEST] IMPORT LOG 2",
                              "\(dateString(daysAgo: 2)) [PACECloudSDK_TEST] IMPORT LOG 3"]
        importLogs(logs)

        let controlFileName1 = "\(fileDateString(daysAgo: 0))\(logFileSuffix)"
        let controlFileName2 = "\(fileDateString(daysAgo: 1))\(logFileSuffix)"
        let controlFileName3 = "\(fileDateString(daysAgo: 2))\(logFileSuffix)"
        let controlFileName4 = "\(fileDateString(daysAgo: 3))\(logFileSuffix)"

        let files = debugBundleFiles()

        XCTAssertTrue(files.contains(controlFileName1))
        XCTAssertTrue(files.contains(controlFileName2))
        XCTAssertTrue(files.contains(controlFileName3))
        XCTAssertTrue(files.contains(controlFileName4))
    }

    func testFileNamesExceedingMaxNumberOfFiles() {
        TestLogger.i("Logging Test 1")
        TestLogger.i("Logging Test 2")
        TestLogger.i("Logging Test 3")

        let logs: [String] = ["\(dateString(daysAgo: 8)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 2)) [PACECloudSDK_TEST] IMPORT LOG 2",
                              "\(dateString(daysAgo: 6)) [PACECloudSDK_TEST] IMPORT LOG 3",
                              "\(dateString(daysAgo: 7)) [PACECloudSDK_TEST] IMPORT LOG 4",
                              "\(dateString(daysAgo: 3)) [PACECloudSDK_TEST] IMPORT LOG 5"]
        importLogs(logs)

        let controlFileName1 = "\(fileDateString(daysAgo: 0))\(logFileSuffix)"
        let controlFileName2 = "\(fileDateString(daysAgo: 2))\(logFileSuffix)"
        let controlFileName3 = "\(fileDateString(daysAgo: 3))\(logFileSuffix)"
        let controlFileName4 = "\(fileDateString(daysAgo: 6))\(logFileSuffix)"

        let files = debugBundleFiles()

        XCTAssertTrue(files.contains(controlFileName1))
        XCTAssertTrue(files.contains(controlFileName2))
        XCTAssertTrue(files.contains(controlFileName3))
        XCTAssertTrue(files.contains(controlFileName4))
    }

    func testFileContent() {
        let today = Date()

        let logs: [String] = ["\(dateFormatter.string(from: Date(timeIntervalSince1970: today.timeIntervalSince1970 + 1))) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateFormatter.string(from: Date(timeIntervalSince1970: today.timeIntervalSince1970 + 3))) [PACECloudSDK_TEST] IMPORT LOG 2",
                              "\(dateFormatter.string(from: Date(timeIntervalSince1970: today.timeIntervalSince1970 + 10))) [PACECloudSDK_TEST] IMPORT LOG 3",
                              "\(dateFormatter.string(from: Date(timeIntervalSince1970: today.timeIntervalSince1970 + 2))) [PACECloudSDK_TEST] IMPORT LOG 4",
                              "\(dateFormatter.string(from: Date(timeIntervalSince1970: today.timeIntervalSince1970 + 0))) [PACECloudSDK_TEST] IMPORT LOG 5",
                              "\(dateFormatter.string(from: Date(timeIntervalSince1970: today.timeIntervalSince1970 + 8))) [PACECloudSDK_TEST] IMPORT LOG 4"]
        importLogs(logs)

        guard let fileName = debugBundleFiles().first else {
            XCTFail()
            return
        }

        let logsEntries = debugBundleLogs(for: fileName)
        XCTAssertEqual(logsEntries, [logs[4], logs[0], logs[3], logs[1], logs[5], logs[2]])
    }

    func testOptOut() {
        TestLogger.i("Logging Test 1")
        TestLogger.i("Logging Test 2")
        TestLogger.i("Logging Test 3")

        let logs: [String] = ["\(dateString(daysAgo: 1)) [PACECloudSDK_TEST] IMPORT LOG 1",
                              "\(dateString(daysAgo: 2)) [PACECloudSDK_TEST] IMPORT LOG 2"]

        importLogs(logs)

        PACECloudSDK.shared.setLogLevel(to: .none)

        XCTAssertEqual(exportedLogs(), [])
        XCTAssertEqual(debugBundleFileNumber(), 0)
    }

    func testDebugLog() {
        PACECloudSDK.shared.setLogLevel(to: .debug)

        let debugMessage = "DEBUG LOG"
        let infoMessage = "INFO LOG"

        TestLogger.d(debugMessage)
        TestLogger.i(infoMessage)

        let logs = exportedLogs()

        XCTAssertTrue(logs.contains(where: { $0.contains(debugMessage) }))
        XCTAssertTrue(logs.contains(where: { $0.contains(infoMessage) }))
    }

    func testInfoLog() {
        PACECloudSDK.shared.setLogLevel(to: .info)

        let debugMessage = "DEBUG LOG"
        let infoMessage = "INFO LOG"
        let warningMessage = "WARNING LOG"

        TestLogger.d(debugMessage)
        TestLogger.i(infoMessage)
        TestLogger.w(warningMessage)

        let logs = exportedLogs()

        XCTAssertFalse(logs.contains(where: { $0.contains(debugMessage) }))
        XCTAssertTrue(logs.contains(where: { $0.contains(infoMessage) }))
        XCTAssertTrue(logs.contains(where: { $0.contains(warningMessage) }))
    }

    func testErrorLog() {
        PACECloudSDK.shared.setLogLevel(to: .error)

        let debugMessage = "DEBUG LOG"
        let infoMessage = "INFO LOG"
        let warningMessage = "WARNING LOG"
        let errorMessage = "ERROR MESSAGE"

        TestLogger.d(debugMessage)
        TestLogger.i(infoMessage)
        TestLogger.w(warningMessage)
        TestLogger.e(errorMessage)

        let logs = exportedLogs()

        XCTAssertFalse(logs.contains(where: { $0.contains(debugMessage) }))
        XCTAssertFalse(logs.contains(where: { $0.contains(infoMessage) }))
        XCTAssertFalse(logs.contains(where: { $0.contains(warningMessage) }))
        XCTAssertTrue(logs.contains(where: { $0.contains(errorMessage) }))
    }

    func testDisableLogging() {
        PACECloudSDK.shared.setLogLevel(to: .none)

        let debugMessage = "DEBUG LOG"
        let infoMessage = "INFO LOG"
        let warningMessage = "WARNING LOG"
        let errorMessage = "ERROR MESSAGE"

        TestLogger.d(debugMessage)
        TestLogger.i(infoMessage)
        TestLogger.w(warningMessage)
        TestLogger.e(errorMessage)

        let logs = exportedLogs()

        XCTAssertFalse(logs.contains(where: { $0.contains(debugMessage) }))
        XCTAssertFalse(logs.contains(where: { $0.contains(infoMessage) }))
        XCTAssertFalse(logs.contains(where: { $0.contains(warningMessage) }))
        XCTAssertFalse(logs.contains(where: { $0.contains(errorMessage) }))
    }

    func testDisableLogPersistance() {
        PACECloudSDK.shared.persistLogs = false
        TestLogger.i("INFO LOG")
        XCTAssertTrue(debugBundleFileNumber() == 0)
    }
}

private extension LoggerTests {
    private func importLogs(_ logs: [String]) {
        let expectation = self.expectation(description: "ImportExpectation")

        TestLogger.importLogs(logs) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    private func exportedLogs() -> [String] {
        let expectation = self.expectation(description: "ExportExpectation")
        var exportedLogs: [String] = []

        TestLogger.exportLogs { logs in
            exportedLogs = logs.filter { !($0.contains("❌") || $0.contains("[API key]")) }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
        return exportedLogs
    }

    private func deleteLogs() {
        let expectation = self.expectation(description: "DeleteExpectation")

        TestLogger.clearCurrentLogs()
        TestLogger.deletePersistedLogs {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    private func debugBundleFileNumber() -> Int {
        let expectation = self.expectation(description: "DebugBundleExpectation")
        var directoryPath: String?

        TestLogger.debugBundleDirectory() { url in
            directoryPath = url?.path
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)

        guard let directoryPath, FileManager.default.fileExists(atPath: directoryPath) else { return 0 }

        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: directoryPath)
            return items.count
        } catch {
            return -1
        }
    }

    private func directoryPath() -> String {
        let expectation = self.expectation(description: "DebugBundleExpectation")
        var directoryPath: String = ""

        TestLogger.debugBundleDirectory() { url in
            guard let url = url else { return }
            directoryPath = url.path
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
        return directoryPath
    }

    private func debugBundleFiles() -> [String] {
        let path = directoryPath()

        do {
            return try FileManager.default.contentsOfDirectory(atPath: path)
        } catch {
            return []
        }
    }

    private func debugBundleLogs(for fileName: String) -> [String] {
        let path = directoryPath()

        guard let fileURL = URL(string: path)?.appendingPathComponent(fileName) else {
            XCTFail()
            return []
        }

        do {
            let fileString: String = try String(contentsOfFile: fileURL.path, encoding: .utf8)
            let logsOfFile: [String] = fileString.components(separatedBy: "\n").filter { !($0.isEmpty || ($0.contains("❌") || $0.contains("[API key]"))) }
            return logsOfFile
        } catch {
            XCTFail()
            return []
        }
    }

    func dateString(daysAgo: Int) -> String {
        dateFormatter.string(from: Date().daysAgo(daysAgo))
    }

    func fileDateString(daysAgo: Int) -> String {
        fileDateFormatter.string(from: Date().daysAgo(daysAgo))
    }

    class TestLogger: Logger {
        override class var logTag: String {
            "[PACECloudSDK_TEST]"
        }

        override class var maxNumberOfFiles: Int {
            4
        }

        override class var maxFileSize: Int {
            2000 // in bytes, 2KB
        }
    }
}
