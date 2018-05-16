//
//  UploadedTableViewCell.swift
//  CameraVideo
//
//  Created by KpStar on 5/16/18.
//  Copyright © 2018 upwork. All rights reserved.
//

import UIKit

class UploadedTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var mImgView: UIImageView!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var timeView: UIView!
    
    weak var delegate: UploadedTableViewCellDelegate?
    
    var cellStruct: VideoInfo? {
        didSet {
            timeLbl.text = cellStruct?.time
            addressLbl.text = cellStruct?.address
            mImgView.image = cellStruct?.image
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        timeView.layer.cornerRadius = 10.0
    }
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        
        if sender == shareBtn {
            delegate?.shareBtnTapped(self)
        } else {
            delegate?.removeBtnTapped(self)
        }
    }
    
}
