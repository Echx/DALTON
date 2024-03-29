//
//  RealTimeColorReadingViewController.swift
//  Dalton
//
//  Created by Jiang Sheng on 4/9/16.
//  Copyright © 2016 Echx. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage
import GLKit
import DaltonFramework

class RealTimeColorReadingViewController: ViewController {
        
	@IBOutlet weak var videoPreviewView: GLKView!
	@IBOutlet weak var colorNameLabel: UILabel!


	var ciContext: CIContext!
	var eaglContext: EAGLContext!

	var videoDevice: AVCaptureDevice!
	var captureSession: AVCaptureSession!
	var captureSessionQueue: dispatch_queue_t!
	var colorNamer: ColorNamer!

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = UIColor.clearColor()
		self.eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
		
		self.colorNamer = ColorNamer()
		self.videoPreviewView.context = self.eaglContext
		self.videoPreviewView?.enableSetNeedsDisplay = false
		
		self.videoPreviewView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
		self.videoPreviewView.bindDrawable()
		
		self.ciContext = CIContext(EAGLContext: self.eaglContext, options: [kCIContextWorkingColorSpace: NSNull()])
		
		if AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count > 0 {
			self.start()
		} else {
			print("No device with AVMediaTypeVideo")
		}
		
		self.view.sendSubviewToBack(self.videoPreviewView)
		
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
	}
	
	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		return .LandscapeLeft
	}
	
	override func shouldAutorotate() -> Bool {
		return false
	}
	
	override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
		return .LandscapeLeft
	}
    
	deinit {
		let input = captureSession.inputs[0]
		captureSession.removeInput(input as! AVCaptureInput)
		
		let output = captureSession.outputs[0]
		captureSession.removeOutput(output as! AVCaptureOutput)
		captureSessionQueue = nil
		captureSession.stopRunning()
		captureSession = nil
	}

}
    
extension RealTimeColorReadingViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
	func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
		
		let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
		let sourceImage = CIImage(CVPixelBuffer: imageBuffer as CVPixelBufferRef)
		let sourceExtent = sourceImage.extent
		let sourceAspect = sourceExtent.size.width / sourceExtent.size.height

		let videoPreviewViewBounds = CGRectMake(0, 0, CGFloat(self.videoPreviewView.drawableWidth), CGFloat(self.videoPreviewView.drawableHeight))
		let previewAspect = videoPreviewViewBounds.size.width  / videoPreviewViewBounds.size.height
		var drawRect = sourceExtent
		
		if (sourceAspect > previewAspect) {
			drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0;
			drawRect.size.width = drawRect.size.height * previewAspect
		}
		
		
		let point = CGPoint(x: sourceExtent.size.width / 2, y: sourceExtent.size.height / 2)
		
		let cgOutput = self.ciContext.createCGImage(sourceImage, fromRect: drawRect)
		
		let image = UIImage(CGImage: cgOutput)
		let color = image.averageColorAtPoint(point, radius: 10)
		
		dispatch_async(dispatch_get_main_queue()) {
			self.colorNameLabel.text = self.colorNamer.rgbToColorName(color).rawValue
		}
		
		if (self.eaglContext != EAGLContext.currentContext()) {
			EAGLContext.setCurrentContext(self.eaglContext)
		}
		
		self.ciContext.drawImage(sourceImage, inRect: videoPreviewViewBounds, fromRect: drawRect)
		self.eaglContext.presentRenderbuffer(Int(GL_RENDERBUFFER))
		self.videoPreviewView.display()
	}
}


extension UIImage {
	
	func averageColorAtPoint(center: CGPoint, radius: CGFloat) -> UIColor {
		var totalR: CGFloat = 0
		var totalG: CGFloat = 0
		var totalB: CGFloat = 0
		
		let xStart = Int(max(center.x - radius, 0))
		let xEnd = Int(min(center.x + radius, self.size.width))
		let yStart = Int(max(center.y - radius, 0))
		let yEnd = Int(min(center.y + radius, self.size.height))
		
		var count: CGFloat = 0
		
		for x in xStart..<xEnd {
			for y in yStart..<yEnd {
				count += 1
				var rF: CGFloat = 0,
				gF: CGFloat = 0,
				bF: CGFloat = 0,
				aF: CGFloat = 0
				self.getPixelColor(CGPoint(x: x, y: y)).getRed(&rF, green: &gF, blue: &bF, alpha: &aF)
				totalR += rF
				totalG += gF
				totalB += bF
			}
		}
		
		let averageR = totalR / count
		let averageG = totalG / count
		let averageB = totalB / count
		
		return UIColor(red: averageR, green: averageG, blue: averageB, alpha: 1.0)
	}
	
	
    func getPixelColor(pos: CGPoint) -> UIColor {
		
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }  
}
