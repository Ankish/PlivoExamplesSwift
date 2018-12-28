//
//  CallInfo.swift
//  OutgoingIncomingCall
//
//  Created by Plivo on 12/28/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import Foundation

// MARK: - CallInfo
class CallInfo : NSObject, NSCoding, NSKeyedUnarchiverDelegate {
    
    private(set) var displayName : String
    private(set) var number : String
    private(set) var createdDate : Date
    private(set) var isIncoming : Bool
    
    public var imageToShow : UIImage? {
        if isIncoming {
            return UIImage(named: "incomingCall")
        } else {
            return UIImage(named: "OutgoingCall")
        }
    }
    
    init(displayName : String,
         number : String,
         createdDate : Date,
         isIncoming : Bool) {
        
        self.displayName = displayName
        self.number = number
        self.createdDate = createdDate
        self.isIncoming = isIncoming
    }
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(number, forKey: "number")
        aCoder.encode(displayName, forKey: "displayName")
        aCoder.encode(createdDate, forKey: "createdDate")
        aCoder.encode(isIncoming, forKey: "isIncoming")
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard let number = aDecoder.decodeObject(forKey: "number") as? String,
            let createdDate = aDecoder.decodeObject(forKey: "createdDate") as? Date else {
                return nil
        }
        let displayName = aDecoder.decodeObject(forKey: "displayName") as? String ?? number
        let isIncoming = aDecoder.decodeBool(forKey: "isIncoming")
        self.init(displayName : displayName,number: number, createdDate: createdDate, isIncoming: isIncoming)
    }
    
    static func appendRecent(callInfo : CallInfo) {
        var recent = CallInfo.getRecents()
        recent.append(callInfo)
        
        NSKeyedArchiver.setClassName("RecentList", for: RecentList.self)
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(RecentList(recents: recent), toFile: RecentList.ArchiveURL.path)
        if !isSuccessfulSave {
            print("Failed to save RecentList...")
        }
    }
    
    static func getRecents() -> [CallInfo] {
        NSKeyedUnarchiver.setClass(RecentList.self, forClassName: "RecentList")
        let list = NSKeyedUnarchiver.unarchiveObject(withFile: RecentList.ArchiveURL.path) as? RecentList
        return list?.recents ?? []
    }
    
}

class RecentList : NSObject, NSCoding {
    
    static let ArchiveURL = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("RecentList")
    
    var recents : [CallInfo]
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(recents, forKey: "recents")
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        if let recents = aDecoder.decodeObject(forKey: "recents") as? [CallInfo] {
            self.init(recents: recents)
        } else {
            self.init(recents: [])
        }
    }
    
    init(recents : [CallInfo]) {
        self.recents = recents
        self.recents.sort(by: { (first,second) in
            return first.createdDate.compare(second.createdDate)  == .orderedDescending
        })
    }
}

