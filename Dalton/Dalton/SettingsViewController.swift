//
//  SettingsViewController.swift
//  Dalton
//
//  Created by Jinghan Wang on 6/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit

class SettingsViewController: ViewController {

	@IBOutlet var tableView: UITableView!
	
	struct SectionIndex {
		static let DeficiencyType = 0
		static let OutputMode = 1
		static let PresentationMode = 2
		static let ARSettings = 3
		static let count = 4
	}
	
	struct RowIndexForSectionDeficiencyType {
		static let Normal = 0
		static let RedColorBlind = 1
		static let GreenColorBlind = 2
		static let count = 3
	}
	
	struct RowIndexForSectionOutputMode {
		static let Simulation = 0
		static let Correction = 1
		static let count = 2
	}
	
	struct RowIndexForSectionPresentationMode {
		static let Video = 0
		static let AugmentedReality = 1
		static let count = 2
	}
	
	struct RowIndexForSectionARSettings {
		static let PupilDistance = 0
		static let count = 1
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SettingsViewController: UITableViewDelegate {
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		let section = indexPath.section
		let row = indexPath.row
		
		switch section {
		case SectionIndex.DeficiencyType:
			switch row {
			case RowIndexForSectionDeficiencyType.Normal:
				SettingsManager.setDeficiencyType(SettingsManager.DeficiencyType.None)
			case RowIndexForSectionDeficiencyType.RedColorBlind:
				SettingsManager.setDeficiencyType(SettingsManager.DeficiencyType.Red)
			case RowIndexForSectionDeficiencyType.GreenColorBlind:
				SettingsManager.setDeficiencyType(SettingsManager.DeficiencyType.Green)
			default:
				print("Invalid Row")
			}
			
		case SectionIndex.OutputMode:
			switch row {
			case RowIndexForSectionOutputMode.Simulation:
				SettingsManager.setOutputType(SettingsManager.OutputType.Simulation)
			case RowIndexForSectionOutputMode.Correction:
				SettingsManager.setOutputType(SettingsManager.OutputType.Correction)
			default:
				print("Invalid Row")
			}
			
		case SectionIndex.PresentationMode:
			switch row {
			case RowIndexForSectionPresentationMode.Video:
				SettingsManager.setPresentationType(SettingsManager.PresentationType.Video)
			case RowIndexForSectionPresentationMode.AugmentedReality:
				SettingsManager.setPresentationType(SettingsManager.PresentationType.AugmentedReality)
			default:
				print("Invalid Row")
			}
			
			
		default:
			print("Invalid Section")
		}
		
		tableView.reloadSections(NSIndexSet(index: section), withRowAnimation: .None)
	}
}

extension SettingsViewController: UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return SectionIndex.count
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
			case SectionIndex.DeficiencyType:
				return RowIndexForSectionDeficiencyType.count
			
			case SectionIndex.OutputMode:
				return RowIndexForSectionOutputMode.count
			
			case SectionIndex.PresentationMode:
				return RowIndexForSectionPresentationMode.count
			
			case SectionIndex.ARSettings:
				return RowIndexForSectionARSettings.count
			
			default:
				return 0
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let tableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
		
		let section = indexPath.section
		let row = indexPath.row
		var checked = false
		var selectable = true
		
		switch section {
			case SectionIndex.DeficiencyType:
				switch row {
					case RowIndexForSectionDeficiencyType.Normal:
						tableViewCell.textLabel?.text = "Normal"
						checked = SettingsManager.getDeficiencyType() == .None
					
					case RowIndexForSectionDeficiencyType.RedColorBlind:
						tableViewCell.textLabel?.text = "Red Color Blind"
						checked = SettingsManager.getDeficiencyType() == .Red
						
					case RowIndexForSectionDeficiencyType.GreenColorBlind:
						tableViewCell.textLabel?.text = "Green Color Blind"
						checked = SettingsManager.getDeficiencyType() == .Green
					
					default:
						print("Invalid Row")
				}
				
			case SectionIndex.OutputMode:
				switch row {
					case RowIndexForSectionOutputMode.Simulation:
						tableViewCell.textLabel?.text = "Simulation"
						checked = SettingsManager.getOutputType() == .Simulation
					
					case RowIndexForSectionOutputMode.Correction:
						tableViewCell.textLabel?.text = "Correction"
						checked = SettingsManager.getOutputType() == .Correction
					
					default:
						print("Invalid Row")
				}
			
			case SectionIndex.PresentationMode:
				switch row {
					case RowIndexForSectionPresentationMode.Video:
						tableViewCell.textLabel?.text = "Live Video"
						checked = SettingsManager.getPresentationType() == .Video
					
					case RowIndexForSectionPresentationMode.AugmentedReality:
						tableViewCell.textLabel?.text = "Augmented Reality"
						checked = SettingsManager.getPresentationType() == .AugmentedReality
					
					default:
						print("Invalid Row")
				}
			
			case SectionIndex.ARSettings:
				tableViewCell.textLabel?.text = "Some Slider Here"
				selectable = false
			
			default:
				print("Invalid Section")
		}
		
		tableViewCell.accessoryType = checked ? .Checkmark : .None
		tableViewCell.selectionStyle = selectable ? .Default : .None
		
		return tableViewCell
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case SectionIndex.DeficiencyType:
			return "Deficiency Type"
			
		case SectionIndex.OutputMode:
			return "Output Mode"
			
		case SectionIndex.PresentationMode:
			return "Presentation Mode"
			
		case SectionIndex.ARSettings:
			return "Augmented Reality Settings"
			
		default:
			return ""
		}
	}
}
