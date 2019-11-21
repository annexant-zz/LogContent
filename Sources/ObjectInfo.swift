//
//  LogObjectStr.swift
//
//  Created by Andrey on 1/24/19.
//  Copyright © 2019 Mobidev. All rights reserved.
//

import MediaPlayer

public protocol ObjectInfo {
	var objectInfo: String {get}
	var objectInfoWithType: String {get}

	var objectInfoOptions: [String : Any?] {get}
	func objectInfo(showNil: Bool, options: [String : Any?]?) -> String
}

public extension ObjectInfo {

	var objectInfo: String {
		return objectInfo(showNil: false)
	}

	var objectInfoWithType: String {
		return "\(type(of: self)): { " + objectInfo + " }"
	}

	var objectInfoOptions: [String : Any?] {
		return [:]
	}

	func objectInfo(showNil: Bool, options: [String : Any?]? = nil) -> String {
		var str = [String]()
		self.objectInfoOptions.forEach { (key: String, value: Any?) in
			if let value = value {
				str.append("\(key):\(value)")
			} else if showNil {
				str.append("\(key):<nil>")
			}
		}
		return str.sorted().joined(separator: "\n - ")
	}

}

extension IndexPath: ObjectInfo {
	public var objectInfo: String {
		let path = self.map { return $0 }
		return "\(path)"
	}
}

extension Data: ObjectInfo {
	public var objectInfo: String {
		var result = "["
		for b in self {
			let separator = result.count > 1 ? "," : ""
			let str = String(b, radix: 16).uppercased()
			let prefix = str.count == 1 ? "0" : ""
			result += (separator + prefix + str)
		}
		result += "]"
		return result
	}
}
