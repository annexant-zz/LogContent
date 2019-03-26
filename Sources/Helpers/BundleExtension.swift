//
//  ReadPlistExtension.swift
//  CarPlayer
//
//  Created by Andrey on 2/19/19.
//  Copyright © 2019 Mobidev. All rights reserved.
//

import Foundation

public extension Bundle {

	/**

	Gets the contents of the specified plist file.

	Usage:
	let values = NSBundle.contentsOfFile("Settings.plist")
	print(values["MyString1"]) // My string value 1.

	- parameter plistName: property list where defaults are declared
	- parameter bundle: bundle where defaults reside

	- returns: dictionary of values
	*/
	static func contentsOfFile(plistName: String, bundle: Bundle = Bundle.main) -> [String : AnyObject] {
		let fileParts = plistName.components(separatedBy: ".")

		guard
			fileParts.count == 2,
			let resourcePath = bundle.path(forResource: fileParts[0], ofType: fileParts[1]),
			let contents = NSDictionary(contentsOfFile: resourcePath) as? [String : AnyObject]
		else {
			return [:]
		}
		return contents
	}

	/**
	Gets the contents of the specified bundle URL.

	- parameter bundleURL: bundle URL where defaults reside
	- parameter plistName: property list where defaults are declared

	- returns: dictionary of values
	*/
	static func contentsOfFile(bundleURL: URL,
									  plistName: String = "Root.plist") -> [String : AnyObject] {
		// Extract plist file from bundle
		let url = bundleURL.appendingPathComponent(plistName)
		guard
			let contents = NSDictionary(contentsOf: url)
		else {
			return [:]
		}

		// Collect default values
		guard let preferences = contents.value(forKey: "PreferenceSpecifiers") as? [String: AnyObject]
			else { return [:] }

		return preferences
	}

	/**
	Gets the contents of the specified bundle name.

	- parameter bundleName: bundle name where defaults reside
	- parameter plistName: property list where defaults are declared

	- returns: dictionary of values
	*/
	static func contentsOfFile(bundleName: String,
									  plistName: String = "Root.plist") -> [String : AnyObject] {
		guard let bundleURL = Bundle.main.url(forResource: bundleName, withExtension: "bundle")
			else { return [:] }

		return contentsOfFile(bundleURL: bundleURL, plistName: plistName)
	}

	/**
	Gets the contents of the specified bundle.

	- parameter bundle: bundle where defaults reside
	- parameter bundleName: bundle name where defaults reside
	- parameter plistName: property list where defaults are declared

	- returns: dictionary of values
	*/
	static func contentsOfFile(bundle: Bundle,
									  bundleName: String = "Settings",
									  plistName: String = "Root.plist") -> [String : AnyObject] {

		guard
			let bundleURL = bundle.url(forResource: bundleName, withExtension: "bundle")
		else {
				return [:]
		}
		return contentsOfFile(bundleURL: bundleURL, plistName: plistName)
	}

}
