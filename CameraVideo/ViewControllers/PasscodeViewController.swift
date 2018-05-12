//
//  PasscodeViewController.swift
//  CameraVideo
//
//  Created by KpStar on 5/7/18.
//  Copyright © 2018 upwork. All rights reserved.
//

import UIKit
import SmileLock
import AVFoundation
import KYDrawerController
import Alamofire

class PasscodeViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            //UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path, nil, nil, nil)
            //    Upload Video
            
            callAPIForUploadVideo(url : outputFileURL)
        }
    }
    

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var passcodeStackView: UIStackView!
    
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 6
    var outputURL : URL!
    var mStatus : String? = UserDefaults.standard.string(forKey: kCodeStatus) ?? "0"
    var passcode : String? = UserDefaults.standard.string(forKey: kPasscode) ?? ""
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var cameraType: UISegmentedControl!
    var isRecording = false
    @IBOutlet weak var cameraSurfaceView: UIView!
    
    var tempImage: UIImageView?
    
    var captureSession: AVCaptureSession?
    var movieOutput = AVCaptureMovieFileOutput()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var currentCaptureDevice: AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //create PasswordContainerView
        passwordContainerView = PasswordContainerView.create(in: passcodeStackView, digit: kPasswordDigit)
        passwordContainerView.delegate = self
        passwordContainerView.deleteButtonLocalizedTitle = "DEL"
        
        //customize password UI
        passwordContainerView.tintColor = UIColor.black
        passwordContainerView.highlightedColor = UIColor.blue
        
        NotificationCenter.default.addObserver(self, selector: #selector(prints), name: notificationDidEnterBackground, object: nil)
    }
    
    @objc func prints() {
        recordBtn.setTitle("REC", for: .normal)
        stopRecording()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mStatus = UserDefaults.standard.string(forKey: kCodeStatus) ?? "0"
        recordBtn.setTitle("REC", for: .normal)
        if mStatus == "0" {
            titleLbl.text = "Register Passcode"
            disableUI()
        } else if mStatus == "1" {
            titleLbl.text = "Confirm Passcode"
            disableUI()
        } else if mStatus == "2" {
            titleLbl.text = "Enter Passcode"
            enableUI()
            loadCamera(type: 0)
            customBtn()
        }
    }
    
    private func callAPIForUploadVideo(url: URL) {
        
        //let videoUrl = kWebsiteUrl + kUploadUrl
//        let videoUrl = "192.168.0.218/upload.php"
//        Alamofire.upload(multipartFormData: { (multipartFormData) in
//            // code
//            // here you can upload only mp4 video
//            multipartFormData.append(url, withName: "File1", fileName: "video.mp4", mimeType: "video/mp4")
//            // here you can upload any type of video
//            //multipartFormData.append(self.selectedVideoURL!, withName: "File1")
//            multipartFormData.append(("VIDEO".data(using: String.Encoding.utf8, allowLossyConversion: false))!, withName: "Type")
//
//        }, to: videoUrl , encodingCompletion: { (result) in
//            // code
//            switch result {
//            case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
//                upload.validate().responseJSON {
//                    response in
//                    if response.result.isFailure {
//                        debugPrint(response)
//                    } else {
//                        let result = response.value as! NSDictionary
//                        print(result)
//                    }
//                }
//            case .failure(let encodingError):
//                NSLog((encodingError as NSError).localizedDescription)
//            }
//        })
        let parameters = ["user":"Sol", "password":"secret1234"]
          // Image to upload:
          let imageToUploadURL = Bundle.main.url(forResource: "tree", withExtension: "png")
        
           // Server address (replace this with the address of your own server):
         let url = "192.168.0.218/upload.php"
        
         // Use Alamofire to upload the image
           Alamofire.upload(
                   multipartFormData: { multipartFormData in
                            // On the PHP side you can retrive the image using $_FILES["image"]["tmp_name"]
                         multipartFormData.append(imageToUploadURL!, withName: "image")
                       for (key, val) in parameters {
                                    multipartFormData.append(val.data(using: String.Encoding.utf8)!, withName: key)
                            }
                  },
                  to: url,
                  encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .success(let upload, _, _):
                          upload.responseJSON { response in
                            if let jsonResponse = response.result.value as? [String: Any] {
                                    print(jsonResponse)
                              }
                            }
                      case .failure(let encodingError):
                            print(encodingError)
                        }
                 }
            )
    }
    
    private func disableUI () {
    
        cameraType.isHidden = true
        recordBtn.isHidden = true
        cameraSurfaceView.isHidden = true
    }
    
    private func enableUI () {
        cameraType.isHidden = false
        recordBtn.isHidden = false
        cameraSurfaceView.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopRecording()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if mStatus == "2" {
            videoPreviewLayer!.frame =  self.cameraSurfaceView.bounds
        }
    }
    
    private func customBtn() {
        recordBtn.layer.cornerRadius = 40
        recordBtn.layer.backgroundColor = UIColor.red.cgColor
        recordBtn.layer.borderColor = UIColor.black.cgColor
        recordBtn.layer.borderWidth = 5
    }
    
    @IBAction func recordBtnTapped(_ sender: UIButton) {
        if movieOutput.isRecording == false {
            recordBtn.setTitle("STOP", for: .normal)
            let connection = movieOutput.connection(with: AVMediaType.video)
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            if (currentCaptureDevice?.isSmoothAutoFocusSupported)! {
                do {
                    try currentCaptureDevice?.lockForConfiguration()
                    currentCaptureDevice?.isSmoothAutoFocusEnabled = false
                    currentCaptureDevice?.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
                
            }
            
            outputURL = tempURL()
            try? FileManager.default.removeItem(at: outputURL)
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        }
        else {
            recordBtn.setTitle("REC", for: .normal)
            stopRecording()
        }

    }
    
    func tempURL() -> URL? {
        
        let fm = FileManager.default
        
        let temp = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dirctory = temp.appendingPathComponent("output.mp4")
        
        return dirctory
    }
    
    func stopRecording() {
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        recordBtn.setTitle("REC", for: .normal)
        loadCamera(type : cameraType.selectedSegmentIndex)
    }
    
    func loadCamera(type : Int) {
        if(captureSession == nil){
            captureSession = AVCaptureSession()
            captureSession!.sessionPreset = AVCaptureSession.Preset.high
        }
        var error: NSError?
        var input: AVCaptureDeviceInput!
        
        currentCaptureDevice = (type == 1 ? getFrontCamera() : getBackCamera())
        
        do {
            input = try AVCaptureDeviceInput(device: currentCaptureDevice!)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        for i : AVCaptureDeviceInput in (self.captureSession?.inputs as! [AVCaptureDeviceInput]){
            self.captureSession?.removeInput(i)
        }
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            if captureSession!.canAddOutput(movieOutput) {
                captureSession!.addOutput(movieOutput)
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                //self.cameraPreviewSurface.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                self.cameraSurfaceView.layer.addSublayer(videoPreviewLayer!)
                DispatchQueue.main.async {
                    self.captureSession!.startRunning()
                }
            }
        }
    }
    func getFrontCamera() -> AVCaptureDevice?{
        var frontCamera: AVCaptureDevice?
        if let videoDevices = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
            frontCamera = videoDevices
        }
        return frontCamera
    }
    
    func getBackCamera() -> AVCaptureDevice? {
        var backCamera: AVCaptureDevice?
        if let videoDevices = AVCaptureDevice.default(for: AVMediaType.video) {
            backCamera = videoDevices
        }
        return backCamera
    }
}

extension PasscodeViewController: PasswordInputCompleteProtocol {
    func passwordInputComplete(_ passwordContainerView: PasswordContainerView, input: String) {
        if validation(input) {
            validationSuccess()
        } else {
            validationFail()
        }
    }
    
    func touchAuthenticationComplete(_ passwordContainerView: PasswordContainerView, success: Bool, error: Error?) {
        if success {
            self.validationSuccess()
        } else {
            passwordContainerView.clearInput()
        }
    }
}

private extension PasscodeViewController {
    func validation(_ input: String) -> Bool {
        self.passcode = UserDefaults.standard.string(forKey: kPasscode) ?? ""
        if mStatus == "0" {
            UserDefaults.standard.set(input, forKey: kPasscode)
            return true
        } else {
            return passcode == input
        }
    }
    
    func validationSuccess() {
        print("*️⃣ success!")
        mStatus = UserDefaults.standard.string(forKey: kCodeStatus) ?? "0"
        if mStatus == "0" {
            UserDefaults.standard.set("1", forKey: kCodeStatus)
            self.viewWillAppear(true)
        } else {
            let desVC = main.instantiateViewController(withIdentifier: "DrawerVC") as! KYDrawerController
            UserDefaults.standard.set("2", forKey: kCodeStatus)
            self.navigationController?.pushViewController(desVC, animated: true)
        }
        self.passwordContainerView.clearInput()
       // dismiss(animated: true, completion: nil)
    }
    
    func validationFail() {
        print("*️⃣ failure!")
        mStatus = UserDefaults.standard.string(forKey: kCodeStatus) ?? "0"
        passwordContainerView.wrongPassword()
        self.passwordContainerView.clearInput()
    }
}
