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

	var videoPreviewView: GLKView!
	var ciContext: CIContext!
	var eaglContext: EAGLContext!
	var videoPreviewViewBounds: CGRect!
	
	var videoDevice: AVCaptureDevice!
	var captureSession: AVCaptureSession!
	var captureSessionQueue: dispatch_queue_t!
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.backgroundColor = UIColor.clearColor()
		
		let window = (UIApplication.sharedApplication().delegate as! AppDelegate).window!
		self.eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
		self.videoPreviewView = GLKView(frame: window.bounds, context: self.eaglContext)
		self.videoPreviewView?.enableSetNeedsDisplay = false
		
		self.videoPreviewView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
		self.videoPreviewView.frame = window.bounds
		
		window.addSubview(self.videoPreviewView)
		window.sendSubviewToBack(self.videoPreviewView)
		
		self.videoPreviewView.bindDrawable()
		self.videoPreviewViewBounds = CGRectZero
		self.videoPreviewViewBounds.size.width = CGFloat(self.videoPreviewView.drawableWidth)
		self.videoPreviewViewBounds.size.height = CGFloat(self.videoPreviewView.drawableHeight)
		
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
		
		let vignetteFilter = CIFilter(name: "CIVignetteEffect")!
		vignetteFilter.setValue(sourceImage, forKey: kCIInputImageKey)
		vignetteFilter.setValue(CIVector(x: sourceExtent.size.width/2, y: sourceExtent.size.height/2), forKey: kCIInputCenterKey)
		vignetteFilter.setValue(NSNumber(double: Double(sourceExtent.size.width/2)), forKey: kCIInputRadiusKey)
		let filteredImage = vignetteFilter.outputImage
		
		let sourceAspect = sourceExtent.size.width / sourceExtent.size.height
		let previewAspect = videoPreviewViewBounds.size.width  / videoPreviewViewBounds.size.height
		
		var drawRect = sourceExtent
		if (sourceAspect > previewAspect) {
			drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0;
			drawRect.size.width = drawRect.size.height * previewAspect
		}
		
		self.videoPreviewView.bindDrawable()
		
		if (eaglContext != EAGLContext.currentContext()) {
			EAGLContext.setCurrentContext(eaglContext)
		}
		
		glClearColor(0.5, 0.5, 0.5, 1.0);
		glClear(GLenum(GL_COLOR_BUFFER_BIT));
		
		// set the blend mode to "source over" so that CI will use that
		glEnable(GLenum(GL_BLEND));
		glBlendFunc(GLenum(GL_ONE), GLenum(GL_ONE_MINUS_SRC_ALPHA));

		if filteredImage != nil {
			self.ciContext.drawImage(filteredImage!, inRect: videoPreviewViewBounds, fromRect: drawRect)
		}
		
		self.videoPreviewView.display()
	}
}