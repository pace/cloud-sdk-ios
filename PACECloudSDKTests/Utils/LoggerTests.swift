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

    override func setUp() {
        PACECloudSDK.shared.isLoggingEnabled = true
        let expectation = self.expectation(description: "DeleteLogs")

        TestLogger.deleteLogs() {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    override func tearDown() {
        super.tearDown()
        TestLogger.deleteLogs()
    }

    func testImportLogs() {
        let importLogs: [String] = ["\(dateFormatter.string(from: Date())) [PACECloudSDK_TEST] IMPORT LOG 1",
                                    "\(dateFormatter.string(from: Date().daysAgo(1))) [PACECloudSDK_TEST] IMPORT LOG 2",
                                    "\(dateFormatter.string(from: Date().daysAgo(2))) [PACECloudSDK_TEST] IMPORT LOG 3"]
        let expectation = self.expectation(description: "ImportLogs")
        var directoryPath: String = ""

        TestLogger.importLogs(importLogs)

        TestLogger.debugBundleDirectory() { url in
            guard let url = url else { return }
            directoryPath = url.path
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: directoryPath)
            XCTAssertTrue(items.count == 3)
        } catch {
            XCTFail()
        }
    }

    func testExportLogs() {
        let exportLogMessage = "Test export logs"
        var resultExportLogsString: String = ""
        let expectation = self.expectation(description: "ExportLogs")

        TestLogger.i(exportLogMessage)
        TestLogger.exportLogs { logs in
            resultExportLogsString = logs.reduce(into: "", { $0 += $1 + "\n" })
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertTrue(resultExportLogsString.contains(exportLogMessage))
    }

    func testMaxFileSize() {
        let dateString = dateFormatter.string(from: Date())
        let testLogs = String(repeating: "\(dateString) TEST\n", count: 1_000).components(separatedBy: "\n")
        let expectation = self.expectation(description: "MaxFileSize")
        var fileUrl: URL?

        TestLogger.importLogs(testLogs)

        TestLogger.debugBundleDirectory() { url in
            if let url = url {
                let fileDateString = self.fileDateFormatter.string(from: Date())
                fileUrl = url.appendingPathComponent("\(fileDateString)_pace_\(self.currentEnvironmentKey())_logs.txt")
            }

            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        do {
            let data: Data = try Data(contentsOf: fileUrl!)
            XCTAssertTrue(data.bytes.count <= 2000)
        } catch {
            XCTFail()
        }
    }

    func testSortLog() {
        let date = Date()
        let log1: String = "\(dateFormatter.string(from: Date(timeIntervalSince1970: date.timeIntervalSince1970 + 1))) [PACECloudSDK_TEST] IMPORT LOG 1"
        let log2: String = "\(dateFormatter.string(from: Date(timeIntervalSince1970: date.timeIntervalSince1970 + 2))) [PACECloudSDK_TEST] IMPORT LOG 2"
        let log3: String = "\(dateFormatter.string(from: Date(timeIntervalSince1970: date.timeIntervalSince1970 + 3))) [PACECloudSDK_TEST] IMPORT LOG 3"
        let importLogs: [String] = [log3, log2, log1]
        var exportLogs: [String] = .init()
        let expectation = self.expectation(description: "ImportUnsortedLogs")

        TestLogger.importLogs(importLogs)

        TestLogger.exportLogs { logs in
            exportLogs = logs
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertTrue(exportLogs == [log1, log2, log3])
    }

    func testDeleteOldFiles() {
        let testDate = Date()
        let importLogs = [
            "\(dateFormatter.string(from: testDate)) [PACECloudSDK_TEST] IMPORT LOG TODAY",
            "\(dateFormatter.string(from: testDate.daysAgo(1))) [PACECloudSDK_TEST] IMPORT LOG DAYS AGO 1",
            "\(dateFormatter.string(from: testDate.daysAgo(2))) [PACECloudSDK_TEST] IMPORT LOG DAYS AGO 2",
            "\(dateFormatter.string(from: testDate.daysAgo(3))) [PACECloudSDK_TEST] IMPORT LOG DAYS AGO 3",
            "\(dateFormatter.string(from: testDate.daysAgo(4))) [PACECloudSDK_TEST] IMPORT LOG DAYS AGO 4",
            "\(dateFormatter.string(from: testDate.daysAgo(5))) [PACECloudSDK_TEST] IMPORT LOG DAYS AGO 5"
        ]

        let controlFileNames = [
            "\(self.fileDateFormatter.string(from: testDate))_pace_\(self.currentEnvironmentKey())_logs.txt",
            "\(self.fileDateFormatter.string(from: testDate.daysAgo(1)))_pace_\(self.currentEnvironmentKey())_logs.txt",
            "\(self.fileDateFormatter.string(from: testDate.daysAgo(2)))_pace_\(self.currentEnvironmentKey())_logs.txt",
            "\(self.fileDateFormatter.string(from: testDate.daysAgo(3)))_pace_\(self.currentEnvironmentKey())_logs.txt"
        ]

        let expectation = self.expectation(description: "DeleteOldFiles")
        var directoryPath: String = ""

        TestLogger.importLogs(importLogs)

        TestLogger.debugBundleDirectory() { url in
            guard let url = url else { return }
            directoryPath = url.path
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: directoryPath)
            XCTAssertTrue(items.sorted() == controlFileNames.sorted())
        } catch {
            XCTFail()
        }
    }

    func testOptOut() {
        let expectation = self.expectation(description: "OptOut 1")
        TestLogger.importLogs(["\(dateFormatter.string(from: Date())) [PACECloudSDK_TEST] OPT OUT TEST",]) {
            PACECloudSDK.shared.isLoggingEnabled = false
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        let expectation2 = self.expectation(description: "OptOut 2")
        var exportLogs: [String] = .init()

        TestLogger.exportLogs { logs in
            exportLogs = logs
            expectation2.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertTrue(exportLogs.isEmpty)
    }

    func currentEnvironmentKey() -> String {
        #if PRODUCTION
        return "production"
        #elseif STAGE
        return "stage"
        #elseif SANDBOX
        return "sandbox"
        #else
        return "development"
        #endif
    }
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
