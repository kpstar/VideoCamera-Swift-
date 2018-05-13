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
    @IBOutlet weak var videoCollection: UICollectionView!
    var urlofVideos: [String] = ["http://jplayer.org/video/m4v/Big_Buck_Bunny_Trailer.m4v", "http://jplayer.org/video/m4v/Big_Buck_Bunny_Trailer.m4v","a","a","a","a","a", "a", "a"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gradient = GradientableOptions(colors: [UIColor.primary, UIColor.colorAccent, UIColor.primary], locations: nil, direction: GradientableOptionsDirection.bottomLeftToTopRight)
        titleView.set(options: gradient)
        
        videoCollection.delegate = self
        videoCollection.dataSource = self
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (urlofVideos.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collection", for: indexPath)
        let url: URL = URL(string: urlofVideos[indexPath.row])!
        let moviePlayer = AVPlayer(url: url)
        let playerlayer = AVPlayerLayer(player: moviePlayer)
        playerlayer.frame = cell.contentView.bounds
        cell.contentView.layer.addSublayer(playerlayer)
        cell.contentView.backgroundColor = UIColor.blue
        return cell
    }
    
    
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (self.view.frame.size.width - 30)/2.0
        
        return CGSize(width: CGFloat(width), height: CGFloat(width))
    }
}
