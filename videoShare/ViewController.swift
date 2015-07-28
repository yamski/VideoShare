//
//  ViewController.swift
//  videoShare
//
//  Created by JOHN YAM on 3/1/15.
//  Copyright (c) 2015 John Yam. All rights reserved.
//
//

    // AVFoundation is based on the concept of the session. A session is used to control the flow of the data from an input to an output device. generates runtime errors in case something goes wrong.

//  AVCaptureDevice – represents the input device (camera or microphone)
//  AVCaptureInput – (a concrete subclass of) to configure the ports from the input device (has one or more input ports which are instances of AVCaptureInputPort)
//  AVCaptureOutput – (a concrete subclass of) to manage the output to a movie file or still image (accepts data from one or more sources, e.g. an AVCaptureMovieFileOutput object accepts both video and audio data)
//  AVCaptureSession – coordinates the data flow from the input to the output
//  AVCaptureVideoPreviewLayer – shows the user what a camera is recording

//  AVCaptureConnection – connection between a capture input and a capture output in a capture session. Can be used to enable or disable the flow of data from a given input or to a given output. Also to monitor the average and peak power levels in audio channels.

//    AVCaptureDevice is the interface to the hardware camera. It is used to control the hardware features such as the position of the lens, the exposure, and the flash

import UIKit
import AVFoundation
import GLKit
import CoreMedia
import AssetsLibrary


import MediaPlayer

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate, TopButtonProtocol, MenuProtocol {
    
    var session: AVCaptureSession!
    var backCameraDevice: AVCaptureDevice?
    var frontCameraDevice: AVCaptureDevice?
    var activeCameraDevice: AVCaptureDevice?
    var possibleCameraInput: AnyObject?
    
    var previewLayer: PreviewLayerVC?
    
    var videoOutput: AVCaptureVideoDataOutput?
    var glContext: EAGLContext?
    var glView: GLKView?
    var ciContext: CIContext?
    var stillCameraOutput: AVCaptureStillImageOutput?
    var movieFileOutput: AVCaptureMovieFileOutput?
    var weAreRecording: Bool = false
    
    
    var topBar: TopBar!
    var menu: Menu?

    var flashIsOn = false
    
    var timeSec = 0
    var timeMin = 0
    var timeHr = 0
    var timer: NSTimer?
    
    var showMenu = true
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var libraryBtn: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clearColor()
        
        setupPreview()
       
        recordButton.layer.cornerRadius = recordButton.frame.size.width / 2
    
        session = AVCaptureSession()
        
        let availableCameraDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        
        for device in availableCameraDevices as! [AVCaptureDevice] {
            if device.position == .Back {
                backCameraDevice = device
            } else if device.position == .Front {
                frontCameraDevice = device
            }
        }
        
   
        do {
            possibleCameraInput = try AVCaptureDeviceInput(device: backCameraDevice)
            
            activeCameraDevice = backCameraDevice
            
        } catch let outError as NSError {
            
            print(outError.description)
            possibleCameraInput = nil
        }
        
        if let cameraInput = possibleCameraInput as? AVCaptureDeviceInput {
            if self.session.canAddInput(cameraInput) {
                self.session.addInput(cameraInput)
            }
        }
        
        addAudio()
        buildTopBarView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
    }
    

    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
    }
    
    func buildTopBarView() {
        
        topBar = TopBar()
        topBar.delegate = self
        view.addSubview(topBar)

    }
    
    func addAudio() {
        
       
        
        do {
            let audioCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
            
//            let audioInput = AVCaptureDeviceInput.deviceInputWithDevice(audioCaptureDevice) as AVCaptureDeviceInput
            let audioInput = try AVCaptureDeviceInput(device: audioCaptureDevice)
            session.addInput(audioInput)
        
//            if let hasAudioInput = audioInput { session.addInput(audioInput) }
            
            
        } catch let error as NSError{
            print(error.description)
        }
        
        
    
        session.commitConfiguration()
    }

    func setupPreview() {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.previewLayer = PreviewLayerVC()
            self.previewLayer!.session = self.session
            self.previewLayer!.pLayer.frame = self.view.frame
            self.view.insertSubview(self.previewLayer!.view, atIndex: 0)
            
            self.session.startRunning()
            
//            self.checkAuthorizition()
            self.setupCameraOutput()
        }
    }
    
    func setupCameraOutput() {

        videoOutput = AVCaptureVideoDataOutput()
        videoOutput?.setSampleBufferDelegate(self, queue: dispatch_queue_create("sample buffer delegate", DISPATCH_QUEUE_SERIAL))
        
        if session.canAddOutput(self.videoOutput) {
            
            session.addOutput(self.videoOutput)
            session.startRunning()
        }
        
        // AVCaptureStillImageOutput allows us to capture a still image
        stillCameraOutput = AVCaptureStillImageOutput()
        
        if self.session.canAddOutput(self.stillCameraOutput) {
            self.session.addOutput(self.stillCameraOutput)
        }
        
        //ADD MOVIE FILE OUTPUT
        movieFileOutput = AVCaptureMovieFileOutput()
        
        let totalSeconds: Float64 = 60	//Total seconds
        let preferredTimeScale: Int32 = 30;	//Frames per second
        let maxDuration: CMTime = CMTimeMakeWithSeconds(totalSeconds, preferredTimeScale);	//<<SET MAX DURATION
        movieFileOutput?.maxRecordedDuration = maxDuration
     
        movieFileOutput?.minFreeDiskSpaceLimit = 1024 * 1024;	//<<SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME
        
        if (session.canAddOutput(movieFileOutput)){
            session.addOutput(movieFileOutput)
        }
    }
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let image = CIImage(CVPixelBuffer: pixelBuffer)
            
            if glContext != EAGLContext.currentContext() {
                EAGLContext.setCurrentContext(glContext)
            }
            glView?.bindDrawable()
            ciContext?.drawImage(image, inRect:image.extent, fromRect: image.extent)
            glView?.display()
        }

    }
    

    
    
//    func cameraSetOutputProperties() {
//        
//        let captureConnection: AVCaptureConnection = movieFileOutput!.connectionWithMediaType(AVMediaTypeVideo)
////        //Set frame rate (if requried)
////        CMTimeShow(captureConnection.videoMinFrameDuration)
////        CMTimeShow(captureConnection.videoMaxFrameDuration)
////        
////        if (captureConnection.supportsVideoMinFrameDuration) {
////        captureConnection.videoMinFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND)
////        }
////        if (captureConnection.supportsVideoMaxFrameDuration)
////        CcptureConnection.videoMaxFrameDuration = CMTimeMake(1, CAPTURE_FRAMES_PER_SECOND);
////        
////        CMTimeShow(CaptureConnection.videoMinFrameDuration);
////        CMTimeShow(CaptureConnection.videoMaxFrameDuration);
//    
//    }
    
    
    func checkAuthorizition() {
        
        let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch authorizationStatus {
        case .NotDetermined:
            // permission dialog not yet presented, request authorization
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted:Bool) -> Void in
                
                    if granted {
                        // go ahead
//                        self.setupPreview()
                        self.setupCameraOutput()
                        
                    }
                    else {
                        // user denied, nothing much to do
                    }
            })
        case .Authorized:
            
//            setupPreview()
            setupCameraOutput()
            
        case .Denied, .Restricted:
            
            let alertController = UIAlertController(title: "Default Style", message: "A standard alert.", preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true) { }
        }
        
    }
    

    
    func checkFlash() {

        if (activeCameraDevice?.hasTorch != nil && activeCameraDevice?.position == AVCaptureDevicePosition.Back) {
            
            topBar.flashBtn.alpha = 1.0
            topBar.flashBtn.enabled = true
            
            if flashIsOn {
                do {
                    try activeCameraDevice?.lockForConfiguration()
                } catch _ {
                }
                activeCameraDevice?.torchMode = AVCaptureTorchMode.Off
                activeCameraDevice?.unlockForConfiguration()
                flashIsOn = false
                topBar.flashLabel.text = "OFF"
            } else {
                do {
                    try activeCameraDevice?.lockForConfiguration()
                } catch _ {
                }
                activeCameraDevice?.torchMode = .On
                activeCameraDevice?.unlockForConfiguration()
                flashIsOn = true
                topBar.flashLabel.text = "ON"
            }
        }
    }
    

    
    @IBAction func recordButtonTapped(sender: UIButton) {
        
        if (!weAreRecording)
            
        {
            print("START RECORDING")
            weAreRecording = true
            
            //Create temporary URL to record to
            
            let outputPath: NSString = "\(NSTemporaryDirectory()) + output.mov"
            
            let outputURL = NSURL(fileURLWithPath: outputPath as String)
            
            let fileManger = NSFileManager.defaultManager()
            
//            if(fileManger.fileExistsAtPath(outputPath as String)){
//                
//                var error: NSError?
//                
//                if (fileManger.removeItemAtPath(outputPath as String) == false) {
//                    // handle error
//                    
//                    print(error)
//                }
//                
//            }
            movieFileOutput?.startRecordingToOutputFileURL(outputURL, recordingDelegate: self)
            
            recordButton.setTitle("STOP", forState: .Normal)
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerTick:", userInfo: nil, repeats: true)
            
            topBar.toggleCameraBtn.alpha = 0.4
            topBar.toggleCameraBtn.enabled = false
            
        } else {
            
            print("STOP RECORDING")
            weAreRecording = false;
            movieFileOutput?.stopRecording()
            
            recordButton.setTitle("RECORD", forState: .Normal)
            
            topBar.toggleCameraBtn.alpha = 1.0
            topBar.toggleCameraBtn.enabled = true
            
            timer?.invalidate()
            topBar.timeLabel.text = "00:00:00"
            timeSec = 0
            timeMin = 0
        }
        
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        
        print("starting to record")
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        
        
        print("didFinishRecordingToOutputFileAtURL - enter");
        
        let recordedSuccessfully = true;
        
//        if (error.code != noErr) {
//            
//            // A problem occurred: Find out if the recording was successful.
//            var value = error.userInfo.objectForKey(AVErrorRecordingSuccessfullyFinishedKey)
//            
//            if (value) {
//                RecordedSuccessfully = value.boolValue;
//            }
//        }
        
        if (recordedSuccessfully) {
        
            print("didFinishRecordingToOutputFileAtURL - success");
            let library = ALAssetsLibrary()
        
            
            library.writeVideoAtPathToSavedPhotosAlbum(outputFileURL, completionBlock: nil)
      
        }
        
    }
    
    func saveToDocumentsDirectory() {
        
        let destFileName = "output.mov"
        print("starting to save \(destFileName)")
        
//        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    
        
//        DestPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:RECORD_TO_ADD_DIRECTORY];
//        DestPath = [DestPath stringByAppendingPathComponent:DestFilename];
//        
//        NSURL* saveLocationURL = [[NSURL alloc] initFileURLWithPath:DestPath];
//        [MovieFileOutput startRecordingToOutputFileURL:saveLocationURL recordingDelegate:self];
    }
    
    
    func selectCamera() {
        
        session.beginConfiguration()
        
        let currentCameraInput = session.inputs.first as! AVCaptureInput
        
        let inputs = session.inputs
        
        for input in inputs {session.removeInput(input as! AVCaptureInput)}
        
        if (currentCameraInput as! AVCaptureDeviceInput).device.position == AVCaptureDevicePosition.Back {
            
            activeCameraDevice = cameraWithPosition(AVCaptureDevicePosition.Front)
            topBar.flashBtn.alpha = 0.25
            topBar.flashBtn.enabled = false
            topBar.flashLabel.alpha = 0.25
        
        } else {
            activeCameraDevice = cameraWithPosition(AVCaptureDevicePosition.Back)
            topBar.flashBtn.alpha = 1.0
            topBar.flashBtn.enabled = true
            topBar.flashLabel.alpha = 1.0
        }
        
       

        do {
            possibleCameraInput = try AVCaptureDeviceInput(device:activeCameraDevice)
            session.addInput(possibleCameraInput as! AVCaptureInput)
        } catch let error as NSError {
            
            possibleCameraInput = nil
            print("Error creating capture device input: \(error.localizedDescription)");

        }
//        
//        if(error != nil) {
//            print("Error creating capture device input: \(error!.localizedDescription)");
//        } else { session.addInput(possibleCameraInput as! AVCaptureInput)}

        addAudio()
        session.commitConfiguration()
    }
    
    
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        
        for device in devices {
            if device.position == position {
                return device as? AVCaptureDevice
            }
        }
        return nil
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let touch = touches.first {
            
            let point = touch.locationInView(self.view)
            let newPoint = previewLayer!.pLayer.captureDevicePointOfInterestForPoint(point)

            focusWithMode(AVCaptureFocusMode.AutoFocus, exposureMode: AVCaptureExposureMode.AutoExpose, point: newPoint, monitorSubjectAreaChange: true)
            
            menu?.exposureSlider.setValue(0.5, animated: true)

        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchesBegan(touches, withEvent: event)
        
    }
    
    
    func focusWithMode(focusMode:AVCaptureFocusMode, exposureMode:AVCaptureExposureMode, point:CGPoint, monitorSubjectAreaChange:Bool){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            let device: AVCaptureDevice! = self.possibleCameraInput?.device
            var error: NSError? = nil
            
            do {
                try device.lockForConfiguration()
                if device.focusPointOfInterestSupported && device.isFocusModeSupported(focusMode){
                    device.focusMode = focusMode
                    device.focusPointOfInterest = point
                }
                if device.exposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode){
                    device.exposurePointOfInterest = point
                    device.exposureMode = exposureMode
                }
                device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch let error1 as NSError {
                error = error1
                print(error)
            } catch {
                fatalError()
            }
        })
    }

    
    func showHideMenu() {
    
        if showMenu {
            menu = Menu()
            menu?.delegate = self
            view.addSubview(menu!)
            
            if let tempAndTintValues = activeCameraDevice?.temperatureAndTintValuesForDeviceWhiteBalanceGains(activeCameraDevice!.deviceWhiteBalanceGains) {
                
                menu!.tempSlider.setValue(tempAndTintValues.temperature, animated: true)
                menu!.tintSlider.value = tempAndTintValues.tint
                
                print("temp is \(tempAndTintValues.temperature), value is \(menu?.tempSlider.value)", appendNewline: false)
                print("tint is \(tempAndTintValues.tint), value is \(menu?.tintSlider.value)", appendNewline: false)
            }
            
        }
        
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            
            let orientation = self.getOrientation()
            
            if self.showMenu {
                
                if (orientation == .Portrait) {
                    
                    print("show menu portrait", appendNewline: false)
                    self.menu?.frame.origin = CGPointMake(0, self.topBar.frame.height)
                    
                } else if (orientation == .LandscapeLeft) {
                    print("show menu landscape", appendNewline: false)
                    self.menu?.frame.origin = CGPointMake(screenWidth - (self.menu!.frame.width + 50), 0)
                }
                self.showMenu = false
            } else {
                
                if (orientation == .Portrait) {
                    
                    print("hide menu portrait", appendNewline: false)
                    self.menu?.frame.origin = CGPointMake(0, 0 - (self.topBar.frame.height + self.menu!.frame.height))
 
                } else if (orientation == .LandscapeLeft) {
                    print("hide menu landscape", appendNewline: false)
                    self.menu?.frame.origin = CGPointMake(screenWidth + (self.menu!.frame.width + 50), 0)
          
                }
                
                self.showMenu = true
            }
            
            }, completion:
            {(Bool) in if (self.showMenu) { self.menu?.removeFromSuperview()
    
                }
        })
    }

    func getOrientation() -> UIDeviceOrientation {
        return UIDevice.currentDevice().orientation
    }
 
    func adjustExposure(sender: UISlider) {
        
        print("adjust exposure", appendNewline: false)
        
        let isoValue = sender.value
        
        if let device = activeCameraDevice {
//            if(device.lockForConfiguration())
            
            do {
                
                try device.lockForConfiguration()
                
                // Adjust the iso to clamp between minIso and maxIso based on the active format
                let minISO = device.activeFormat.minISO
                let maxISO = device.activeFormat.maxISO
                let clampedISO = isoValue * (maxISO - minISO) + minISO
                
                print("iso info: \(minISO),\(maxISO), \(clampedISO) ")
                
                device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: clampedISO, completionHandler: { (time) -> Void in
                    //
                })
                
                device.unlockForConfiguration()
            } catch let error as NSError {
                print(error.description)
               
            }
        }
    }
    
    func adjustTemp(sender: UISlider) {
        
        print("adjust temp", appendNewline: false)
        
        let tempAndTint = AVCaptureWhiteBalanceTemperatureAndTintValues(temperature: menu!.tempSlider.value, tint: menu!.tintSlider.value)
        setWhiteBalanceGains(activeCameraDevice!.deviceWhiteBalanceGainsForTemperatureAndTintValues(tempAndTint))
    }
    
    
    func adjustTint(sender: UISlider) {
        
        print("adjust tint", appendNewline: false)
        let tempAndTint = AVCaptureWhiteBalanceTemperatureAndTintValues(temperature: menu!.tempSlider.value, tint: menu!.tintSlider.value)
        setWhiteBalanceGains(activeCameraDevice!.deviceWhiteBalanceGainsForTemperatureAndTintValues(tempAndTint))
        
        activeCameraDevice?.deviceWhiteBalanceGains
    }
    
    
    func setWhiteBalanceGains(gains: AVCaptureWhiteBalanceGains) {
//        let error: NSError?
//        
//        if ((activeCameraDevice?.lockForConfiguration()) != nil) {
//            
//            let normalized = normalizedGains(gains)  // Conversion can yield out-of-bound values, cap to limits
//            activeCameraDevice?.setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains(normalized, completionHandler: nil)
//            activeCameraDevice?.unlockForConfiguration()
//        } else {
//            print("\(error)")
//        }
        
        do {
            try activeCameraDevice?.lockForConfiguration()
            let normalized = normalizedGains(gains)  // Conversion can yield out-of-bound values, cap to limits
            activeCameraDevice?.setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains(normalized, completionHandler: nil)
            activeCameraDevice?.unlockForConfiguration()
        } catch let error as NSError {
            print(error.description)
        }
        
        
    }
    
    
    func normalizedGains(gains: AVCaptureWhiteBalanceGains) -> AVCaptureWhiteBalanceGains {
        var g: AVCaptureWhiteBalanceGains = gains
        
        g.redGain = max(1.0, g.redGain);
        g.greenGain = max(1.0, g.greenGain);
        g.blueGain = max(1.0, g.blueGain);
        
        g.redGain = min(activeCameraDevice!.maxWhiteBalanceGain, g.redGain);
        g.greenGain = min(activeCameraDevice!.maxWhiteBalanceGain, g.greenGain);
        g.blueGain = min(activeCameraDevice!.maxWhiteBalanceGain, g.blueGain);
        
        return g
        
    }
    

    func timerTick(timer: NSTimer) {
        
        timeSec++
        
        if(timeSec == 60){
            timeSec = 0
            timeMin++
        } else if (timeMin == 60){
            timeMin = 0
            timeHr++
        }
    
        let strSeconds = timeSec > 9 ? String(timeSec):"0" + String(timeSec)
        let strMinutes = timeMin > 9 ? String(timeMin):"0" + String(timeMin)
        let strHour = timeHr > 9 ? String(timeHr):"0" + String(timeHr)
        
        topBar.timeLabel.text = "\(strHour):\(strMinutes):\(strSeconds)"
    }
    

    
    func orientationChanged(notif: NSNotification) {
        
        var barWidth: CGFloat = 0
        var barHeight: CGFloat = 0
        
        let orientation = getOrientation()
        var angle = 0 as CGFloat
        var position = CGPoint(x: 0,y: 0)
        var menuPosition = CGPoint(x: 0, y:50)
        
        print("\(orientation.rawValue), \(orientation.isValidInterfaceOrientation)")
        
        switch orientation {
            
            case .Portrait, .PortraitUpsideDown, .FaceUp, .FaceDown, .Unknown:
                barWidth = screenWidth
                barHeight = 50
                position.x = 0
                position.y = 0
                menuPosition.x = 0
                menuPosition.y = 50
            
            case .LandscapeLeft, .LandscapeRight:
                angle = CGFloat(M_PI_2)
                barWidth = 50
                barHeight = screenHeight
                position.x = screenWidth - topBar.frame.size.height
                
                if let menuBox = menu {
                    menuPosition.x = screenWidth - menuBox.frame.size.height - topBar.frame.size.height
                    menuPosition.y = 0
                }
        }

        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            
            self.topBar.hidden = true
            self.topBar.transform = CGAffineTransformMakeRotation(angle)
            self.topBar.frame.origin = position
            self.topBar.frame.size.width = barWidth
            self.topBar.frame.size.height = barHeight
    
            self.recordButton.transform = CGAffineTransformMakeRotation(angle)
            
            if (self.menu != nil) {
                self.menu?.hidden = true
                self.menu?.transform = CGAffineTransformMakeRotation(angle)
                self.menu?.frame.origin.x = menuPosition.x
                self.menu?.frame.origin.y = menuPosition.y
            }
            
            print("width: \(self.topBar.frame.width), height: \(self.topBar.frame.height)")
            print("position: \(position)")
    
        }) { (Bool) -> Void in
            self.topBar.hidden = false
            self.menu?.hidden = false
        }
    }
    

    @IBAction func libraryBtnTapped(sender: AnyObject) {
        performSegueWithIdentifier("ToLibrary", sender: self)
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        
//        let vc = storyboard.instantiateViewControllerWithIdentifier("tableView") as? LibraryTableView
//        
// 
//        presentViewController(vc!, animated: true, completion: nil)
    }

    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    


}

