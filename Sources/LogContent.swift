//
//  ContextLogger.swift
//  CarPlayer
//
//  Created by Andrey on 12/10/18.
//  Copyright © 2018 Mobidev. All rights reserved.
//

import Foundation

//typealias lc = LogContent
//typealias LC = LogContent
fileprivate typealias SELF = LogContent

public class LogContent {

	public class Config {

		enum DetalizationLevel {
			case none, short, medium, detail
		}

		enum TimestampPresentation {
			case none, relative, detail
		}

		static var logErrors = true
		static var logWarnings = true
		static var logInfos = true

		static var showThreadInfo: DetalizationLevel = .short
		static var showTimestamp: TimestampPresentation = .relative
		static var relativeTimestampFormat = "%.4f:"

		static var storeToFile = false
		static var fileEncoding = String.Encoding.utf8
		static var redirectErrorOutput = true
	}

	class ThreadInfo {

		let threadDescription: String
		let qos: QualityOfService
		let priority: Double

		init(_ thread: Thread = Thread.current) {
			self.threadDescription = thread.description
			self.qos = thread.qualityOfService
			self.priority = thread.threadPriority
		}

		var description: String {
			var str = ""

			switch LogContent.Config.showThreadInfo {
			case .none:
				break
			case .short:
				str = qosStr()
				let separator:Character = "|"
				let parts = threadDescription
					.split(separator: "{")[1]
					.split(separator: "}")[0]
					.replacingOccurrences(of: "name = ", with: "\(separator)")
					.split(separator: separator)
				if parts.count == 2 && parts[1] != "(null)" {
					str += (":" + parts[1])
				}
			case .medium, .detail: //TODO: .detail
				str = qosStr()
				let separator:Character = "|"
				let parts = threadDescription
					.split(separator: "{")[1]
					.split(separator: "}")[0]
					.replacingOccurrences(of: "name = ", with: "\(separator)")
					.split(separator: separator)
				if parts.count == 2 && parts[1] != "(null)" {
					str += (":" + parts[1])
				}
			}
			return str.count > 0 ? "(\(str)):" : str
		}

		func qosStr() -> String {
			switch self.qos {
			case .userInteractive:
				return "UI"
			case .userInitiated:
				return "USR"
			case .utility:
				return "UTL"
			case .background:
				return "BG"
			case .default:
				return "DEF"
			default:
				return "<Unknown>"
			}
		}
	}

	public enum LogLevel: Int {
		case ERROR = 0
		case WARNING
		case INFO
	}

	public static var marks = [
		"🔴 ",
		"🌕 ",
		"🔵 "
	]

	static var conditions = [
		Config.logErrors,
		Config.logWarnings,
		Config.logInfos
	]

	static var startedAt: Date =  {
		let result = Date()
		initialize()		// Auto Init
		return result
	}()

	static var file: FileHandle?

	var message: String?
	var error: Error?

	let file: String
	let line: Int
	let function: String
	let threadInfo: ThreadInfo
	let now = Date()


	func timestamp() -> String {
		switch LogContent.Config.showTimestamp {
		case .none:
			return ""
		case .relative:
			var interval = now.timeIntervalSince(LogContent.startedAt)
			if interval < 0 {
				interval = 0
			}
			let intervalStr = String(format: LogContent.Config.relativeTimestampFormat, interval)
			return intervalStr
		case .detail:
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .long
			dateFormatter.timeStyle = .long
//			dateFormatter.timeZone = timeZone
//			dateFormatter.locale = locale
			return dateFormatter.string(from: now) + ":"
		}
	}

	class func initialize() {
		let startUpMessage = "=== Logging started. ===\n"
		if Config.storeToFile {
			let startedAt = Date()
			let propertyName = "UIFileSharingEnabled"
			let values = Bundle.contentsOfFile(plistName: "Info.plist")

			guard
				let value = values[propertyName],
				let bool = value as? NSNumber,
				bool.boolValue
			else {
				print(marks[LogLevel.ERROR] + "Cannot start log file sharing! Add UIFileSharingEnabled=true to the Info.plist file")
				return
			}

			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .short
			dateFormatter.timeStyle = .short
			dateFormatter.locale = Locale(identifier: "ru_RU")

			let name = (values["CFBundleName"] as? String ?? "<>") + "-"
			let filename = (name + dateFormatter.string(from: startedAt) + ".log.txt")
				.replacingOccurrences(of: ", ", with: "-")
				.replacingOccurrences(of: "/", with: ":")

			print(marks[LogLevel.INFO] + "LogContext: sharing to file: \(filename) established")

			let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
			let path = [dir, filename].joined(separator: "/")

			do {
				try startUpMessage.write(toFile: path, atomically: true, encoding: Config.fileEncoding)
				let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: path))
				fileHandle.seekToEndOfFile()
				self.file = fileHandle
			} catch {
				print(marks[LogLevel.ERROR] + "Unable to create log file: \(error)")
				return
			}
			if Config.redirectErrorOutput {
				_ = freopen(path.cString(using: Config.fileEncoding), "a+", stderr)
				print(marks[LogLevel.INFO] + "LogContext: ERROR OUTPUT REDIRECTED! ")
			}
		}
		print(startUpMessage)
	}

	class func write(_ message: String) {
		if let fileHandle = SELF.file {
			let str = message + "\n"
			guard let data = str.data(using: Config.fileEncoding) else {
				print(marks[LogLevel.ERROR] + "ContextLogger:write:Unable to get data from string \"\(str)\"")
				return
			}
			fileHandle.write(data)
			fileHandle.synchronizeFile()
		}
	}

	class func contextStr(file: String, line: Int, function: String, threadInfo: ThreadInfo) -> String {
		var file = file
		if 	let end = file.range(of: ".", options:NSString.CompareOptions.backwards),
			let start = file.range(of: "/", options:NSString.CompareOptions.backwards)	{
			file = String(file[start.upperBound..<end.lowerBound])
		}

		var function = function
		if let brace = function.range(of: "(") {
			function = String(function[function.startIndex..<brace.lowerBound])
		}
		return "\(file):\(line):\(threadInfo.description)\(function)"
	}

	class func errorStr(_ message: String? = nil, _ error:Error? = nil) -> String? {
		guard let error = error else {
			return message
		}
		guard let message = message else {
			return error.localizedDescription
		}
		return message + ": " + error.localizedDescription
	}


	public init(_ message: String? = nil, _ error:Error? = nil, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
		self.message = message
		self.error = error
		self.file = file
		self.line = line
		self.function = function
		self.threadInfo = ThreadInfo(Thread.current)
	}

	public convenience init(_ message: String? = nil, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
				self.init(message, nil, file, line, function)
	}

	public convenience init(_ error:Error, _ file: String = #file, _ line: Int = #line, _ function: String = #function) {
		self.init(nil, error, file, line, function)
	}

	func log(_ msg: String) {
		print(msg)
		SELF.write(msg)
	}

	public func str(_ logLevel: LogLevel) -> String {
		let context = SELF.contextStr(file: file, line: line, function: function, threadInfo: threadInfo)
		let message = SELF.errorStr(self.message, error)


		let str = SELF.marks[logLevel] + timestamp() + context
		if let msg = message {
			return str + ":" + msg + "\n"
		}
		return str
	}

	func log(_ logLevel: LogLevel) {
		if SELF.conditions[logLevel] {
			let message = str(logLevel)
			log(message)
		}
	}
}

fileprivate extension Array {
	subscript<T:RawRepresentable>(index: T) -> Element where T.RawValue == Int {
		return self[index.rawValue]
	}
}

//	MARK: Public Logger methods

public extension LogContent {
	func logError() {
		log(.ERROR)
	}

	func logWarning() {
		log(.WARNING)
	}

	func logInfo() {
		log(.INFO)
	}

	func strError() -> String {
		return str(.ERROR)
	}

	func strWarning() -> String {
		return str(.WARNING)
	}

	func strInfo() -> String {
		return str(.INFO)
	}
}

public extension LogContent {

	static func objectInfo(_ obj: Any?, asDump: Bool = false, showNil: Bool = false, options: [String : Any?]? = nil) -> String {
		let nilStr = "<nil>"
		guard let obj = obj else {
			return nilStr
		}
		guard let li = obj as? ObjectInfo else {
			return SELF.objectInfo(obj, asDump: asDump)
		}
		return li.objectInfo(showNil: showNil, options: options)
	}
}

public extension LogContent {
	class func logError(_ error:Error, _ file: String = #file,_ line: Int = #line, _ function: String = #function) {
		LogContent(error, file, line, function).logError()
	}

	class func logError(_ message: String? = nil, _ error:Error? = nil, _ file: String = #file,_ line: Int = #line, _ function: String = #function) {
		LogContent(message, error, file, line, function).logError()
	}

	class func logWarning(_ message: String? = nil, _ file: String = #file,_ line: Int = #line, _ function: String = #function) {
		LogContent(message, file, line, function).logWarning()
	}

	class func logInfo(_ message: String? = nil, _ file: String = #file,_ line: Int = #line, _ function: String = #function) {
		LogContent(message, file, line, function).logInfo()
	}
}

#if ENABLE_GLOBAL_LOG_FUNCTIONS // Use Active Compilation Conditions (Target -> Build Settings)

public func logError(_ error:Error, _ file: String = #file,_ line: Int = #line, _ function: String = #function) {
	LogContent(error, file, line, function).logError()
}

public func logError(_ message: String? = nil, _ error:Error? = nil, _ file: String = #file,_ line: Int = #line, _ function: String = #function) {
	LogContent(message, error, file, line, function).logError()
}

public func logWarning(_ message: String? = nil, _ file: String = #file,_ line: Int = #line, _ function: String = #function) {
	LogContent(message, file, line, function).logWarning()
}

public func logInfo(_ message: String? = nil, _ file: String = #file,_ line: Int = #line, _ function: String = #function) {
	LogContent(message, file, line, function).logInfo()
}

#endif


