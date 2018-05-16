//
//  CustomTableViewCell.swift
//  CameraVideo
//
//  Created by KpStar on 5/15/18.
//  Copyright © 2018 upwork. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var thumbImg: UIImageView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var timeView: UIView!
    
    weak var delegate: CustomTableViewCellDelegate?
    
    var url: URL?
    
    var cellStruct: VideoInfo? {
        didSet {
            timeLbl.text = cellStruct?.time
            addressLbl.text = cellStruct?.address
            thumbImg.image = cellStruct?.image
            self.url = cellStruct?.url
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        timeView.layer.cornerRadius = 10.0
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if sender == removeBtn {
            delegate?.removeBtnTapped(self)
        } else if sender == uploadBtn {
            delegate?.uploadBtnTapped(self)
        } else {
            delegate?.shareBtnTapped(self)
        }
    }
}

