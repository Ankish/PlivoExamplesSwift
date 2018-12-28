//
//  ContactsViewController.swift
//  OutgoingIncomingCall
//
//  Created by Plivo on 12/28/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import UIKit
import APAddressBook
import libPhoneNumber_iOS

class ContactsViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    // MARK: - Properties
    private var phoneContacts = [APContact]()
    private var contactsSegmentControl: UISegmentedControl?
    private var filterContacts = [APContact]()
    
    private let addressBook = APAddressBook()
    private let searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Outlet variables
    @IBOutlet private weak var contactsTableView: UITableView!
    @IBOutlet private weak var noContactsLabel: UILabel!
    
    // MARK: - Life cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        addressBook.fieldsMask = [APContactField.default, APContactField.thumbnail]
        addressBook.sortDescriptors = [NSSortDescriptor(key: "name.firstName", ascending: true),
                                       NSSortDescriptor(key: "name.lastName", ascending: true)]
        
        addressBook.filterBlock = {
            (contact: APContact) -> Bool in
            if let phones = contact.phones {
                return phones.count > 0
            } else {
                return false
            }
        }
        
        addressBook.startObserveChanges {
            [unowned self] in
            self.loadContacts()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadContacts()
        
        self.contactsTableView.delegate = self
        self.contactsTableView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        contactsTableView.tableHeaderView = searchController.searchBar
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        
        self.contactsTableView.tableFooterView = UIView()
        
        self.title = NSLocalizedString("Contacts", comment: "")
        let signout = UIBarButtonItem(title: NSLocalizedString("Logout", comment: ""), style: .plain, target: self, action: #selector(didPressedLogout))
        self.navigationItem.rightBarButtonItem = signout
    }
    
    @objc
    private func didPressedLogout() {
        UserDefaultManager.shared.removeAll()
        PlivoManager.sharedInstance.logout()
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - APContacts
    func loadContacts() {
        addressBook.loadContacts {
            [weak self] (contacts: [APContact]?, error: Error?) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.phoneContacts = [APContact]()
            
            if let contacts = contacts {
                strongSelf.phoneContacts = contacts
                
                strongSelf.filterContacts = contacts
                strongSelf.contactsTableView?.reloadData()
            } else if let error = error {
                Logger.logError(tag: "ContactsViewController", message: "error in load contacts \(error.localizedDescription)")
            }
        }
    }
    
    
    // MARK: - UITableView
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    /**
     * Actual array
     * Search results array
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (filterContacts.count > 0) {
            noContactsLabel.isHidden = true
        } else {
            noContactsLabel.isHidden = false
        }
        
        return filterContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let editprofileIdentifier: String = "CallHistory"
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: editprofileIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: editprofileIdentifier)
        }
        let contact: APContact = filterContacts[Int(indexPath.row)]
        cell?.textLabel?.text = contact.contactName
        cell?.detailTextLabel?.text = contact.contactPhone ?? "N/A"
        cell?.imageView?.image = UIImage(named: "ContactsTabbarIcon")
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let contactDetail: APContact = filterContacts[Int(indexPath.row)]
        
        let callNumber: String?
        if let number = contactDetail.contactPhone {
            var phoneNumber = (number as NSString).replacingOccurrences(of: "\\s", with: "", options: .regularExpression, range: NSRange(location: 0, length: number.count))
            phoneNumber = phoneNumber.replacingOccurrences(of: "(", with: "")
            phoneNumber = phoneNumber.replacingOccurrences(of: ")", with: "")
            phoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "")
            callNumber = phoneNumber
        } else {
            callNumber = nil
        }
        
        if let number = callNumber {
            let numberUtil = NBPhoneNumberUtil()
            var formattedPhoneNumber : String = number
            if let nsNumber = try? numberUtil.parse(number, defaultRegion: NSLocale.current.regionCode) {
                formattedPhoneNumber = (try? numberUtil.format(nsNumber, numberFormat: .E164)) ?? number
            }

            Logger.logDebug(tag: "ContactsViewController", message: "formatted Phone number \(formattedPhoneNumber)")
            
            let callController = CallViewController.storyBoardControllerForOutGoing(callerId: AppUtility.getUserNameWithoutDomain(formattedPhoneNumber),callerName : contactDetail.contactName,isOutGoing: true)
            self.present(callController, animated: true, completion: nil)
            
            self.searchController.isActive = false
        } else {
            self.showAlert(title: NSLocalizedString("Invalid Number", comment: ""), message: NSLocalizedString("Please select a valid phone number", comment: ""))
        }
        
    }
    
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText: String = searchController.searchBar.text {
            
            let strippedString: String = searchText.trimmingCharacters(in: CharacterSet.whitespaces)
            
            // break up the search terms (separated by spaces)
            var searchItems: [String]? = nil
            if (strippedString.count) > 0 {
                searchItems = strippedString.components(separatedBy: " ")
            }
            
            // build all the "AND" expressions for each value in the searchString
            var andMatchPredicates = [Any]()
            
            if(searchItems != nil) {
                
                for searchString: String in searchItems! {
                    // each searchString creates an OR predicate for: name, yearIntroduced, introPrice
                    //
                    // example if searchItems contains "iphone 599 2007":
                    //      name CONTAINS[c] "iphone"
                    //      name CONTAINS[c] "599", yearIntroduced ==[c] 599, introPrice ==[c] 599
                    //      name CONTAINS[c] "2007", yearIntroduced ==[c] 2007, introPrice ==[c] 2007
                    //
                    var searchItemsPredicate = [Any]()
                    // Below we use NSExpression represent expressions in our predicates.
                    // NSPredicate is made up of smaller, atomic parts: two NSExpressions (a left-hand value and a right-hand value)
                    // name field matching
                    var lhs = NSExpression(forKeyPath: "name.compositeName")
                    var rhs = NSExpression(forConstantValue: searchString)
                    var finalPredicate: NSPredicate? = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: .contains, options: .caseInsensitive)
                    searchItemsPredicate.append(finalPredicate as Any)
                    // yearIntroduced field matching
                    let numberFormatter = NumberFormatter()
                    numberFormatter.numberStyle = .none
                    let targetNumber = numberFormatter.number(from: searchString)
                    if targetNumber != nil {
                        // searchString may not convert to a number
                        lhs = NSExpression(forKeyPath: "phones")
                        rhs = NSExpression(forConstantValue: targetNumber)
                        finalPredicate = NSComparisonPredicate(leftExpression: lhs, rightExpression: rhs, modifier: .direct, type: .equalTo, options: .caseInsensitive)
                        searchItemsPredicate.append(finalPredicate as Any)
                    }
                    // at this OR predicate to our master AND predicate
                    let orMatchPredicates:NSCompoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates:searchItemsPredicate as! [NSPredicate])
                    andMatchPredicates.append(orMatchPredicates)
                }
            }
            // match up the fields of the Product object
            let finalCompoundPredicate:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:andMatchPredicates as! [NSPredicate])
            filterContacts = phoneContacts.filter { finalCompoundPredicate.evaluate(with: $0) }
            
            self.contactsTableView.reloadData()
        }
    }
    
}

