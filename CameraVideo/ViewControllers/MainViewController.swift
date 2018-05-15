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

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleView: GradientableView!
    var urlofVideos: [String] = []
    var drawer: KYDrawerController? {
        get {
            return self.parent as? KYDrawerController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gradient = GradientableOptions(colors: [UIColor.primary, UIColor.colorAccent, UIColor.primary], locations: nil, direction: GradientableOptionsDirection.bottomLeftToTopRight)
        titleView.set(options: gradient)
        
        tableView.delegate = self
        tableView.dataSource = self
        
//        let fileManager = FileManager.default
//        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        do {
//            self.urlofVideos = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
//            print(self.urlofVideos)
//            // process files
//        } catch {
//            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
//        }
    
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
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
    
    @IBAction func btnMenuPressed(_ sender: Any) {
       drawer?.setDrawerState(.opened, animated: true)
    }
}


extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return urlofVideos.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell") as! CustomTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }
}
