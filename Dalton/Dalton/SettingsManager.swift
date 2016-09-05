//
//  SettingsManager.swift
//  Dalton
//
//  Created by Jinghan Wang on 3/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import DaltonFramework

class SettingsManager: NSObject {
	class func registerUserDefaults() {
		let userDefaults = NSUserDefaults.standardUserDefaults()
		
		if userDefaults.objectForKey("pupil_distance") == nil {
			userDefaults.setDouble(150, forKey: "pupil_distance")
		}
		
		if userDefaults.objectForKey("deficiency_type") == nil {
			userDefaults.setInteger(DeficiencyType.None.rawValue, forKey: "deficiency_type")
		}
		
		if userDefaults.objectForKey("output_type") == nil {
			userDefaults.setInteger(OutputType.Correction.rawValue, forKey: "output_type")
		}
		
		if userDefaults.objectForKey("presentation_type") == nil {
			userDefaults.setInteger(PresentationType.Video.rawValue, forKey: "presentation_type")
		}
	}
	
	class func getPupilDistance() -> Double {
		return NSUserDefaults.standardUserDefaults().doubleForKey("pupil_distance")
	}
	
	class func setPupilDistance(distance: Double){
		NSUserDefaults.standardUserDefaults().setDouble(distance, forKey: "pupil_distance")
	}
	
	//----------
	
	class func getDeficiencyType() -> DeficiencyType {
		let result = NSUserDefaults.standardUserDefaults().integerForKey("deficiency_type")
		return DeficiencyType(rawValue: result)!
	}
	
	class func setDeficiencyType(type: DeficiencyType) {
		NSUserDefaults.standardUserDefaults().setInteger(type.rawValue, forKey: "deficiency_type")
	}
	
	//----------
	
	class func getOutputType() -> OutputType {
		let result = NSUserDefaults.standardUserDefaults().integerForKey("output_type")
		return OutputType(rawValue: result)!
	}
	
	class func setOutputType(type: OutputType) {
		NSUserDefaults.standardUserDefaults().setInteger(type.rawValue, forKey: "output_type")
	}
	
	//----------
	
	class func getPresentationType() -> PresentationType {
		let result = NSUserDefaults.standardUserDefaults().integerForKey("presentation_type")
		return PresentationType(rawValue: result)!
	}
	
	class func setPresentationType(type: PresentationType) {
		NSUserDefaults.standardUserDefaults().setInteger(type.rawValue, forKey: "presentation_type")
	}
	
	
	enum DeficiencyType: Int {
		case None = 0, Red, Green
	}
	
	enum OutputType: Int {
		case Simulation = 0, Correction
	}
	
	enum PresentationType: Int {
		case Video = 0, AugmentedReality
	}
}
