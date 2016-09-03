//
//  ViewController.swift
//  Dalton
//
//  Created by Lei Mingyu on 3/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	@IBAction func dismiss() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

