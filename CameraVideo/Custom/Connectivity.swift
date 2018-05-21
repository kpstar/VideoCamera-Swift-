//
//  Connectivity.swift
//  CameraVideo
//
//  Created by KpStar on 5/19/18.
//  Copyright © 2018 upwork. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
    
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
