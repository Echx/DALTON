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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
			mode = ColorBlindness.CBMode.RedDaltonize.rawValue
		}
		
		print(mode)
		
		NSUserDefaults.standardUserDefaults().setInteger(mode, forKey: "MODE")
    }

}
