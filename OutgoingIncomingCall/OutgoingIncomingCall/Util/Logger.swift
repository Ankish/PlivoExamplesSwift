//
//  Logger.swift
//  OutgoingIncomingCall
//
//  Created by Plivo on 12/8/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import Foundation

public class Logger {
    static var enableLog = true
    
    /**
     * Logs all the errors
     *
     * @param tag     SimpleTag
     * @param message Error message
     */
    public static func logError(tag: String, message: String) {
        print("Plivo:" + tag + ":" + message)
    }
    
    /**
     * Logs debug messages if log level is <= Log.DEBUG
     *
     * @param tag     SimpleTag
     * @param message Error Message
     */
    public static func logDebug(tag: String, message: String) {
        if (enableLog) {
            print("Plivo:" + tag + ":" + message)
        }
    }
    
    public static func enableLog(enable: Bool) {
        Logger.enableLog = enable
    }
    
}
