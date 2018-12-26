//
//  PlivoManager.swift
//  OutgoingIncomingCall
//
//  Created by Plivo on 12/7/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import Foundation
import PlivoVoiceKit

/**
 *
 * PlivoManager
 * Manages all the communication between Client and Plivo
 *
 * Need to call the method setCallDelegate / setLoginDelegate (based on required feature) inorder to
 * get respective callbacks
 *
 */
class PlivoManager : NSObject {
    
    // MARK: - static variables
    static let sharedInstance = PlivoManager()
    
    // MARK: - private variables
    private var endpoint: PlivoEndpoint = PlivoEndpoint(debug: true)
    private(set) var outCall: PlivoOutgoing?
    private(set) var inCall :  PlivoIncoming?
    
    // MARK: - public variables
    public var isMuted: Bool = false {
        didSet {
            if isMuted {
                outCall?.mute()
            } else {
                outCall?.unmute()
            }
        }
    }
    
    public var isHold: Bool = false {
        didSet {
            if isHold {
                outCall?.hold()
                PlivoManager.sharedInstance.stopAudioDevice()
            } else {
                outCall?.unhold()
                PlivoManager.sharedInstance.startAudioDevice()
            }
        }
    }
    
    // MARK: - Initializers
    override init() {
        super.init()
        
    }
    
    // MARK: - Methods
    
    // To register with SIP Server
    func login(withUserName userName: String, andPassword password: String) {
        endpoint.login(userName, andPassword: password)
    }
    
    //To unregister with SIP Server
    func logout() {
        endpoint.logout()
    }
    
    //To call sip/number
    func call(withDest dest: String, andHeaders headers: [AnyHashable: Any]) {
        func isValidEmail(str:String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: str)
        }
        var sipUri: String = "sip:\(dest)@phone.plivo.com"
        if dest.contains("sip:"){
            sipUri = dest
        } else if isValidEmail(str: dest){
            sipUri = dest
        }
        if let call = endpoint.createOutgoingCall() {
            outCall = call
            outCall?.call(sipUri, headers: headers)
        }
    }
    
    func setDelegate(_ controllerDelegate: NSObject) {
        endpoint.delegate = controllerDelegate
    }

    //Register pushkit token
    func registerToken(_ token: Data) {
        endpoint.registerToken(token)
    }
    
    //receive and pass on (information or a message)
    func relayVoipPushNotification(_ pushdata: [AnyHashable: Any]) {
        endpoint.relayVoipPushNotification(pushdata)
    }
    
    func sendDigits(digits : String) {
        Logger.logDebug(tag: "PlivoManager", message: "sendDigits \(digits)")
        outCall?.sendDigits(digits)
    }
    
    //To Configure Audio
    func configureAudioSession() {
        endpoint.configureAudioDevice()
    }
    
    /*
     * To Start Audio service
     * To handle Audio Interruptions
     * AVAudioSessionInterruptionTypeEnded
     */
    func startAudioDevice() {
        endpoint.startAudioDevice()
    }
    
    /*
     * To Start Audio service
     * To handle Audio Interruptions
     * AVAudioSessionInterruptionTypeBegan
     */
    func stopAudioDevice() {
        endpoint.stopAudioDevice()
    }
    
    /*
     * To Hang up Outgoing Call
     *
     */
    func hangUp() {
        self.stopAudioDevice()
        
        if let outCall = outCall {
            outCall.hangup()
        } else if let inCall = inCall {
            if inCall.state != Ongoing {
                inCall.reject()
            } else {
                inCall.hangup()
            }
        }
        
        if let uuid = CallKitInstance.sharedInstance.callUUID {
            CallKitInstance.sharedInstance.performEndCallAction(with: uuid)
        }
        
        self.inCall = nil
        self.outCall = nil
    }
    
    
    /*
     * Setting up the incoming Call
     */
    public func setUpIncomingCall(incomingCall : PlivoIncoming?) {
        self.inCall = incomingCall
        outCall = nil
    }
    
    /*
     * Setting up the outgoing Call
     */
    public func setUpOutGoingCall(outGoingCall : PlivoOutgoing?) {
        self.outCall = outGoingCall
        inCall = nil
    }
}
