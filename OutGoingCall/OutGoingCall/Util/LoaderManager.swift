//
//  LoaderUtil.swift
//  OutGoingCall
//
//  Created by Plivo on 12/7/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import UIKit

/**
 *
 * ActivityIndicatorManager
 * Shows and hide the Activity Indicator whenever needed.
 *
 */
class ActivityIndicatorManager {
    
    public static let shared = ActivityIndicatorManager()
    
    private var container: UIView?
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    func showActivityIndicator(uiView: UIView) {
        if container == nil {
            let container = UIView()
            container.backgroundColor = UIColor.clear
            
            let loadingView = UIView()
            loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            loadingView.center = uiView.center
            loadingView.backgroundColor = UIColor.black
            loadingView.clipsToBounds = true
            loadingView.layer.cornerRadius = 10
            
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40);
            activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
            activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
            
            loadingView.addSubview(activityIndicator)
            container.addSubview(loadingView)
            self.container = container
        }
        
        container?.frame = uiView.frame
        container?.center = uiView.center
        
        uiView.addSubview(container!)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        container?.removeFromSuperview()
    }
    
}
