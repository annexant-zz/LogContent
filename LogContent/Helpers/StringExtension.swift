//
//  StringExtended.swift
//  HWModel
//
//  Created by Sergey Maximenko on 11/2/17.
//  Copyright © 2017 Andrey Ostroverkhiy. All rights reserved.
//

import UIKit

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

extension Optional where Wrapped == String {
	func unwrap() -> String {
		return self ?? "<nil>"
	}
}
