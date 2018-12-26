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

    /*
     * remove any sip type/domain related
     * information from username
     */
    static func getUserNameWithoutDomain(_ userName : String) -> String {
        var userNameArray = userName.components(separatedBy: "@")
        if (userNameArray.count > 0) {
            let modifiedName = userNameArray[0]
            Logger.logDebug(tag: "AppUtility", message: "found @ in username modified username \(modifiedName)")
            return modifiedName
        } else {
            return userName
        }
    }
}
