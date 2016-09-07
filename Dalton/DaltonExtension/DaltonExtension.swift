//
//  DaltonExtension.swift
//  DaltonExtensionViewController
//
//  Created by Lei Mingyu on 3/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import DaltonFramework

class DaltonExtensionViewController: UIViewController, PHContentEditingController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var input: PHContentEditingInput?
    var displayedImage: UIImage?
    var imageOrientation: Int32?
    var currentMode = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchMode(sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 1:
			currentMode = ColorBlindness.CBMode.Red.rawValue
		case 2:
			currentMode = ColorBlindness.CBMode.Green.rawValue
		case 3:
			currentMode = ColorBlindness.CBMode.RedDaltonize.rawValue
		case 4:
			currentMode = ColorBlindness.CBMode.GreenDaltonize.rawValue
		default:
			currentMode = ColorBlindness.CBMode.None.rawValue
		}
		
        if displayedImage != nil {
            imageView.image = performFilter(displayedImage!)
        }
    }
    
    func performFilter(inputImage: UIImage) -> UIImage? {
        var cimage: CIImage
        cimage = CIImage(image: inputImage)!
        
        let filter = CIFilter(name: "CIColorMatrix")!
        filter.setDefaults()
        filter.setValue(cimage, forKey: "inputImage")
        ColorBlindness.applyCBMatrix(filter, mode: currentMode)
        
        let ciFilteredImage = filter.outputImage!
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciFilteredImage,
                                            fromRect: ciFilteredImage.extent)
        let resultImage = UIImage(CGImage: cgImage)
        
        return resultImage
    }
    
    
    
    // MARK: - PHContentEditingController
    
    func canHandleAdjustmentData(adjustmentData: PHAdjustmentData?) -> Bool {
        // Inspect the adjustmentData to determine whether your extension can work with past edits.
        // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
        return false
    }
    
    func startContentEditingWithInput(contentEditingInput: PHContentEditingInput?, placeholderImage: UIImage) {
        // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
        // If you returned true from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
        // If you returned false, the contentEditingInput has past edits "baked in".
        input = contentEditingInput
        
        if input != nil {
            displayedImage = input!.displaySizeImage
            imageOrientation = input!.fullSizeImageOrientation
			imageView.image = performFilter(displayedImage!)
        }
    }
    
    func finishContentEditingWithCompletionHandler(completionHandler: ((PHContentEditingOutput!) -> Void)!) {
        // Update UI to reflect that editing has finished and output is being rendered.
        
        // Render and provide output on a background queue.
        dispatch_async(dispatch_get_global_queue(CLong(DISPATCH_QUEUE_PRIORITY_DEFAULT), 0)) {
            // Create editing output from the editing input.
            let output = PHContentEditingOutput(contentEditingInput: self.input!)
            
            // Provide new adjustments and render output to given location.
            // output.adjustmentData = <#new adjustment data#>
            // let renderedJPEGData = <#output JPEG#>
            // renderedJPEGData.writeToURL(output.renderedContentURL, atomically: true)
            
            // Call completion handler to commit edit to Photos.
            completionHandler?(output)
            
            // Clean up temporary files, etc.
        }
    }
    
    var shouldShowCancelConfirmation: Bool {
        // Determines whether a confirmation to discard changes should be shown to the user on cancel.
        // (Typically, this should be "true" if there are any unsaved changes.)
        return false
    }
    
    func cancelContentEditing() {
        // Clean up temporary files, etc.
        // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
    }
    
}
