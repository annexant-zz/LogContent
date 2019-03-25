# LogContent


To increase convenience of usage, add these lines somewhere in your code:

func logError(_ error:Error, _ file: String = #file,_ line: Int = #line, _ function: String = #function) {
	LogContent(error, file, line, function).logError()
}

func logError(_ message: String? = nil, _ error:Error? = nil, _ file: String = #file,_ line: Int = #line, _ function: String = #function) {
	LogContent(message, error, file, line, function).logError()
}

func logWarning(_ message: String? = nil, _ file: String = #file,_ line: Int = #line, _ function: String = #function) {
	LogContent(message, file, line, function).logWarning()
}

func logInfo(_ message: String? = nil, _ file: String = #file,_ line: Int = #line, _ function: String = #function) {
	LogContent(message, file, line, function).logInfo()
}

