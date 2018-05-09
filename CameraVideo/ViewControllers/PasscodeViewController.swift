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

class PasscodeViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path, nil, nil, nil)
            //    Upload Video
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
        stopRecording()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mStatus = UserDefaults.standard.string(forKey: kCodeStatus) ?? "0"
        recordBtn.setTitle("REC", for: .normal)
        if mStatus == "0" {
            titleLbl.text = "Register Passcode"
            recordBtn.isHidden = true
            cameraSurfaceView.isHidden = true
        } else if mStatus == "1" {
            titleLbl.text = "Confirm Passcode"
            recordBtn.isHidden = true
            cameraSurfaceView.isHidden = true
        } else if mStatus == "2" {
            titleLbl.text = "Enter Passcode"
            recordBtn.isHidden = false
            cameraSurfaceView.isHidden = false
            loadCamera(type: 0)
            customBtn()
        } else {
            titleLbl.text = "Enter Passcode"
            recordBtn.isHidden = false
            cameraSurfaceView.isHidden = false
            loadCamera(type: 0)
            customBtn()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Backgou")
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
    
    func getBackCamera() -> AVCaptureDevice{
        return AVCaptureDevice.default(for: AVMediaType.video)!
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
