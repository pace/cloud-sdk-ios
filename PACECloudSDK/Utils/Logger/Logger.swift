//
//  Logger.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import UIKit

// swiftlint:disable file_length
open class Logger {
    open class var logTag: String { "[Logger]" }
    open class var moduleTag: String { "" }
    open class var maxNumberOfFiles: Int { 7 }
    open class var maxFileSize: Int { 10 * 1000 * 1000 } // in bytes, 10MB

    private static let maxNumberOfFilesUpperLimit: Int = 7
    private static let maxFileSizeUpperLimit: Int = 10 * 1000 * 1000

    private static var currentLogs: [String] = []

    private static let loggingQueue = DispatchQueue(label: "pacecloudsdklogger", qos: .background)

    private static let dateFormatter: DateFormatter = .init(formatString: "yyyy-MM-dd HH:mm:ss.SSS")
    private static let dateRegexString = "\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d{3}"
    private static let dateRegex = try! NSRegularExpression(pattern: dateRegexString) // swiftlint:disable:this force_try

    private static let fileDateFormatter: DateFormatter = .init(formatString: "yyyy-MM-dd")
    private static let fileDateRegex = "\\d{4}-\\d{2}-\\d{2}"

    private static let fileManager: FileManager = FileManager.default
    private static let logsDirectoryName: String = "PaceLogs"

    public enum LogLevel: Int {
        case debug
        case info
        case warning
        case error
        case none

        var tag: String {
            switch self {
            case .debug:
                return "[D]"

            case .info:
                return "[I]"

            case .warning:
                return "[W]"

            case .error:
                return "[E]"

            case .none:
                return ""
            }
        }
    }

    open class func d(_ message: String) {
        log(message: message, level: .debug)
    }

    open class func i(_ message: String) {
        log(message: message, level: .info)
    }

    open class func w(_ message: String) {
        log(message: message, level: .warning)
    }

    open class func e(_ message: String) {
        log(message: message, level: .error)
    }

    private static func log(message: String, level: LogLevel) {
        loggingQueue.async {
            guard level.rawValue >= PACECloudSDK.shared.currentLogLevel.rawValue else { return }

            let log = "\(logTag)\(moduleTag)\(level.tag) \(message)"

            NSLog(log)

            guard PACECloudSDK.shared.isLoggingEnabled else { return }

            let messageLogs: [String] = message.components(separatedBy: "\n")

            messageLogs.forEach {
                let singleMessageLog = "\(logTag)\(moduleTag)\(level.tag) \($0)"
                let timestamp = dateFormatter.string(from: Date())
                let timestampLog = "\(timestamp) \(singleMessageLog)"
                currentLogs.append(timestampLog)
            }

            syncFiles()
        }
    }

    public static func debugBundleDirectory(completion: @escaping ((URL?) -> Void)) {
        guard PACECloudSDK.shared.isLoggingEnabled else {
            completion(nil)
            return
        }

        createExportLogs(completion: completion)
    }

    public static func exportLogs(completion: @escaping (([String]) -> Void)) {
        guard PACECloudSDK.shared.isLoggingEnabled else {
            completion([])
            return
        }

        loggingQueue.async {
            let sortedLogs = sortedLogs(persistedLogs() + currentLogs)
            completion(sortedLogs.filter { !$0.isEmpty })
        }
    }

    public static func importLogs(_ logs: [String], completion: (() -> Void)? = nil) {
        guard PACECloudSDK.shared.isLoggingEnabled else {
            completion?()
            return
        }

        mergeAndSortLogFiles(withNewLogs: logs) {
            completion?()
        }
    }

    /// Deletes all currently not persisted Logs.
    public static func clearCurrentLogs() {
        currentLogs = []
    }

    public static func deletePersistedLogs(completion: (() -> Void)? = nil) {
        loggingQueue.async {
            let currentLogFiles = self.persistedLogFiles()
            currentLogFiles.forEach {
                deleteFile(with: $0)
            }
            completion?()
        }
    }

    public static func didSetLogPersistence(enable: Bool) {
        if enable { optIn() } else { optOut() }
    }
}

extension Logger {
    static func optIn() {
        if PACECloudSDK.shared.isLoggingEnabled {
            createLogsDirectory()
        }
    }

    static func optOut() {
        deletePersistedLogs()
    }
}

// MARK: - File Management
private extension Logger {
    static func createLogsDirectory() {
        guard let logsDirectory = logsDirectory else { return }

        do {
            try fileManager.createDirectory(atPath: logsDirectory.path,
                                            withIntermediateDirectories: true,
                                            attributes: [FileAttributeKey(rawValue: FileAttributeKey.protectionKey.rawValue): FileProtectionType.none])
        } catch _ {
            e("Failed creating logs directory")
        }
    }

    /// Persists the logs of today
    static func syncFiles() {
        loggingQueue.async {
            guard !currentLogs.isEmpty,
                  PACECloudSDK.shared.config != nil,
                  PACECloudSDK.shared.persistLogs else { return }

            guard let todaysFileUrl = fileUrl(for: Date()) else {
                w("[Logger] Couldn't sync files. Invalid file.")
                return
            }

            guard append(logs: currentLogs, to: todaysFileUrl) else { return }

            deleteOldestFileIfNeeded()
            currentLogs = [] // Reset logs
        }
    }

    /// Appends logs to a file with the specified url.
    /// Creates the file if if does not exist yet
    @discardableResult
    static func append(logs: [String], to fileUrl: URL) -> Bool {
        let logString = logs.reduce(into: "", { $0 += $1 + "\n" }) // Append a linebreak
        let logsData = Data(logString.utf8)
        let logsSize = logsData.bytes.count
        let fileSizeLimit: Int = min(maxFileSize, maxFileSizeUpperLimit)
        let bytesExcess = logsSize - fileSizeLimit
        let dataToAppend: Data

        if !fileManager.fileExists(atPath: fileUrl.path) {
            // Create file with data
            // Delete oldest file if number of files exceeds the limit
            fileManager.createFile(atPath: fileUrl.path, contents: nil, attributes: nil)

            // Truncate the current data to be appended if necessary
            let truncatedData = truncateData(logsData, for: bytesExcess)
            dataToAppend = truncatedData
        } else {
            // Files available for truncating
            let isTruncatingSuccessful = truncateFilesIfNeeded(for: logsSize)

            if isTruncatingSuccessful {
                // File already exists + no errors
                // append data to file
                dataToAppend = logsData
            } else {
                // All files got deleted and currentLogData may exceed fileSize
                // Truncate the current data to be appended if necessary
                let truncatedData = truncateData(logsData, for: bytesExcess)
                fileManager.createFile(atPath: fileUrl.path, contents: nil, attributes: nil)
                dataToAppend = truncatedData
            }
        }

        return write(data: dataToAppend, to: fileUrl, replacesContent: false)
    }

    @discardableResult
    static func write(data: Data, to fileUrl: URL, replacesContent: Bool) -> Bool {
        guard let fileHandle = FileHandle(forWritingAtPath: fileUrl.path) else {
            e("[Logger] Couldn't merge logs, couldn't create fileHandle with fileUrl: \(fileUrl).")
            return false
        }

        if replacesContent {
            fileHandle.truncateFile(atOffset: 0)
        } else {
            fileHandle.seekToEndOfFile()
        }

        fileHandle.write(data)
        fileHandle.closeFile()
        return true
    }

    /// Removes data from the persisted files if the size of the debug bundle exceeds the max limit
    static func truncateFilesIfNeeded(for bytesToAppend: Int) -> Bool {
        let currentFiles = persistedLogFiles() // Already sorted by creation date
        let logsSize = currentFiles.map { fileSize(for: $0) }.reduce(0, +)
        let fileSizeLimit: Int = min(maxFileSize, maxFileSizeUpperLimit)
        var currentBytesExcess = logsSize + bytesToAppend - fileSizeLimit

        for fileName in currentFiles {
            // File size isn't exceeding the limit anymore -> data can be appended as is
            guard currentBytesExcess > 0 else { return true }

            let fileSize = self.fileSize(for: fileName)

            guard fileSize > currentBytesExcess else {
                // Delete file since its size is less than the required file size
                // Reduce currentByteExcess by the value of the current file size
                deleteFile(with: fileName)
                currentBytesExcess -= fileSize
                continue
            }

            guard truncateFile(fileName, for: currentBytesExcess) else {
                // Truncating went wrong -> continue with next file
                continue
            }
            currentBytesExcess = 0
        }

        // No more files available to truncate
        return false
    }

    /// Returns the file size of the specified file name
    static func fileSize(for fileName: String) -> Int {
        guard let logsDirectory = self.logsDirectory else { return 0 }
        let fileUrl = logsDirectory.appendingPathComponent(fileName)

        do {
            let fileAttributes = try fileManager.attributesOfItem(atPath: fileUrl.path)
            let fileSize = fileAttributes[FileAttributeKey.size] as? Int ?? 0
            return fileSize
        } catch {
            w("[Logger] Couldn't retrieve file size of \(fileUrl.path) due to \(error)")
            return 0
        }
    }

    /// Removes a specified number of bytes from a persisted log file
    static func truncateFile(_ fileName: String, for numberOfBytes: Int) -> Bool {
        guard let logsDirectory = self.logsDirectory else { return false }

        let fileUrl = logsDirectory.appendingPathComponent(fileName)

        do {
            let fileData = try Data(contentsOf: fileUrl)

            let truncatedData = truncateData(fileData, for: numberOfBytes)

            // Overwrite the current file with its truncated version
            try truncatedData.write(to: fileUrl)
            return true
        } catch {
            w("[Logger] Couldn't write truncated file to path \(fileUrl.path) due to \(error)")
            return false
        }
    }

    /// Removes a specified number of bytes from the given logs as data
    static func truncateData(_ data: Data, for numberOfBytes: Int) -> Data {
        guard data.bytes.count >= numberOfBytes, numberOfBytes >= 0 else { return data }

        var truncatedData = data
        truncatedData.removeSubrange(0..<numberOfBytes)
        return truncatedData
    }

    /// Deletes files recursively if the number of files exceeds the max number
    static func deleteOldestFileIfNeeded() {
        let currentLogFiles = self.persistedLogFiles()
        let numberOfFiles: Int = min(maxNumberOfFiles, maxNumberOfFilesUpperLimit)
        guard currentLogFiles.count > numberOfFiles, let fileNameToDelete = currentLogFiles.first else { return }
        deleteFile(with: fileNameToDelete)
        deleteOldestFileIfNeeded()
    }

    /// Deletes a persisted log file
    static func deleteFile(with name: String) {
        guard let debugBundleDirectory = logsDirectory else { return }

        do {
            let fileUrl = debugBundleDirectory.appendingPathComponent(name)
            try fileManager.removeItem(at: fileUrl)
        } catch {
            w("[Logger] Couldn't delete file in directory \(debugBundleDirectory.path) due to \(error)")
        }
    }

    /// Returns the names of the currently persisted log files sorted by date if available
    static func persistedLogFiles() -> [String] {
        guard let debugBundleDirectory = logsDirectory, fileManager.fileExists(atPath: debugBundleDirectory.path) else { return [] }

        do {
            let currentLogFiles = try fileManager.contentsOfDirectory(atPath: debugBundleDirectory.path)
            let sortedLogFiles = currentLogFiles.sorted { lhs, rhs -> Bool in
                guard let lhsDateTimestamp = lhs.matches(for: fileDateRegex)?.first,
                      let lhsDate = fileDateFormatter.date(from: lhsDateTimestamp),
                      let rhsDateTimestamp = rhs.matches(for: fileDateRegex)?.first,
                      let rhsDate = fileDateFormatter.date(from: rhsDateTimestamp) else { return false }

                return lhsDate < rhsDate
            }

            return sortedLogFiles
        } catch {
            w("[Logger] Couldn't sort files in directory \(debugBundleDirectory.path) due to \(error)")
            return []
        }
    }

    /// Returns the file url of a log file for a specific date
    static func fileUrl(for date: Date) -> URL? {
        let todaysFileName = fileName(for: date)
        guard let debugBundleDirectory = logsDirectory else { return nil }

        let fileURL = debugBundleDirectory.appendingPathComponent(todaysFileName).appendingPathExtension("txt")
        return fileURL
    }

    /// Returns the file name of logs for a specific date
    static func fileName(for date: Date) -> String {
        let dateString: String = fileDateFormatter.string(from: date)

        return "\(dateString)_pace_\(PACECloudSDK.shared.environment.rawValue)_logs"
    }

    /// The logs directory url
    static var logsDirectory: URL? = {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last else { return nil }
        let logsDirectory = documentsDirectory.appendingPathComponent(logsDirectoryName, isDirectory: true)

        return logsDirectory
    }()

    /// Sorts the persisted logs and returns the log directory url
    static func createExportLogs(completion: @escaping ((URL?) -> Void)) {
        mergeAndSortLogFiles {
            completion(logsDirectory)
        }
    }

    /// Merges new logs with the persisted logs and sorts them
    static func mergeAndSortLogFiles(withNewLogs newLogs: [String] = [], completion: (() -> Void)? = nil) {
        loggingQueue.async {
            guard !newLogs.isEmpty else {
                sortPersistedLogs(completion: completion)
                return
            }

            // [DateString: [LogEntries]]
            var newLogsItems: [String: [String]] = [:]

            // Extract date from every new log string (only use first occurence)
            newLogs.forEach { newLogString in
                guard let dateTimestamp = newLogString.matches(for: dateRegex).first,
                      let dateString = dateTimestamp.components(separatedBy: " ").first else { return }

                if let logEntries = newLogsItems[dateString] {
                    newLogsItems[dateString] = logEntries + [newLogString]
                } else {
                    newLogsItems[dateString] = [newLogString]
                }
            }

            // Append new logs to files or create new files
            newLogsItems.forEach { dateString, logEntries in
                guard let date = fileDateFormatter.date(from: dateString),
                      let fileUrl = fileUrl(for: date) else {
                    e("[Logger] Couldn't get file url.")
                    return
                }

                append(logs: logEntries, to: fileUrl)
            }

            deleteOldestFileIfNeeded()
            sortPersistedLogs(completion: completion)
        }
    }

    /// Sorts the persisted logs in all log files
    static func sortPersistedLogs(completion: (() -> Void)? = nil) {
        let logFileDates: [Date] = currentLogFilesDates()

        let dispatchGroup = DispatchGroup()

        logFileDates.forEach { _ in
            dispatchGroup.enter()
        }

        logFileDates.forEach { logFileDate in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let fileUrl = fileUrl(for: logFileDate) else {
                    dispatchGroup.leave()
                    return
                }

                let logs = persistedLogs(from: logFileDate)
                let sortedLogs = sortedLogs(logs)

                let logString = sortedLogs.reduce(into: "", { $0 += $1 + "\n" }) // Append a linebreak
                let logsData = Data(logString.utf8)

                write(data: logsData, to: fileUrl, replacesContent: true)
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: loggingQueue) {
            completion?()
        }
    }

    static func sortedLogs(_ logs: [String]) -> [String] {
        return logs.sorted(by: { lhs, rhs in
            guard let lhsDateTimestamp = lhs.matches(for: dateRegex).first,
                  let lhsDate = dateFormatter.date(from: lhsDateTimestamp),
                  let rhsDateTimestamp = rhs.matches(for: dateRegex).first,
                  let rhsDate = dateFormatter.date(from: rhsDateTimestamp) else { return false }
            return lhsDate < rhsDate
        })
    }

    /// Returns the persisted logs of a specific date
    static func persistedLogs(from date: Date) -> [String] {
        guard let path: String = fileUrl(for: date)?.path,
              fileManager.fileExists(atPath: path) else { return [] }

        do {
            let fileString: String = try String(contentsOfFile: path, encoding: .utf8)
            let logsOfFile: [String] = fileString.components(separatedBy: "\n").filter { !$0.isEmpty }

            return logsOfFile
        } catch {
            e("[Logger] Couldn't read file \(path)")
            return []
        }
    }

    /// Returns the persisted logs of all log files combined into a single string array
    static func persistedLogs() -> [String] {
        var logs: [String] = .init()
        let logFileDates: [Date] = currentLogFilesDates()

        logFileDates.forEach {
            logs.append(contentsOf: persistedLogs(from: $0))
        }

        return logs
    }

    /// Returns the dates of all log files
    static func currentLogFilesDates() -> [Date] {
        persistedLogFiles().compactMap {
            guard let dateString = $0.matches(for: fileDateRegex)?.first,
                  let date = fileDateFormatter.date(from: dateString) else { return nil }
            return date
        }
    }
}
