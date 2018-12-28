//
//  APContact+Extension.swift
//  OutgoingIncomingCall
//
//  Created by Plivo on 12/28/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import Foundation
import APAddressBook

extension APContact {
 
    var contactName : String {
        if let firstName = self.name?.firstName, let lastName = self.name?.lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName = self.name?.firstName {
            return "\(firstName)"
        } else if let lastName = self.name?.lastName {
            return "\(lastName)"
        } else {
            return NSLocalizedString("Unknown", comment: "")
        }
    }
    
    var contactPhone : String? {
        if let phone = self.phones?.first?.number {
            return phone
        } else {
            return nil
        }
    }

}
