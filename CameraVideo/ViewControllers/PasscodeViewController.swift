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

class PasscodeViewController: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var passcodeStackView: UIStackView!
    
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 6
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mStatus = UserDefaults.standard.string(forKey: kCodeStatus) ?? "0"
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
        if isRecording {
            
        } else {
        }
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
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
            let desVC = main.instantiateViewController(withIdentifier: "DrawerNav") as! UINavigationController
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
