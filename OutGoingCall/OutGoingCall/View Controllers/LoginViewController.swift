//
//  LoginViewController.swift
//  OutGoingCall
//
//  Created by Plivo on 12/7/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import UIKit
import PlivoVoiceKit

class LoginViewController: UITableViewController {

    // MARK: - class method
    /**
     *  Story BoardController
     *
     * Initiate DialPadViewController
     */
    class func storyBoardController() -> LoginViewController {
        let vc : LoginViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        
        return vc
    }
    
    // MARK: - Outlet variables
    @IBOutlet private weak var appTitleLabel: UILabel!
    //Table view cell views
    @IBOutlet private weak var signInButton: UIButton!
    @IBOutlet private weak var userNameField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!

    private let activityIndicator = UIActivityIndicatorView()
    private let plivoColor = UIColor.init(red: 0.1686, green: 0.6901, blue: 0.1921, alpha: 1)
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PlivoManager.sharedInstance.setDelegate(self)
        
        setUp()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        activityIndicator.center = self.view.center

        self.signInButton?.layer.cornerRadius = (self.signInButton?.frame.height ?? 0) / 2
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Private methods
    
    /**
     * Initial setup for UI and adding table view delegate and regerstring cells
     */
    
    private func setUp() {
        // adding observers for the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.userNameField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Username", comment: ""), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black.withAlphaComponent(0.5)])
        self.userNameField.delegate = self
    
        self.passwordField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Password", comment: ""), attributes: [NSAttributedString.Key.foregroundColor : UIColor.black.withAlphaComponent(0.5)])
        self.passwordField.isSecureTextEntry = true
        self.passwordField.delegate = self
        
        self.signInButton.setTitle(NSLocalizedString("LOGIN", comment: ""), for: .normal)
        self.enableLogin()
        
        self.userNameField.text = ""
        self.passwordField.text = ""
        
        self.appTitleLabel.text = NSLocalizedString("Plivo", comment: "")
       
        activityIndicator.color = UIColor.black
        self.view.addSubview(activityIndicator)
        
        self.tableView.backgroundColor = UIColor.white
        self.tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        
    }
    
    private func disableLogin() {
        self.signInButton.backgroundColor = plivoColor.withAlphaComponent(0.6)
        self.signInButton.isEnabled = false
    }
    
    private func enableLogin() {
        self.signInButton.backgroundColor = plivoColor
        self.signInButton.isEnabled = true
    }
    
    private func doLogin(userName : String,password : String) {
        self.disableLogin()
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
        PlivoManager.sharedInstance.login(withUserName: userName, andPassword: password)
    }
    
    // MARK: - Action methods
    
    /**
     * save the user name and open the landing screen
     */
    
    @IBAction func signInButtonAction(_ sender: Any) {
        if let name = self.userNameField.text,!name.isEmpty,let password = self.passwordField.text,!password.isEmpty {
            self.doLogin(userName : AppUtility.getUserNameWithoutDomain(name),password : password)
        } else {
            self.showAlert(title : NSLocalizedString("Error!", comment: ""),message : NSLocalizedString("Username and Password can't be empty.", comment: ""))
        }
    }
    
    @objc
    private func keyboardWillAppear(_ note: Notification) {
        if self.userNameField.isFirstResponder,let indexPath = self.indexPath(forView: self.userNameField) {
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        } else if self.passwordField.isFirstResponder,let indexPath = self.indexPath(forView: self.passwordField) {
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @objc
    private func keyboardWillHideNotification(_ note: Notification) {
        
    }
    
    /**
     * returns the indexpath of the cell in which the view presented.
     */
    func indexPath(forView: UIView) -> IndexPath? {
        let viewCenterRelativeToTableview = self.tableView.convert(CGPoint.init(x: forView.bounds.midX, y: forView.bounds.midY), from: forView)
        return self.tableView.indexPathForRow(at: viewCenterRelativeToTableview)
    }
}
// MARK: - UITextFieldDelegate
extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
// MARK: - Plivo delegate
extension LoginViewController : PlivoEndpointDelegate  {
    
    /**
     *
     * Trigger when login successfully made.
     *
     */
    func onLogin() {
        Logger.logDebug(tag: "LoginViewController", message: "onLogin")
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.enableLogin()
            
            strongSelf.activityIndicator.stopAnimating()
            strongSelf.activityIndicator.isHidden = true
            
            UserDefaultManager.shared.set(value: AppUtility.getUserNameWithoutDomain(strongSelf.userNameField.text ?? ""), forKey: .username)
            UserDefaultManager.shared.set(value: strongSelf.passwordField.text ?? "", forKey: .password)
            
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
        Logger.logDebug(tag: "LoginViewController", message: "onLoginFailed")
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.enableLogin()
            strongSelf.activityIndicator.stopAnimating()
            strongSelf.activityIndicator.isHidden = true
            
            strongSelf.showAlert(title: NSLocalizedString("Login Failed", comment: ""), message: NSLocalizedString("Please check your username and password", comment: ""))
        }
    }
}

