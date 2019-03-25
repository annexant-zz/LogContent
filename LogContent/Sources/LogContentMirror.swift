//
//  ContextLoggerAny.swift
//
//  Created by Andrey on 3/11/19.
//  Copyright © 2019 Mobidev. All rights reserved.
//

import Foundation

extension LogContent {

	typealias Properties = Dictionary<String, Any>
	typealias Keys = [String]
	typealias Value = (value:String, optional:Bool)

	private static func collectKeys(_ mirror:Mirror) -> Keys {
		var keys:Keys = []
		for case let (label?, _) in mirror.children {
//			print("label=\(label), value=\(v)")
			keys.append(label)
		}
		return keys
	}

	private static func unwrap(_ any:Any) -> Any? {

		let mi = Mirror(reflecting: any)
		if mi.displayStyle != .optional {
			return any
		}

		if mi.children.count == 0 { return nil }
		return mi.children.first!.value
	}


	private static func dictionaryFromMirror(_ mirror:Mirror, _ properties:[String]? = nil) -> Properties {

		var dic:Properties = [:]
		if let superMirror = mirror.superclassMirror {
			dic = dictionaryFromMirror(superMirror, properties)
		}

		let keys = properties ?? collectKeys(mirror)
		for case let (label?, value) in mirror.children {
			if keys.contains(label) {
//				let title = "\(label): \(type(of: value)) = \(value)"
				dic[label] = unwrap(value)
			}
		}
		return dic
	}

	private static func dictionary(_ obj: Any, _ properties:Array<String>? = nil) -> Properties {
		return dictionaryFromMirror(Mirror(reflecting: obj), properties)
	}

	static func objectInfo(_ obj: Any?, asDump: Bool = false) -> String {

		guard let obj = obj else {
			return "<nil>"
		}

		if asDump {
			return "\(dump(obj))"
		}

		let dic = dictionary(obj)
		var s = String(describing: type(of: obj)) + " {"

		for (key, value) in dic {
			s += "\n\t\(key): \(type(of: value)) = \(value)"
		}
		return s + "\n}"
	}
}



