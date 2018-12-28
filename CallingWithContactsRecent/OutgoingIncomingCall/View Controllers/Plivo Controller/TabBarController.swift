//
//  TabBarController.swift
//  OutgoingIncomingCall
//
//  Created by Plivo on 12/28/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import UIKit

class TabBarController : UITabBarController {
    
    override func viewWillAppear(_ animated : Bool) {
        super.viewWillAppear(animated)
        
        PlivoManager.sharedInstance.setDelegate(AppDelegate.shared)
    }
}
