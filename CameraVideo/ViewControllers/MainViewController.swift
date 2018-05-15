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

class MainViewController: UIViewController {

    @IBOutlet weak var titleView: GradientableView!
    var urlofVideos: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gradient = GradientableOptions(colors: [UIColor.primary, UIColor.colorAccent, UIColor.primary], locations: nil, direction: GradientableOptionsDirection.bottomLeftToTopRight)
        titleView.set(options: gradient)
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            self.urlofVideos = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            print(self.urlofVideos)
            // process files
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }

    }
}

