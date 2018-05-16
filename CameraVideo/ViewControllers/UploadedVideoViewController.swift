//
//  UploadedVideoViewController.swift
//  CameraVideo
//
//  Created by KpStar on 5/16/18.
//  Copyright © 2018 upwork. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import AVFoundation

class UploadedVideoViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    struct uploadVideo {
        var address: String
        var createtime: String
        var uploadtime: String
        var httpurl: String
    }
    
    var data: [uploadVideo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.hidesBackButton = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "Uploaded Videos"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let user = UserDefaults.standard.string(forKey: kUsername)
        
        let url: String = kWebsiteUrl + kGetdataUrl
        
        let params: [String: String] = ["username": user!]
        
        let progress = MBProgressHUD.showAdded(to: self.view, animated: true)
        progress.detailsLabel.text = "Waiting..."
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: [:]).responseJSON { response in
            
            if let result = response.result.value {
                let JSON = result as! [NSDictionary]
                
                for object in JSON {
                    var temp: uploadVideo? = uploadVideo(address: "", createtime: "", uploadtime: "", httpurl: "")
                    temp?.address = object.value(forKey: "address") as! String
                    temp?.createtime = object.value(forKey: "createdate") as! String
                    temp?.httpurl = object.value(forKey: "videofileurl") as! String
                    temp?.uploadtime = "2018-05-16 09:22:34"
                    self.data.append(temp!)
                }
                self.tableView.reloadData()
            }
            progress.hide(animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
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

extension UploadedVideoViewController: UITableViewDelegate, UITableViewDataSource, UploadedTableViewCellDelegate {
    
    func removeBtnTapped(_ sender: UploadedTableViewCell) {
        guard let tappedIndex = tableView.indexPath(for: sender) else { return }
        let url = self.data[tappedIndex.section].httpurl
        let videoUrl: URL = URL(string: url)!
        
        
    }
    
    func shareBtnTapped(_ sender: UploadedTableViewCell) {
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "uploaded") as! UploadedTableViewCell
        cell.delegate = self
        let object = self.data[indexPath.section]
        var image: UIImage?
        let fileUrl: URL = URL(string: object.httpurl)!
        image = self.getImageFromUrl(url: fileUrl)
        cell.cellStruct = VideoInfo(time: object.createtime, address: object.address, image: image!, url: fileUrl)
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let desVC = main.instantiateViewController(withIdentifier: "Player") as! PlayerViewController
        let object = self.data[indexPath.section]
        let videoofUrl: URL = URL(string: object.httpurl)!
        desVC.url = videoofUrl
        self.navigationController?.pushViewController(desVC, animated: true)
    }
}
