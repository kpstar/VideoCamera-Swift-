//
//  MainViewController.swift
//  CameraVideo
//
//  Created by KpStar on 5/7/18.
//  Copyright © 2018 upwork. All rights reserved.
//

import UIKit
import Gradientable
import MediaPlayer
import AVKit
import KYDrawerController
import Alamofire
import MBProgressHUD

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleView: GradientableView!
    var urlofVideos: [String] = []
    var drawer: KYDrawerController? {
        get {
            return self.parent as? KYDrawerController
        }
    }
    
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    var videoUrl : URL?
    var time : String? = ""
    var address : String? = ""
    var thumb : UIImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gradient = GradientableOptions(colors: [UIColor.primary, UIColor.colorAccent, UIColor.primary], locations: nil, direction: GradientableOptionsDirection.bottomLeftToTopRight)
        titleView.set(options: gradient)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if let urlArray = try? FileManager.default.contentsOfDirectory(at: directory,
                                                                       includingPropertiesForKeys: [.contentModificationDateKey],
                                                                       options:.skipsHiddenFiles) {
            
            urlofVideos = urlArray.map { url in
                (url.lastPathComponent, (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast)
                }
                .sorted(by: { $0.1 > $1.1 }) // sort descending modification dates
                .map { $0.0 } // extract file names
            
            print(urlofVideos)
            tableView.reloadData()
            
        } else {
            urlofVideos = []
            tableView.reloadData()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func btnMenuPressed(_ sender: Any) {
       drawer?.setDrawerState(.opened, animated: true)
    }
    
    @IBAction func btnPressed(_ sender: UIButton) {
        
    }
    
    private func parseInfo( filename: String ){
        videoUrl = directory.appendingPathComponent(filename)
        if let index = filename.index(of: "__") {
            address = String(filename.prefix(upTo: index))
            time = String(filename.suffix(from: index))
            time = time?.replacingOccurrences(of: "__", with: "")
            time = time?.replacingOccurrences(of: ".mp4", with: "")
            print((videoUrl?.path)!+"\n")
            print(address!+"\n")
            print(time!+"\n")
        }
    }
    
    @IBAction func recordBtnTapped(_ sender: UIButton) {
        
        UserDefaults.standard.set("2", forKey: kCodeStatus)
        drawer?.performSegue(withIdentifier: "Passcode", sender: nil)
        drawer?.setDrawerState(.closed, animated: true)
        
    }
    
    private func getImageFromUrl(url: URL) -> UIImage? {
        
        do {
            
            let asset = AVURLAsset(url: url , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            return thumbnail
            
        } catch let error {
            
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
            
        }
    }
    
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource, CustomTableViewCellDelegate {
    
    func removeBtnTapped(_ sender: CustomTableViewCell) {
        guard let tappedIndex = tableView.indexPath(for: sender) else { return }
        let url = urlofVideos[tappedIndex.section]
        print(tappedIndex.section)
        let videoUrl = directory.appendingPathComponent(url)
        let fm = FileManager.default
        if fm.fileExists(atPath: videoUrl.path) {
            do {
                try fm.removeItem(at: videoUrl)
                urlofVideos.remove(at: tappedIndex.section)
                self.tableView.reloadData()
            } catch {
                
            }
        }
        
    }
    
    func uploadBtnTapped(_ sender: CustomTableViewCell) {
        guard let tappedIndex = tableView.indexPath(for: sender) else { return }
        let index = tappedIndex.section
        let filename = urlofVideos[index]
        let url = directory.appendingPathComponent(filename)
        let data: Data? = FileManager.default.contents(atPath: url.path)
        if let mIndex = filename.index(of: "__") {
            address = String(filename.prefix(upTo: mIndex))
            address = address?.replacingOccurrences(of: "_", with: " ")
            time = String(filename.suffix(from: mIndex))
            time = time?.replacingOccurrences(of: "__", with: "")
            time = time?.replacingOccurrences(of: ".mp4", with: "")
            time = time?.replacingOccurrences(of: "_", with: ":")
        }
        let user = UserDefaults.standard.string(forKey: kUsername)
        let params : [String: String] = [
            "address" : "Ukraine Lviv Azovska",//self.address!, //"Ukraine Lviv Ruslan Street",
            "time" : self.time!,
            "user" : user!
        ]
        
        let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        progress.detailsLabel.text = "Uploading video..."
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in params {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            multipartFormData.append(data!, withName: "video", fileName: "video.mp4", mimeType: "video/mp4")
        }, to: "http://192.168.0.218/api/uploadvideo", method: .post, headers: nil) { (result) in
            DispatchQueue.main.async {
                progress.hide(animated: true)
                self.displayMyAlertMessage(titleMsg: "Success", alertMsg: "Successfully uploaded.")
                print(result)
            }
        }

    }
    
    func shareBtnTapped(_ sender: CustomTableViewCell) {
        
        guard let tappedIndex = tableView.indexPath(for: sender) else { return }
        let index = tappedIndex.section
        let filename = urlofVideos[index]
        let url = directory.appendingPathComponent(filename)
        let video = [url]
        let activityViewController = UIActivityViewController(activityItems: video, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        // exclude some activity types from the list (optional)
        //        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook, UIActivityType.postToTwitter ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return urlofVideos.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell") as! CustomTableViewCell
        cell.delegate = self
        let videoofUrl = directory.appendingPathComponent(urlofVideos[indexPath.section])
        thumb = self.getImageFromUrl(url: videoofUrl)!
        let filename = urlofVideos[indexPath.section]
        if let index = filename.index(of: "__") {
            address = String(filename.prefix(upTo: index))
            address = address?.replacingOccurrences(of: "_", with: " ")
            time = String(filename.suffix(from: index))
            time = time?.replacingOccurrences(of: "__", with: "")
            time = time?.replacingOccurrences(of: ".mp4", with: "")
            time = time?.replacingOccurrences(of: "_", with: ":")
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.cellStruct = VideoInfo(time: time!, address: address!, image: thumb, url: videoofUrl)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let desVC = main.instantiateViewController(withIdentifier: "Player") as! PlayerViewController
        let videoofUrl = directory.appendingPathComponent(urlofVideos[indexPath.section])
        desVC.url = videoofUrl
        self.navigationController?.pushViewController(desVC, animated: true)
    }
}
