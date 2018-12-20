//
//  SplashViewController.swift
//  OutGoingCall
//
//  Created by Plivo on 12/13/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import UIKit
import PlivoVoiceKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        PlivoManager.sharedInstance.setDelegate(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let username = UserDefaultManager.shared.value(forKey: .username) as? String,!username.isEmpty,let password = UserDefaultManager.shared.value(forKey: .password) as? String,!password.isEmpty {
            ActivityIndicatorManager.shared.showActivityIndicator(uiView: UIApplication.shared.keyWindow ?? self.view)
            PlivoManager.sharedInstance.login(withUserName: username, andPassword: password)
        } else {
            openLoginController()
        }
        
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
            
            ActivityIndicatorManager.shared.hideActivityIndicator()
            
            let dialPadController = DialPadViewController.storyBoardController()
            strongSelf.present(dialPadController, animated: true, completion: nil)
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
            
            ActivityIndicatorManager.shared.hideActivityIndicator()
            UserDefaultManager.shared.set(value: "", forKey: .username)
            UserDefaultManager.shared.set(value: "", forKey: .password)
            
            strongSelf.showAlert(title: NSLocalizedString("Login Failed", comment: ""), message: NSLocalizedString("Please check your username and password", comment: ""),okAction : { (_) in
                strongSelf.openLoginController()
            })
        }
    }
}

