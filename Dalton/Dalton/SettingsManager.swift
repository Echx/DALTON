//
//  SettingsManager.swift
//  Dalton
//
//  Created by Jinghan Wang on 3/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class SettingsManager: NSObject {
	class func registerDefaults() {
		if let settingsBundle = NSBundle.mainBundle().pathForResource("Settings", ofType: "bundle") {
			let settings = NSDictionary(contentsOfFile: settingsBundle.stringByAppendingString("/Root.plist"))!
			let preferences = settings.objectForKey("PreferenceSpecifiers") as! NSArray
			
			var defaultsToRegister = [String: AnyObject]()
			
			for preferenceSpecification in preferences {
				if let key = preferenceSpecification.objectForKey("Key") {
					defaultsToRegister[key as! String] = preferenceSpecification.objectForKey("DefaultValue")!
				}
			}
			
			NSUserDefaults.standardUserDefaults().registerDefaults(defaultsToRegister)
		} else {
			print("Could not find Settings.bundle")
		}
	}
	
	class func getPupilDistance() -> CGFloat {
		return CGFloat(NSUserDefaults.standardUserDefaults().doubleForKey("pupil_distance"))
	}
}
