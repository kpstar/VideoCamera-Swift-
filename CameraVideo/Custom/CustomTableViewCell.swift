//
//  CustomTableViewCell.swift
//  CameraVideo
//
//  Created by KpStar on 5/15/18.
//  Copyright © 2018 upwork. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var delBtn: UIButton!
    @IBOutlet weak var thumbImg: UIImageView!
    @IBOutlet weak var addressLbl: UILabel!
    
    var cellStruct: VideoInfo? {
        didSet {
            timeLabel.text = cellStruct?.time
            addressLbl.text = cellStruct?.address
            thumbImg.image = cellStruct?.image
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
