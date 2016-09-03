//
//  PhotoEditingViewController.swift
//  DaltonColorCorrectExtension
//
//  Created by Lei Mingyu on 3/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class PhotoEditingViewController: UIViewController, PHContentEditingController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var input: PHContentEditingInput?
    var displayedImage: UIImage?
    var imageOrientation: Int32?
    var currentMode = 0
    enum CBMode: Int {
        case None = 0, Red, Green, Blue, Blind
    }
    var colorMatrices: [Int: Matrix] = [
        CBMode.None.rawValue: Matrix(matrix: [[1, 0, 0], [0, 1, 0], [0, 0, 1]]),
        CBMode.Red.rawValue: Matrix(matrix: [[0, 2.02344, -2.52581], [0, 1, 0], [0, 0, 1]]),
        CBMode.Green.rawValue: Matrix(matrix: [[1, 0, 0], [0.494207, 0, 1.24827], [0, 0, 1]]),
        CBMode.Blue.rawValue: Matrix(matrix: [[1, 0, 0], [0, 1, 0], [-0.395913, 0.801109, 1]]),
        CBMode.Blind.rawValue: Matrix(matrix: [[0, 0, 0], [0, 0, 0], [0, 0, 0]])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func viewRed(sender: AnyObject) {
        currentMode = sender.tag
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
        applyCBMatrix(filter)
        
        let ciFilteredImage = filter.outputImage!
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(ciFilteredImage,
                                            fromRect: ciFilteredImage.extent)
        let resultImage = UIImage(CGImage: cgImage)
        
        return resultImage
    }
    
    // MARK: - Color Blindness Matrix
    func getCBMatrix(colorMatrix: Matrix) -> Matrix {
        var matrices = [Matrix]()
        let LMSMatrix = Matrix(matrix: [[17.8824, 43.5161, 4.11935],
            [3.45565, 27.1554, 3.86714],
            [0.0299566, 0.184309, 1.46709]])
        
        matrices.insert(LMSMatrix, atIndex: 0)
        matrices.insert(colorMatrix, atIndex: 0)
        let RGBMatrix = Matrix(matrix: [[0.080944, -0.130504, 0.116721],
            [-0.0102485, 0.0540194, -0.113615],
            [-0.000365294, -0.00412163, 0.693513]])
        
        return matrices.reduce(RGBMatrix, combine: {($0 * $1)!})
    }
    
    func applyCBMatrix(filter: CIFilter) {
        let colorMatrix = colorMatrices[currentMode]
        let CBMatrix = getCBMatrix(colorMatrix!)
        let rVector = CIVector(x: CGFloat(CBMatrix.matrix[0][0]),
                               y: CGFloat(CBMatrix.matrix[0][1]),
                               z: CGFloat(CBMatrix.matrix[0][2]),
                               w: 0)
        let gVector = CIVector(x: CGFloat(CBMatrix.matrix[1][0]),
                               y: CGFloat(CBMatrix.matrix[1][1]),
                               z: CGFloat(CBMatrix.matrix[1][2]),
                               w: 0)
        let bVector = CIVector(x: CGFloat(CBMatrix.matrix[2][0]),
                               y: CGFloat(CBMatrix.matrix[2][1]),
                               z: CGFloat(CBMatrix.matrix[2][2]),
                               w: 0)
        filter.setValue(rVector, forKey: "inputRVector")
        filter.setValue(gVector, forKey: "inputGVector")
        filter.setValue(bVector, forKey: "inputBVector")
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
            imageView.image = displayedImage
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
