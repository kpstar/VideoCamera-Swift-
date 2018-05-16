//
//  File.swift
//  CameraVideo
//
//  Created by KpStar on 5/7/18.
//  Copyright © 2018 upwork. All rights reserved.
//

import Foundation
import UIKit

let kUsername = "Username"
let kPassword = "Password"
let kPasscode = "Passcode"
let kCodeStatus = "CodeStatus"
let main : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
let notificationDidEnterBackground = Notification.Name("DIDENTERBACKGROUND")
let kWebsiteUrl = "http://192.168.0.218/api"
let kVideoControlUrl = "http://192.168.0.218/api"
//let kWebsiteUrl = "http://18.221.221.116/api"
let kLoginUrl = "/login"
let kRegUrl = "/register"
let kDetail = "/details"
let kUploadUrl = "/uploadvideo"
let kGetdataUrl = "/posturls"
let kToken = "token"

struct VideoInfo {
    var time: String
    var address: String
    var image: UIImage
    var url: URL
}
