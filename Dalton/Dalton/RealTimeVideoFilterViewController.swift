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
import DaltonFramework

class RealTimeVideoFilterViewController: ViewController {
	
	var currentMode = NSUserDefaults.standardUserDefaults().integerForKey("MODE")
	
	@IBOutlet var videoPreviewView: GLKView!
	
	
	var ciContext: CIContext!
	var eaglContext: EAGLContext!
	var videoPreviewViewBounds: CGRect!
	
	var videoDevice: AVCaptureDevice!
	var captureSession: AVCaptureSession!
	var captureSessionQueue: dispatch_queue_t!
	
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = UIColor.clearColor()
		self.eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
		
		
		self.videoPreviewView.context = self.eaglContext
		self.videoPreviewView?.enableSetNeedsDisplay = false
		
		self.videoPreviewView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
		self.videoPreviewView.bindDrawable()
		self.videoPreviewViewBounds = CGRectMake(0, 0, CGFloat(self.videoPreviewView.drawableWidth), CGFloat(self.videoPreviewView.drawableHeight))
		
		self.ciContext = CIContext(EAGLContext: self.eaglContext, options: [kCIContextWorkingColorSpace: NSNull()])
		
		if AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count > 0 {
			self.start()
		} else {
			print("No device with AVMediaTypeVideo")
		}
		
		// Do any additional setup after loading the view.
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		currentMode = NSUserDefaults.standardUserDefaults().integerForKey("MODE")
	}
    
    deinit {
        let input = captureSession.inputs[0]
        captureSession.removeInput(input as! AVCaptureInput)
        
        let output = captureSession.outputs[0]
        captureSession.removeOutput(output as! AVCaptureOutput)
        captureSessionQueue = nil
        captureSession.stopRunning()
        captureSession = nil
        videoPreviewViewBounds = nil
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
		ColorBlindness.applyCBMatrix(filter, mode: currentMode)
		
		let filteredImage = filter.outputImage
		
		let sourceAspect = sourceExtent.size.width / sourceExtent.size.height
		
		let previewAspect = videoPreviewViewBounds.size.width  / videoPreviewViewBounds.size.height
		var drawRect = sourceExtent
		if (sourceAspect > previewAspect) {
			drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0 - 100;
			drawRect.size.width = drawRect.size.height * previewAspect
		}
		
		self.videoPreviewView.bindDrawable()
		
		if (eaglContext != EAGLContext.currentContext()) {
			EAGLContext.setCurrentContext(eaglContext)
		}
		
		if filteredImage != nil {
			self.ciContext.drawImage(filteredImage!, inRect: videoPreviewViewBounds, fromRect: drawRect)
		}
		
		dispatch_async(dispatch_get_main_queue()) {
			self.eaglContext.presentRenderbuffer(Int(GL_RENDERBUFFER))
			self.videoPreviewView.display()
		}
	}
}
