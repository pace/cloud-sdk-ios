//
//  Logger.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import UIKit

open class Logger {
    open class var logTag: String { "[Logger]" }
    open class var moduleTag: String { "" }
    open class var maxNumberOfFiles: Int { 7 }
    open class var maxFileSize: Int { 10 * 1000 * 1000 } // in bytes, 10MB

    private static let maxNumberOfFilesUpperLimit: Int = 7
    private static let maxFileSizeUpperLimit: Int = 10 * 1000 * 1000

    private static var todaysLogs: [String] = []

    private static let loggingQueue = DispatchQueue(label: "pacecloudsdklogger", qos: .background)
    private static let dateFormatter: DateFormatter = .init(formatString: "yyyy-MM-dd HH:mm:ss.SSS")
    private static let fileDateFormatter: DateFormatter = .init(formatString: "yyyy-MM-dd")

    private static let fileManager: FileManager = FileManager.default
    private static let logsDirectoryName: String = "PaceLogs"

    enum Level: CustomStringConvertible {
        case verbose
        case info
        case warning
        case error

        var description: String {
            switch self {
            case .verbose:
                return "[V]"

            case .info:
                return "[I]"

            case .warning:
                return "[W]"

            case .error:
                return "[E]"
            }
        }
    }

    public static func v(_ message: String) {
        log(message: message, level: Level.verbose.description)
    }

    public static func i(_ message: String) {
        log(message: message, level: Level.info.description)
    }

    public static func w(_ message: String) {
        log(message: message, level: Level.warning.description)
    }

    public static func e(_ message: String) {
        log(message: message, level: Level.error.description)
    }

    public static func log(message: String, level: String) {
        loggingQueue.async {
            let log = "\(logTag)\(moduleTag)\(level) \(message)"

            NSLog(log)

            guard PACECloudSDK.shared.isLoggingEnabled else { return }

            let messageLogs: [String] = message.components(separatedBy: "\n")

            messageLogs.forEach {
                let singleMessagelog = "\(logTag)\(moduleTag)\(level) \($0)"
                let timestamp = dateFormatter.string(from: Date())
                let timestampLog = "\(timestamp) \(singleMessagelog)"
                todaysLogs.append(timestampLog)
            }
        }
    }

    public static func debugBundleDirectory(completion: @escaping ((URL?) -> Void)) {
        syncFiles()
        createExportLogs(completion: completion)
    }

    public static func exportLogs(completion: @escaping (([String]) -> Void)) {
        loggingQueue.async {
            completion((persistedLogs() + todaysLogs).filter { !$0.isEmpty })
        }
    }

    public static func importLogs(_ logs: [String], completion: (() -> Void)? = nil) {
        mergeAndSortLogFiles(withNewLogs: logs) {
            completion?()
        }
    }

    public static func deleteLogs(completion: (() -> Void)? = nil) {
        loggingQueue.async {
            todaysLogs = []
            let currentLogFiles = self.currentLogFiles()
            currentLogFiles.forEach {
                deleteFile(with: $0)
            }
            completion?()
        }
    }
}

internal extension Logger {
    static func optIn() {
        if PACECloudSDK.shared.isLoggingEnabled {
            createLogsDirectory()
            addDidEnterBackgroundObserver()
        }
    }

    static func optOut() {
        deleteLogs()
        removeDidEnterBackgroundObserver()
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

    static func syncFiles() {
        loggingQueue.async {
            guard let todaysFileUrl = fileUrl(for: Date()) else {
                w("[Logger] Couldn't sync files. Invalid file.")
                return
            }

            let logs = todaysLogs.reduce(into: "", { $0 += $1 + "\n" }) // Append a linebreak
            let todaysLogsData = Data(logs.utf8)
            let todaysLogsSize = todaysLogsData.bytes.count
            let fileSizeLimit: Int = min(maxFileSize, maxFileSizeUpperLimit)
            let bytesExcess = todaysLogsSize - fileSizeLimit
            let dataToAppend: Data

            if !fileManager.fileExists(atPath: todaysFileUrl.path) {
                // Create file with today's data
                // Delete oldest file if number of files exceeds the limit
                deleteOldestFileIfNeeded()
                fileManager.createFile(atPath: todaysFileUrl.path, contents: nil, attributes: nil)

                // Truncate the current data to be appended if necessary
                let truncatedData = truncateData(todaysLogsData, for: bytesExcess)
                dataToAppend = truncatedData
            } else {
                // Files available for truncating
                let isTruncatingSuccessful = truncateFilesIfNeeded(for: todaysLogsSize)

                if isTruncatingSuccessful {
                    // File already exists + no errors
                    // append data to file
                    dataToAppend = todaysLogsData
                } else {
                    // All files got deleted and currentLogData may exceed fileSize
                    // Truncate the current data to be appended if necessary
                    let truncatedData = truncateData(todaysLogsData, for: bytesExcess)
                    fileManager.createFile(atPath: todaysFileUrl.path, contents: nil, attributes: nil)
                    dataToAppend = truncatedData
                }
            }

            guard let fileHandle = FileHandle(forWritingAtPath: todaysFileUrl.path) else {
                w("[Logger] Couldn't sync files, couldn't create fileHandle.")
                return
            }

            fileHandle.seekToEndOfFile() // Go to the end of the file to append the data
            fileHandle.write(dataToAppend)
            fileHandle.closeFile()

            todaysLogs = [] // Reset logs
        }
    }

    static func truncateFilesIfNeeded(for bytesToAppend: Int) -> Bool {
        let currentFiles = currentLogFiles() // Already sorted by creation date
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

    static func truncateData(_ data: Data, for numberOfBytes: Int) -> Data {
        guard data.bytes.count >= numberOfBytes, numberOfBytes >= 0 else { return data }

        var truncatedData = data
        truncatedData.removeSubrange(0..<numberOfBytes)
        return truncatedData
    }

    static func deleteOldestFileIfNeeded() {
        let currentLogFiles = self.currentLogFiles().sorted()
        let numberOfFiles: Int = min(maxNumberOfFiles, maxNumberOfFilesUpperLimit)
        guard currentLogFiles.count > numberOfFiles, let fileNameToDelete = currentLogFiles.first else { return }
        deleteFile(with: fileNameToDelete)
        deleteOldestFileIfNeeded()
    }

    static func deleteFile(with name: String) {
        guard let debugBundleDirectory = logsDirectory else { return }

        do {
            let fileUrl = debugBundleDirectory.appendingPathComponent(name)
            try fileManager.removeItem(at: fileUrl)
        } catch {
            w("[Logger] Couldn't delete file in directory \(debugBundleDirectory.path) due to \(error)")
        }
    }

    // Returns the currently peristed log files sorted by creation date
    static func currentLogFiles() -> [String] {
        guard let debugBundleDirectory = logsDirectory else { return [] }

        do {
            let currentLogFiles = try fileManager.contentsOfDirectory(atPath: debugBundleDirectory.path)
            let sortedLogFiles = currentLogFiles.sorted { lhs, rhs -> Bool in
                let lhsPath = debugBundleDirectory.appendingPathComponent(lhs).path
                let rhsPath = debugBundleDirectory.appendingPathComponent(rhs).path

                guard let lhsCreatedAt = try? self.fileManager.attributesOfItem(atPath: lhsPath)[FileAttributeKey.creationDate] as? Date,
                      let rhsCreatedAt = try? self.fileManager.attributesOfItem(atPath: rhsPath)[FileAttributeKey.creationDate] as? Date else { return false }

                return lhsCreatedAt < rhsCreatedAt
            }

            return sortedLogFiles
        } catch {
            w("[Logger] Couldn't sort files in directory \(debugBundleDirectory.path) due to \(error)")
            return []
        }
    }

    static func fileUrl(for date: Date) -> URL? {
        let todaysFileName = fileName(for: date)
        guard let debugBundleDirectory = logsDirectory else { return nil }

        let fileURL = debugBundleDirectory.appendingPathComponent(todaysFileName).appendingPathExtension("txt")
        return fileURL
    }

    static func fileName(for date: Date) -> String {
        let dateString: String = fileDateFormatter.string(from: date)

        return "\(dateString)_pace_\(currentEnvironmentKey())_logs"
    }

    static var logsDirectory: URL? = {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last else { return nil }
        let logsDirectory = documentsDirectory.appendingPathComponent(logsDirectoryName, isDirectory: true)

        return logsDirectory
    }()

    static func currentEnvironmentKey() -> String {
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

    static func createExportLogs(completion: @escaping ((URL?) -> Void)) {
        mergeAndSortLogFiles {
            completion(logsDirectory)
        }
    }

    static func mergeAndSortLogFiles(withNewLogs newLogs: [String] = [], completion: (() -> Void)? = nil) {
        loggingQueue.async {
            guard let logsDir: URL = logsDirectory else {
                completion?()
                return
            }

            let numberOfFiles: Int = min(maxNumberOfFiles, maxNumberOfFilesUpperLimit)

            do {
                let items: [String] = try fileManager.contentsOfDirectory(atPath: logsDir.path)

                let lastMaximumDays: [Date] = (0..<numberOfFiles).map { Date().daysAgo($0) }

                lastMaximumDays.forEach { day in
                    var logs: [String] = []
                    let prefix: String = fileDateFormatter.string(from: day)
                    logs.append(contentsOf: newLogs.filter { $0.hasPrefix(prefix) })
                    let sameDayItems: [String] = items.filter { $0.hasPrefix(prefix) }

                    sameDayItems.forEach {
                        logs.append(contentsOf: persistedLogs(from: day))
                        do {
                            let path = logsDir.appendingPathComponent($0, isDirectory: false).path
                            try fileManager.removeItem(atPath: path)
                        } catch {
                            w("[Logger] Couldn't delete file \(logsDir.appendingPathComponent($0, isDirectory: false).path)")
                        }
                    }

                    if !logs.isEmpty {
                        logs.sort()

                        guard let path: String = fileUrl(for: day)?.path else { return }

                        if !fileManager.createFile(atPath: path, contents: nil, attributes: nil) {
                            w("[Logger] Couldn't create file \(path)")
                        }

                        guard let fileHandle: FileHandle = FileHandle(forWritingAtPath: path) else { return }

                        let logsString: String = logs.reduce(into: "", { $0 += $1 + "\n" }) // Append a linebreak
                        let data: Data = Data(logsString.utf8)
                        let logsSize = data.bytes.count
                        let fileSizeLimit: Int = min(maxFileSize, maxFileSizeUpperLimit)
                        let bytesExcess = logsSize - fileSizeLimit
                        let truncatedData = truncateData(data, for: bytesExcess)

                        fileHandle.seekToEndOfFile() // Go to the end of the file to append the data
                        fileHandle.write(truncatedData)
                        fileHandle.closeFile()
                    }
                }

                deleteOldestFileIfNeeded()
                completion?()
            } catch {
                deleteOldestFileIfNeeded()
                completion?()
            }
        }
    }

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

    static func persistedLogs() -> [String] {
        var logs: [String] = .init()
        let numberOfFiles: Int = min(maxNumberOfFiles, maxNumberOfFilesUpperLimit)
        let last7Days: [Date] = (0...numberOfFiles).map { Date().daysAgo($0) }

        last7Days.forEach {
            logs.append(contentsOf: persistedLogs(from: $0))
        }

        return logs
    }
}

internal extension Logger {
    @objc
    static func handleDidEnterBackground() {
        syncFiles()
    }
}
