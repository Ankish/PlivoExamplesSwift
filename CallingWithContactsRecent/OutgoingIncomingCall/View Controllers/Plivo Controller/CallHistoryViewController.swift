//
//  CallHistoryViewController.swift
//  OutgoingIncomingCall
//
//  Created by Plivo on 12/28/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import UIKit

class CallHistoryViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var callHistoryTableView: UITableView!
    @IBOutlet weak var noRecentCallsLabel: UILabel!
    
    // MARK: - Properties
    private var recents : [CallInfo] = CallInfo.getRecents()
    
    // MARK: - Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.callHistoryTableView.delegate = self
        self.callHistoryTableView.dataSource = self
        
        self.callHistoryTableView.tableFooterView = UIView()
        
        self.title = NSLocalizedString("Recents", comment: "")
        let signout = UIBarButtonItem(title: NSLocalizedString("Logout", comment: ""), style: .plain, target: self, action: #selector(didPressedLogout))
        self.navigationItem.rightBarButtonItem = signout
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: NSNotification.Name(rawValue: AppUtility.CallHistoryRefreshKey), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: AppUtility.CallHistoryRefreshKey), object: nil)
    }
    
    // MARK: - Action methods
    @objc
    private func refresh() {
        recents = CallInfo.getRecents()
        DispatchQueue.main.async {
            self.callHistoryTableView.reloadData()
        }
    }
    
    @objc
    private func didPressedLogout() {
        UserDefaultManager.shared.removeAll()
        PlivoManager.sharedInstance.logout()
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - UITableView Deleages, DataSources
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if (recents.count > 0) {
           noRecentCallsLabel.isHidden = true
        } else {
            noRecentCallsLabel.isHidden = false
        }
        
        return recents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let editprofileIdentifier: String = "CallHistory"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: editprofileIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: editprofileIdentifier)
        }
        
        let recent = self.recents[indexPath.row]
        cell?.textLabel?.text = recent.displayName
        cell?.detailTextLabel?.text = recent.createdDate.monthDateYear
        cell?.imageView?.image = recent.imageToShow
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recent = self.recents[indexPath.row]
        
        let callController = CallViewController.storyBoardControllerForOutGoing(callerId: AppUtility.getUserNameWithoutDomain(recent.number),callerName : recent.displayName,isOutGoing: true)
        self.present(callController, animated: true, completion: nil)
    }
}

