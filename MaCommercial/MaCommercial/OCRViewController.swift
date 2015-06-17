//
//  OCRViewController.swift
//  MaCommercial
//
//  Created by iem on 10/06/2015.
//

import UIKit

class OCRViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, G8TesseractDelegate {

    @IBOutlet weak var previewView: UIView!
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCaptureStillImageOutput!
    
    var keys: [String]?
    var image: UIImage?
    var completionHandler: (([String: String]) -> ())?
    
    var loader: Loader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: kMCImageOfficeBackground)
        loader = Loader(view: self.view)
        
        startPreview()
    }
        
    func startPreview() {
        var errorDevice : NSError?
        let inputDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let captureInput : AVCaptureDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(inputDevice, error: &errorDevice) as! AVCaptureDeviceInput
        if (errorDevice != nil) {
            return
        }
        
        var captureOutput = AVCaptureVideoDataOutput()
        captureOutput.setSampleBufferDelegate(self, queue: dispatch_get_main_queue())
        let videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): NSNumber(integer: kCVPixelFormatType_32BGRA)]
        captureOutput.videoSettings = videoSettings
        
        stillImageOutput = AVCaptureStillImageOutput()
        let imageSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        stillImageOutput.outputSettings = imageSettings
        
        self.captureSession = AVCaptureSession()
        self.captureSession.sessionPreset = AVCaptureSessionPresetMedium
        if self.captureSession.canAddInput(captureInput) {
            self.captureSession.addInput(captureInput)
        }
        if self.captureSession.canAddOutput(captureOutput) {
            self.captureSession.addOutput(captureOutput)
        }
        if self.captureSession.canAddOutput(stillImageOutput) {
            self.captureSession.addOutput(stillImageOutput)
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer.frame = self.previewView.bounds
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.previewLayer.position = CGPoint(x: self.previewView.center.x * 1.5, y: self.previewView.center.y)
        self.setOrientation()
        self.previewView.layer.addSublayer(self.previewLayer)
        self.captureSession.startRunning()
    }
    
    func setOrientation () {
        var previewLayerConnection = self.previewLayer.connection
        if (previewLayerConnection.supportsVideoOrientation) {
            let orientation = UIApplication.sharedApplication().statusBarOrientation
            if  orientation == UIInterfaceOrientation.Portrait {
                previewLayerConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            }
            else if orientation == UIInterfaceOrientation.LandscapeLeft {
                previewLayerConnection.videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
            }
            else if orientation == UIInterfaceOrientation.LandscapeRight {
                previewLayerConnection.videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            }
            else if orientation == UIInterfaceOrientation.PortraitUpsideDown {
                previewLayerConnection.videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
            }
        }
        
        self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo).videoOrientation = self.previewLayer.connection.videoOrientation
    }
    
    override func shouldAutorotate() -> Bool {
        setOrientation()
        return true
    }
    
    @IBAction func takeScreen(sender: AnyObject) {
        loader?.showLoader()
        
        var videoConnection: AVCaptureConnection?
        for connection in stillImageOutput.connections
        {
            for port in connection.inputPorts! {
                if (port.mediaType == AVMediaTypeVideo)
                {
                    videoConnection = connection as? AVCaptureConnection;
                    break;
                }
            }
            if ((videoConnection) != nil)
            {
                loader?.hideLoader()
                break; 
            }
        }
        
        
        stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageBuffer, error) -> Void in
            
            if error != nil {
                println(error)
                self.loader?.hideLoader()
            }
            else {
                let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageBuffer)
                let imageGet = UIImage(data: data)
                
                if imageGet != nil {
                    self.image = self.scaleImage(imageGet!, maxDimension: 640)
                    self.performSegueWithIdentifier("resultOCR", sender: self)
                }
            }
            
        })
    }
    
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }

 
    //MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "resultOCR" {
            var destination = segue.destinationViewController as! OCRResultViewController
            destination.keys = self.keys
            destination.image = self.image
            destination.completionHandler = { (data) -> () in
                if self.completionHandler != nil {
                    self.completionHandler!(data)
                }
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        loader?.hideLoader()
    }
    
    //MARK: - G8TesseractDelegate
    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
        return false;
    }
}
