//
//  StringExtended.swift
//  HWModel
//
//  Created by Sergey Maximenko on 11/2/17.
//  Copyright © 2017 Andrey Ostroverkhiy. All rights reserved.
//

import UIKit


extension String {
	
	static var loremIpsum: String {
		get { return """
			Lorem ipsum dolor sit amet, sed ex laudem utroque meliore, at cum lucilius vituperata.
			Ludus mollis consulatu mei eu, esse vocent epicurei sed at. Ut cum recusabo prodesset.
			Ut cetero periculis sed, mundi senserit est ut. Nam ut sonet mandamus intellegebat,
			summo voluptaria vim ad.
		"""}
	}
	
	var isValidEmailAddres: Bool {
		let EMAIL_REGEX = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
		let predicate = NSPredicate(format: "SELF MATCHES %@", EMAIL_REGEX)
		return predicate.evaluate(with: lowercased())
	}

	var trimmed: String {
		return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}
	
	var ls: String {
		return Bundle.main.localizedString(forKey: self, value: self, table: nil)
	}

	static func unwrap(_ str: String?) -> String {
		return str ?? "<nil>"
	}

	func occurrences(of substring: String, options: CompareOptions = []) -> [Range<Index>] {
		var ranges = [Range<Index>]()
		var start = startIndex
		while let range = range(of: substring, options: options, range: start..<endIndex, locale: nil) {
			ranges.append(range)
			start = range.upperBound
		}
		return ranges
	}
	
	func contains(of substring: [String]) -> Bool {
		for ss in substring {
			if self.contains(ss) {
				return true
			}
		}
		return false
	}
	
	func containsIgnoreCase(of substring: [String]) -> Bool {
		let str = self.uppercased()
		for ss in substring {
			if str.contains(ss.uppercased()) {
				return true
			}
		}
		return false
	}
	
	func occurrencesOfCharacter(from set: CharacterSet, options: CompareOptions = []) -> [Range<Index>] {
		var ranges = [Range<Index>]()
		var start = startIndex
		while let range = rangeOfCharacter(from: set, options: options, range: start..<endIndex) {
			ranges.append(range)
			start = range.upperBound
		}
		return ranges
	}
	
	func attributedBy(font: UIFont?, color: UIColor?) -> NSMutableAttributedString {
		
		var attr = [NSAttributedString.Key:Any]()
		
		if let font = font {
			attr[NSAttributedString.Key.font] = font
		}
		
		if let color = color {
			attr[NSAttributedString.Key.foregroundColor] = color
		}
		
		let attrString = NSMutableAttributedString(string: self, attributes: attr)
		return attrString
		
	}

}

extension Array where Element == String {  //Just for remimnder purpose
	func joinedBy(_ separator: String) -> String {
		let result = self.joined(separator: separator)
		return result
	}
}


extension Optional where Wrapped == String {
	func unwrap() -> String {
		return self ?? "<nil>"
	}
}

extension String {

	public func index(offset: Int) -> String.Index {
		if offset == NSNotFound {
			return endIndex
		}
		else if offset < 0 {
			return index(endIndex, offsetBy: offset)
		}
		else {
			return index(startIndex, offsetBy: offset)
		}
	}

	public func substring(from: Int, to:Int) -> String {
		return String(self[index(offset:from)..<index(offset:to)])
	}

	public subscript(pos: Int) -> String {
		let pos = index(offset: pos)
		return String(self[pos..<index(pos, offsetBy: 1)])
	}

	public subscript(from: Int, to: Int) -> String {
		return substring(from: from, to: to)
	}

	public subscript(range: Range<Int>) -> String {
		return substring(from: range.lowerBound, to: range.upperBound)
	}

	public var mutable: NSMutableString {
		return NSMutableString(string: self)
	}

}
