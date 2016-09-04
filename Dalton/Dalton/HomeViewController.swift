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
	
	@IBAction func presentVideoController() {
		if !willPresentController {
			self.performSelector(#selector(presentControllerWithSegueIdentifier), withObject: "VideoSegue", afterDelay: seguePerformDelay)
			willPresentController = true
		}
	}
	
	@IBAction func presentVRController() {
		if !willPresentController {
			self.performSelector(#selector(presentControllerWithSegueIdentifier), withObject: "VRSegue", afterDelay: seguePerformDelay)
			willPresentController = true
		}
	}
	
	@IBAction func presentColorReaderController() {
		if !willPresentController {
			self.performSelector(#selector(presentControllerWithSegueIdentifier), withObject: "ColorReaderSegue", afterDelay: seguePerformDelay)
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
		
		if simulationModeSegment.selectedSegmentIndex == 0 {
			switch colorModeSegment.selectedSegmentIndex {
			case 1:
				mode = ColorBlindness.CBMode.Red.rawValue
			case 2:
				mode = ColorBlindness.CBMode.Green.rawValue
			default:
				mode = ColorBlindness.CBMode.None.rawValue
			}
			
		} else {
			switch colorModeSegment.selectedSegmentIndex {
			case 1:
				mode = ColorBlindness.CBMode.RedDaltonize.rawValue
			case 2:
				mode = ColorBlindness.CBMode.GreenDaltonize.rawValue
			default:
				mode = ColorBlindness.CBMode.None.rawValue
			}
		}
		
		NSUserDefaults.standardUserDefaults().setInteger(mode, forKey: "MODE")
    }

}
