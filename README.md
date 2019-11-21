# LogContent

A Powerfull and convenient logger 

1. Configure at application startup:

import LogContent

@inline(__always)
func setupLogContent() {
	LogContent.Config.storeToFile = false
	LogContent.Config.redirectErrorOutput = true
	LogContent.Config.redirectStdOutput = true
	LogContent.initialize()
}

2. To increase convenience of usage, add these lines somewhere in your code:

@inline(__always)
func logError(_ error:Error, _ file: String = #file,_ line: Int = #line, _ function: String = #function) {
	LogContent(error, file, line, function).logError()
}

@inline(__always)
func logError(_ message: String? = nil, _ error:Error? = nil, _ file: String = #file,_ line: Int = #line, _ function: String = #function) {
	LogContent(message, error, file, line, function).logError()
}

@inline(__always)
func logWarning(_ message: String? = nil, _ file: String = #file,_ line: Int = #line, _ function: String = #function) {
	LogContent(message, file, line, function).logWarning()
}

@inline(__always)
func logInfo(_ message: String? = nil, _ file: String = #file,_ line: Int = #line, _ function: String = #function) {
	LogContent(message, file, line, function).logInfo()	
}


