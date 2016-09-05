//
//  HomeViewController.swift
//  Dalton
//
//  Created by Jinghan Wang on 4/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import DaltonFramework

class HomeViewController: ViewController {
	
	@IBOutlet var colorModeSegment: UISegmentedControl!
	@IBOutlet var simulationModeSegment: UISegmentedControl!
	
	private let seguePerformDelay = 0.5
	private var willPresentController = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func presentColorReaderController() {
		if !willPresentController {
			self.performSelector(#selector(presentControllerWithSegueIdentifier), withObject: "ColorReaderSegue", afterDelay: seguePerformDelay)
			willPresentController = true
		}
	}
	
	@IBAction func presentLiveFilterController() {
		if !willPresentController {
			var segueIdentifier = ""
			
			let presentationMode = SettingsManager.getPresentationType()
			if presentationMode == .Video {
				segueIdentifier = "VideoSegue"
			} else if presentationMode == .AugmentedReality {
				segueIdentifier = "ARSegue"
			} else {
				print("Invalid presentation type! Abort.")
				return
			}
			
			self.performSelector(#selector(presentControllerWithSegueIdentifier), withObject: segueIdentifier, afterDelay: seguePerformDelay)
			willPresentController = true
		}
	}
	
	@IBAction func presentSettingsViewController() {
		if !willPresentController {
			self.performSelector(#selector(presentControllerWithSegueIdentifier), withObject: "SettingsSegue", afterDelay: seguePerformDelay)
			willPresentController = true
		}
	}
	
	func presentControllerWithSegueIdentifier(identifier: String) {
		self.performSegueWithIdentifier(identifier, sender: self)
		self.willPresentController = false
	}
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		var mode = ColorBlindness.CBMode.None.rawValue
		let deficiencyType = SettingsManager.getDeficiencyType()
		let outputType = SettingsManager.getOutputType()
		
		if outputType == .Simulation {
			switch deficiencyType {
			case .Red:
				mode = ColorBlindness.CBMode.Red.rawValue
			case .Green:
				mode = ColorBlindness.CBMode.Green.rawValue
			default:
				mode = ColorBlindness.CBMode.None.rawValue
			}
			
		} else {
			switch deficiencyType {
			case .Red:
				mode = ColorBlindness.CBMode.RedDaltonize.rawValue
			case .Green:
				mode = ColorBlindness.CBMode.GreenDaltonize.rawValue
			default:
				mode = ColorBlindness.CBMode.None.rawValue
			}
		}
		
		NSUserDefaults.standardUserDefaults().setInteger(mode, forKey: "MODE")
    }

}
