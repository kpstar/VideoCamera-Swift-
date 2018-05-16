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
import CoreLocation

class PasscodeViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var videoPreview: UIStackView!
    @IBOutlet weak var videoLayout: UIView!
    var location : CLLocation?
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var passcodeStackView: UIStackView!
    var locationManager = CLLocationManager()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var passwordContainerView: PasswordContainerView!
    let kPasswordDigit = 6
    var outputURL : URL!
    var mStatus : String? = UserDefaults.standard.string(forKey: kCodeStatus) ?? "0"
    var passcode : String? = UserDefaults.standard.string(forKey: kPasscode) ?? ""
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var cameraType: UISegmentedControl!
    var isRecording = false
    var player: AVAudioPlayer?
    @IBOutlet weak var lblTimer: UILabel!
    var counter = 0
    var tempImage: UIImageView?
    
    var captureSession: AVCaptureSession?
    var movieOutput = AVCaptureMovieFileOutput()
    var currentCaptureDevice: AVCaptureDevice?
    var timer = Timer()
    let ceo : CLGeocoder = CLGeocoder()
    var addressString : String = ""

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
    
    override func viewDidLayoutSubviews() {
        videoPreviewLayer?.frame = self.videoLayout.bounds
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            //UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path, nil, nil, nil)
            
            //    Upload Video
//            DispatchQueue.global(qos: .background).async {
//                self.callAPIForUploadVideo(url : outputFileURL)
//            }
        }
    }
    
    @objc func prints() {
        recordBtn.setTitle("REC", for: .normal)
        stopRecording()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.addressString = ""
        if (CLLocationManager.locationServicesEnabled())
        {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
                location = locationManager.location
                ceo.reverseGeocodeLocation(location!, completionHandler:
                    {(placemarks, error) in
                        if (error != nil)
                        {
                            print("reverse geodcode fail: \(error!.localizedDescription)")
                        }
                        let pm = placemarks! as [CLPlacemark]
                        
                        if pm.count > 0 {
                            let pm = placemarks![0]
                            
                            if pm.country != nil {
                                self.addressString = self.addressString + pm.country! + "_"
                            }
                            if pm.locality != nil {
                                self.self.addressString = self.addressString + pm.locality! + "_"
                            }
                            if pm.thoroughfare != nil {
                                self.self.addressString = self.addressString + pm.thoroughfare! + "_"
                            }
                            if pm.subLocality != nil {
                                self.addressString = self.addressString + pm.subLocality!
                            }
                        } else {
                            self.addressString = "noaddress"
                        }
                })
                break
            case .notDetermined, .restricted, .denied:
                self.addressString = "noaddress"
                break
            }
        } else {
            self.addressString = "noaddress__"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
        mStatus = UserDefaults.standard.string(forKey: kCodeStatus) ?? "0"
        recordBtn.setTitle("REC", for: .normal)
        
        locationManager.requestAlwaysAuthorization()
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
            cameraType.selectedSegmentIndex = 0
            customBtn()
        }
        
        videoPreview.isHidden = true
        passcodeStackView.isHidden = false
    }
    
//    private func callAPIForUploadVideo(url: URL) {
//
//    }
    
    @objc func timerAction() {
        counter += 1
        
        var tst = String(counter % 60)
        var tst1 = String(counter / 60)
        if tst.count == 1 {
            tst = "0" + tst
        }
        if tst1.count == 1 {
            tst1 = "0" + tst1
        }
        
        
        lblTimer.text = "\(tst1)" + ":" + "\(tst)"
        
        //lblTimer.text = "\(counter)"
    }
    
    private func details () {
        
        let params: [String: Any] = [
            "name": "abcde",
            "password": "password!"
        ]
        
        
        let url: String = kWebsiteUrl + kDetail
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: [:]).responseJSON { response in
            
        }
    }
    
    private func disableUI () {
    
        cameraType.isHidden = true
        recordBtn.isHidden = true
    }
    
    private func enableUI () {
        cameraType.isHidden = false
        recordBtn.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopRecording()
    }

    private func customBtn() {
        recordBtn.layer.cornerRadius = 40
        recordBtn.layer.backgroundColor = UIColor.red.cgColor
        recordBtn.layer.borderColor = UIColor.black.cgColor
        recordBtn.layer.borderWidth = 5
    }
    
    @IBAction func recordBtnTapped(_ sender: UIButton) {
        if movieOutput.isRecording == false {
            
            videoPreview.isHidden = false
            passcodeStackView.isHidden = true
            playStartSound()
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
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
            
            stopRecording()
        }

    }
    
    func tempURL() -> URL? {
        
        let fm = FileManager.default
        let temp = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH_mm_ss"
        
        let filename = addressString + "__" + formatter.string(from: Date()) + ".mp4"
        print(filename)
        let directory = temp.appendingPathComponent(filename)
        print(directory)
        return directory
    }
    
    func stopRecording() {
        
        if movieOutput.isRecording == true {
            passcodeStackView.isHidden = false
            timer.invalidate()
            counter = 0
            lblTimer.text = "00:00"
            videoPreview.isHidden = true
            playEndSound()
            recordBtn.setTitle("REC", for: .normal)
            movieOutput.stopRecording()
        }
    }
    
    func playStartSound() {
        guard let url = Bundle.main.url(forResource: "camera_start", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func playEndSound() {
        guard let url = Bundle.main.url(forResource: "camera_end", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
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
        
        if currentCaptureDevice == nil {
            self.displayMyAlertMessage(titleMsg: "Error", alertMsg: "No camera device")
            return
        }
        
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
                self.videoLayout.layer.addSublayer(videoPreviewLayer!)
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
