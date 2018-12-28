//
//  CallKitInstance.swift
//  OutgoingIncomingCall
//
//  Created by Raja Sekar on 12/17/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import Foundation
import CallKit
import AVFoundation
import PlivoVoiceKit

/**
 *
 * CallKitInstance
 * Handle All the Callkit related functinality
 *
 */
class CallKitInstance: NSObject,CXProviderDelegate, CXCallObserverDelegate {
    
    // MARK: - static variables
    //Singleton instance
    static let sharedInstance = CallKitInstance()
    
    // MARK: - properties
    private(set) var callUUID: UUID?
    private(set) var callKitProvider: CXProvider?
    private(set) var callKitCallController: CXCallController?
    private(set) var callObserver: CXCallObserver?
    private(set) var handle : String?
    
    // MARK: - Initializers
    override init() {
        super.init()
        
        let configuration = CXProviderConfiguration(localizedName: "Plivo")
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1
        callKitProvider = CXProvider(configuration: configuration)
        callKitCallController = CXCallController()
        callObserver = CXCallObserver()
        
        callKitProvider?.setDelegate(self, queue: DispatchQueue.main)
        callObserver?.setDelegate(self, queue: DispatchQueue.main)
    }
    
    // MARK: - CallKit Actions
    /* reportOutGoingCall
     * Need to call while placing an outgoing call,
     * which will initiate callkit instance method
     *
     */
    public func reportOutGoingCall(with uuid: UUID, handle: String) {
        if AppUtility.isNetworkAvailable(){
            switch AVAudioSession.sharedInstance().recordPermission {
                
            case AVAudioSession.RecordPermission.granted:
                Logger.logDebug(tag: "CallKitInstance", message:"Permission granted")
                Logger.logDebug(tag: "CallKitInstance", message:String(format : "Outgoing call uuid is: %@", uuid.uuidString))
                Logger.logDebug(tag: "CallKitInstance", message:"provider:performStartCallActionWithUUID:");
                
                let callHandle = CXHandle(type: .generic, value: handle)
                let startCallAction = CXStartCallAction(call: uuid, handle: callHandle)
                let transaction = CXTransaction(action:startCallAction)
                CallKitInstance.sharedInstance.callKitCallController?.request(transaction, completion: {(_ error: Error?) -> Void in
                    if error != nil {
                        Logger.logDebug(tag: "CallKitInstance", message: String(format : "StartCallAction transaction request failed: %@", error.debugDescription))
                        DispatchQueue.main.async(execute: {() -> Void in
                            Logger.logError(tag: "CallKitInstance", message: "Call start Action Failed")
                        })
                    }
                    else {
                        Logger.logDebug(tag: "CallKitInstance", message:"StartCallAction transaction request successful");
                        let callUpdate = CXCallUpdate()
                        callUpdate.remoteHandle = callHandle
                        callUpdate.supportsDTMF = true
                        callUpdate.supportsHolding = true
                        callUpdate.supportsGrouping = false
                        callUpdate.supportsUngrouping = false
                        callUpdate.hasVideo = false
                        
                        self.callUUID = uuid
                        self.handle = handle
                        
                        DispatchQueue.main.async(execute: {() -> Void in
                            CallKitInstance.sharedInstance.callKitProvider?.reportOutgoingCall(with: uuid, startedConnectingAt: Date())
                        })
                    }
                })
                break
            case AVAudioSession.RecordPermission.denied:
                Logger.logError(tag: "CallKitInstance", message:"Please go to settings and turn on Microphone service for incoming/outgoing calls.")
                break
            case AVAudioSession.RecordPermission.undetermined:
                // This is the initial state before a user has made any choice
                // You can use this spot to request permission here if you want
                break
            default:
                break
            }
            
        } else{
            Logger.logError(tag: "CallKitInstance", message: "No Internet Connection")
        }
        
    }
    
    /* performEndCallAction
     *
     * Need to call when hanging up any call
     *
     */
    public func performEndCallAction(with uuid: UUID) {
        DispatchQueue.main.async(execute: {() -> Void in
            Logger.logDebug(tag: "CallKitInstance", message: String(format : "performEndCallActionWithUUID: %@",uuid.uuidString))
            let endCallAction = CXEndCallAction(call: uuid)
            let trasanction = CXTransaction(action:endCallAction)
            CallKitInstance.sharedInstance.callKitCallController?.request(trasanction, completion: {(_ error: Error?) -> Void in
                if error != nil {
                    Logger.logError(tag: "CallKitInstance", message:String(format : "EndCallAction transaction request failed: %@", error.debugDescription))
                    
                    DispatchQueue.main.async(execute: {() -> Void in
                        PlivoManager.sharedInstance.stopAudioDevice()
                    })
                } else {
                    Logger.logError(tag: "CallKitInstance", message:"EndCallAction transaction request successful")
                }
            })
        })
    }
    
    /* performEndCallAction
     *
     * Need to call when new incoming voip comes.
     *
     */
    public func reportNewIncomingCall(incoming : PlivoIncoming) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSession.RecordPermission.granted:
            
            Logger.logDebug(tag: "CallKitInstance", message: "Permission granted")
            
            if (PlivoManager.sharedInstance.inCall == nil && PlivoManager.sharedInstance.outCall == nil) {
                /* log it */
                Logger.logDebug(tag: "CallKitInstance", message:String(format : "Incoming Call from %@", incoming.fromContact))
                Logger.logDebug(tag: "CallKitInstance", message:"Call id in incoming is:")
                Logger.logDebug(tag: "CallKitInstance", message:incoming.callId)
                /* assign incCall var */
                CallKitInstance.sharedInstance.callUUID = UUID()
                PlivoManager.sharedInstance.setUpIncomingCall(incomingCall: incoming)
                reportIncomingCall(from: incoming.endpointName, with: CallKitInstance.sharedInstance.callUUID!)
            } else {
                /*
                 * Reject the call when we already have active ongoing call
                 */
                incoming.reject()
                return
            }
            break
            
        case AVAudioSession.RecordPermission.denied:
            Logger.logDebug(tag: "CallKitInstance", message:"Pemission denied")
            incoming.reject()
            break
            
        case AVAudioSession.RecordPermission.undetermined:
            Logger.logDebug(tag: "CallKitInstance", message:"Request permission here")
            break
        default:
            break
        }
    }
    
    private func reportIncomingCall(from: String, with uuid: UUID) {
        let callHandle = CXHandle(type: .generic, value: from)
        let callUpdate = CXCallUpdate()
        callUpdate.remoteHandle = callHandle
        callUpdate.supportsDTMF = true
        callUpdate.supportsHolding = true
        callUpdate.supportsGrouping = false
        callUpdate.supportsUngrouping = false
        callUpdate.hasVideo = false
        
        handle = from
        
        CallKitInstance.sharedInstance.callKitProvider?.reportNewIncomingCall(with: uuid, update: callUpdate, completion: {(_ error: Error?) -> Void in
            if error != nil {
                Logger.logDebug(tag: "CallKitInstance", message: String(format : "Failed to report incoming call successfully: %@", error.debugDescription))
                PlivoManager.sharedInstance.stopAudioDevice()
            } else {
                Logger.logDebug(tag: "CallKitInstance", message:"Incoming call successfully reported.");
                PlivoManager.sharedInstance.configureAudioSession()
            }
        })
    }
    
    // MARK: - CXCallObserverDelegate
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded == true {
            Logger.logDebug(tag: "CallKitInstance", message:"CXCallState : Disconnected")
        } else  if call.hasConnected == true {
            Logger.logDebug(tag: "CallKitInstance", message:"CXCallState : Connected");
        } else if call.isOutgoing == true {
            Logger.logDebug(tag: "CallKitInstance", message:"CXCallState : Dialing");
        } else {
            Logger.logDebug(tag: "CallKitInstance", message:"CXCallState : Incoming");
        }
    }
    
    
    // MARK: - CXProvider Handling
    func providerDidReset(_ provider: CXProvider) {
        Logger.logDebug(tag: "CallKitInstance", message:"ProviderDidReset");
    }
    
    func providerDidBegin(_ provider: CXProvider) {
        Logger.logDebug(tag: "CallKitInstance", message:"providerDidBegin");
    }
    
    /* didActivate
     *
     * Need to start your audio Device
     *
     */
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        Logger.logDebug(tag: "CallKitInstance", message:"provider:didActivateAudioSession");
        PlivoManager.sharedInstance.startAudioDevice()
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        Logger.logDebug(tag: "CallKitInstance", message:"provider:didDeactivateAudioSession:");
    }
    
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        Logger.logDebug(tag: "CallKitInstance", message:"provider:timedOutPerformingAction:");
    }
    
    /* CXStartCallAction
     *
     * Trigger when Audio Session is configured
     * Need to create Outgoing call
     *
     */
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        Logger.logDebug(tag: "CallKitInstance", message:"provider:CXStartCallAction:");
        PlivoManager.sharedInstance.configureAudioSession()
        //Set extra headers
        let extraHeaders: [AnyHashable: Any] = [
            "X-PH-Header1" : "Value1",
            "X-PH-Header2" : "Value2"
        ]
        
        let dest: String = action.handle.value
        //Make the call
        PlivoManager.sharedInstance.call(withDest : dest, andHeaders : extraHeaders)
        action.fulfill(withDateStarted: Date())
    }
    
    /* CXSetHeldCallAction
     *
     * Trigger when user press held button from Callkit UI
     *
     */
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        if action.isOnHold {
            PlivoManager.sharedInstance.stopAudioDevice()
        }
        else {
            PlivoManager.sharedInstance.startAudioDevice()
        }
        action.fulfill()
    }
    
    /* CXSetMutedCallAction
     *
     * Trigger when user press mute/unmute button from Callkit UI
     *
     */
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
       PlivoManager.sharedInstance.isMuted = action.isMuted
    }
    
    /* CXAnswerCallAction
     *
     * Trigger when user answer the incoming call
     *
     */
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        Logger.logDebug(tag: "CallKitInstance", message:"provider:performAnswerCallAction:");
        
        //Answer the call
        CallKitInstance.sharedInstance.callUUID = action.callUUID
        PlivoManager.sharedInstance.inCall?.answer()
        
        let callController = CallViewController.storyBoardControllerForOutGoing(callerId: handle ?? "", isOutGoing: false)
        AppDelegate.topViewController()?.present(callController, animated: true, completion: nil)
        
        action.fulfill()
    }
    
    /* CXPlayDTMFCallAction
     *
     * Trigger when user enter the number from CallKit UI
     *
     */
    func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
        Logger.logDebug(tag: "CallKitInstance", message:"provider:performPlayDTMFCallAction:");
        let dtmfDigits: String = action.digits
        
        if let outGoing = PlivoManager.sharedInstance.outCall {
            outGoing.sendDigits(dtmfDigits)
        } else if let incoming = PlivoManager.sharedInstance.inCall {
            incoming.sendDigits(dtmfDigits)
        }
        
        action.fulfill()
    }
    
    /* CXEndCallAction
     *
     * Trigger when user hangup the call from CallKit UI
     *
     */
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        DispatchQueue.main.async(execute: {() -> Void in
            Logger.logDebug(tag: "CallKitInstance", message:"provider:performEndCallAction:");
            PlivoManager.sharedInstance.hangUp()
            action.fulfill()
        })
    }

}
