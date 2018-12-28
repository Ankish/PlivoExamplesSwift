//
//  SplashViewController.swift
//  OutgoingIncomingCall
//
//  Created by Plivo on 12/13/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import UIKit
import PlivoVoiceKit

class SplashViewController: UIViewController {

    private let activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(activityIndicator)
        activityIndicator.color = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PlivoManager.sharedInstance.setDelegate(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let username = UserDefaultManager.shared.value(forKey: .username) as? String,!username.isEmpty,let password = UserDefaultManager.shared.value(forKey: .password) as? String,!password.isEmpty {
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
            PlivoManager.sharedInstance.login(withUserName: username, andPassword: password)
        } else {
            openLoginController()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        activityIndicator.center = self.view.center
    }
    
    private func openLoginController() {
        let loginController = LoginViewController.storyBoardController()
        self.present(loginController, animated: true, completion: nil)
    }

}
// MARK: - Plivo delegate
extension SplashViewController : PlivoEndpointDelegate  {
    
    /**
     *
     * Trigger when login successfully made.
     *
     */
    func onLogin() {
        Logger.logDebug(tag: "SplashViewController", message: "onLogin")
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.activityIndicator.stopAnimating()
            strongSelf.activityIndicator.isHidden = true
            
            let tabController = UIStoryboard.init(name: "Plivo", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
            strongSelf.present(tabController, animated: true, completion: nil)
            AppDelegate.shared.voipRegistration()
        }
    }
    
    /**
     *
     * Trigger when login failed
     *
     */
    func onLoginFailed() {
        Logger.logDebug(tag: "SplashViewController", message: "onLoginFailed")
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.activityIndicator.stopAnimating()
            strongSelf.activityIndicator.isHidden = true
            
            UserDefaultManager.shared.set(value: "", forKey: .username)
            UserDefaultManager.shared.set(value: "", forKey: .password)
            
            strongSelf.showAlert(title: NSLocalizedString("Login Failed", comment: ""), message: NSLocalizedString("Please check your username and password", comment: ""),okAction : { (_) in
                strongSelf.openLoginController()
            })
        }
    }
}

