//
//  CustomTableViewCell+Protocol.swift
//  CameraVideo
//
//  Created by KpStar on 5/16/18.
//  Copyright © 2018 upwork. All rights reserved.
//

import Foundation

protocol CustomTableViewCellDelegate : class {
    func removeBtnTapped(_ sender: CustomTableViewCell)
    func uploadBtnTapped(_ sender: CustomTableViewCell)
    func shareBtnTapped(_ sender: CustomTableViewCell)
}

protocol UploadedTableViewCellDelegate : class {
    func removeBtnTapped(_ sender: UploadedTableViewCell)
    func shareBtnTapped(_ sender: UploadedTableViewCell)
}
