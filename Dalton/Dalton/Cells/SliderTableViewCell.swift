//
//  SliderTableViewCell.swift
//  Dalton
//
//  Created by Jinghan Wang on 6/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class SliderTableViewCell: TableViewCell {

	@IBOutlet var slider: UISlider!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var valueLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func setSliderValue(value: Double) {
		self.slider.setValue(Float(value), animated: true)
		self.sliderValueDidChange(slider)
	}
	
	@IBAction func sliderValueDidChange(slider: UISlider) {
		self.valueLabel.text = "\(Int(slider.value))"
		SettingsManager.setPupilDistance(Double(slider.value))
	}
}