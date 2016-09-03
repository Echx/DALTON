//
//  RealTimeVideoFilterViewController.swift
//  Dalton
//
//  Created by Jinghan Wang on 3/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage
import GLKit


class RealTimeVideoFilterViewController: UIViewController {

	@IBOutlet var videoPreviewViewLeft: GLKView!
	@IBOutlet var videoPreviewViewRight: GLKView!
	
	
	var ciContext: CIContext!
	var eaglContext: EAGLContext!
	var videoPreviewViewBoundsLeft: CGRect!
	var videoPreviewViewBoundsRight: CGRect!
	
	var videoDevice: AVCaptureDevice!
	var captureSession: AVCaptureSession!
	var captureSessionQueue: dispatch_queue_t!
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.backgroundColor = UIColor.clearColor()
		self.eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
		
		
		self.videoPreviewViewLeft.context = self.eaglContext
		self.videoPreviewViewLeft?.enableSetNeedsDisplay = false
		
		self.videoPreviewViewLeft.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
		self.videoPreviewViewLeft.bindDrawable()
		self.videoPreviewViewBoundsLeft = CGRectMake(0, 0, CGFloat(self.videoPreviewViewLeft.drawableWidth), CGFloat(self.videoPreviewViewLeft.drawableHeight))
		
		self.videoPreviewViewRight.context = self.eaglContext
		self.videoPreviewViewRight?.enableSetNeedsDisplay = false
		
		self.videoPreviewViewRight.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
		self.videoPreviewViewRight.bindDrawable()
		
		self.videoPreviewViewBoundsRight = CGRectMake(0, 0, CGFloat(self.videoPreviewViewRight.drawableWidth), CGFloat(self.videoPreviewViewRight.drawableHeight))
		
		
		
		
		
		
		self.ciContext = CIContext(EAGLContext: self.eaglContext, options: [kCIContextWorkingColorSpace: NSNull()])
		
		if AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count > 0 {
			self.start()
		} else {
			print("No device with AVMediaTypeVideo")
		}
		
        // Do any additional setup after loading the view.
    }
	
	func start() {
		let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
		
		let position = AVCaptureDevicePosition.Back
		
		for device in videoDevices {
			if device.position == position {
				self.videoDevice = device as! AVCaptureDevice
			}
		}
		
		let videoDeviceInput = try? AVCaptureDeviceInput(device: self.videoDevice)
		
		if videoDeviceInput == nil {
			print("Cannot add video data output")
			self.captureSession = nil
			return
		}
		
		
		let preset = AVCaptureSessionPresetHigh
		
		if !self.videoDevice.supportsAVCaptureSessionPreset(preset) {
			print("Capture session preset not supported by video device: \(preset)")
			return
		}
		
		
		self.captureSession = AVCaptureSession()
		self.captureSession.sessionPreset = preset
		
		let videoDataOutput = AVCaptureVideoDataOutput()
		videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : NSNumber(integer:Int(kCVPixelFormatType_32BGRA))]
		
		self.captureSessionQueue = dispatch_queue_create("capture_session_queue", nil)
		videoDataOutput.setSampleBufferDelegate(self, queue: self.captureSessionQueue)
		videoDataOutput.alwaysDiscardsLateVideoFrames = true
		
		self.captureSession.beginConfiguration()
		if !self.captureSession.canAddOutput(videoDataOutput) {
			print("Cannot add video data output")
			self.captureSession = nil
			return
		}
		
		self.captureSession.addInput(videoDeviceInput)
		self.captureSession.addOutput(videoDataOutput)
		self.captureSession.commitConfiguration()
		
		self.captureSession.startRunning()
		
		print("Capture Session Start Running...")
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


extension RealTimeVideoFilterViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
	func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
		
		let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
		let sourceImage = CIImage(CVPixelBuffer: imageBuffer as CVPixelBufferRef)
		let sourceExtent = sourceImage.extent
		
		let currentFilter = "CIColorMatrix"
		
		let filter = CIFilter(name: currentFilter)!
		filter.setDefaults()
		filter.setValue(sourceImage, forKey: "inputImage")
		
		switch currentFilter {
		case "CIColorMatrix":
			filter.setValue(CIVector(x: 0, y: 1, z: 0, w:0), forKey: "inputRVector")
			
		default:
			break
		}
		
		let filteredImage = filter.outputImage
		
		let sourceAspect = sourceExtent.size.width / sourceExtent.size.height
		
		
		glClearColor(0.5, 0.5, 0.5, 1.0);
		glClear(GLenum(GL_COLOR_BUFFER_BIT));
		
		// set the blend mode to "source over" so that CI will use that
		glEnable(GLenum(GL_BLEND));
		glBlendFunc(GLenum(GL_ONE), GLenum(GL_ONE_MINUS_SRC_ALPHA));
		
		
		//left
		
		let previewAspectLeft = videoPreviewViewBoundsLeft.size.width  / videoPreviewViewBoundsLeft.size.height
		var drawRectLeft = sourceExtent
		if (sourceAspect > previewAspectLeft) {
			drawRectLeft.origin.x += (drawRectLeft.size.width - drawRectLeft.size.height * previewAspectLeft) / 2.0 - 100;
			drawRectLeft.size.width = drawRectLeft.size.height * previewAspectLeft
		}
		
		self.videoPreviewViewLeft.bindDrawable()
		
		if (eaglContext != EAGLContext.currentContext()) {
			EAGLContext.setCurrentContext(eaglContext)
		}

		if filteredImage != nil {
			self.ciContext.drawImage(filteredImage!, inRect: videoPreviewViewBoundsLeft, fromRect: drawRectLeft)
			self.ciContext.drawImage(filteredImage!, inRect: videoPreviewViewBoundsLeft, fromRect: drawRectLeft)
		}
		
		self.videoPreviewViewLeft.display()
		
		
		//right
		
		let previewAspectRight = videoPreviewViewBoundsRight.size.width  / videoPreviewViewBoundsRight.size.height
		
		var drawRectRight = sourceExtent
		
		if (sourceAspect > previewAspectRight) {
			drawRectRight.origin.x += (drawRectRight.size.width - drawRectRight.size.height * previewAspectRight) / 2.0 + 100;
			drawRectRight.size.width = drawRectRight.size.height * previewAspectRight
		}

		
		self.videoPreviewViewRight.bindDrawable()
		
		if (eaglContext != EAGLContext.currentContext()) {
			EAGLContext.setCurrentContext(eaglContext)
		}
		
		if filteredImage != nil {
			self.ciContext.drawImage(filteredImage!, inRect: videoPreviewViewBoundsRight, fromRect: drawRectRight)
			self.ciContext.drawImage(filteredImage!, inRect: videoPreviewViewBoundsRight, fromRect: drawRectRight)
		}
		
		self.videoPreviewViewRight.display()
	}
}