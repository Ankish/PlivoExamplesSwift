//
//  PlivoIncoming+Extension.swift
//  OutgoingIncomingCall
//
//  Created by Plivo on 12/28/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import Foundation
import PlivoVoiceKit

extension PlivoIncoming {
    var endpointName : String {
        let contact = self.fromContact.components(separatedBy: " ")
        if (contact.count > 0) {
            var endpoint = contact[0].dropFirst()
            endpoint = endpoint.dropLast()
            return String(endpoint)
        } else {
            return self.fromContact
        }
    }
}
