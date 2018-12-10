//
//  AppUtility.swift
//  OutGoingCall
//
//  Created by Plivo on 12/8/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import Foundation

/**
 *
 * AppUtility
 * To Lock Orientation for each screen
 *
 */
struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }

}
