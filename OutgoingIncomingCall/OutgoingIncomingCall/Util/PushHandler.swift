//
//  PushHandler.swift
//  OutgoingIncomingCall
//
//  Created by Raja Sekar on 12/19/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import Foundation
import UserNotifications
import PushKit
import PlivoVoiceKit


extension AppDelegate :PKPushRegistryDelegate,UNUserNotificationCenterDelegate,PlivoEndpointDelegate  {
    
    // Register for VoIP notifications
    func voipRegistration() {
        Logger.logDebug(tag: "Appdelegate",message:"voipRegistration")
        let mainQueue = DispatchQueue.main
        // Create a push registry object
        let voipResistry = PKPushRegistry(queue: mainQueue)
        // Set the registry's delegate to self
        voipResistry.delegate = self as PKPushRegistryDelegate
        //Set the push type to VOIP
        voipResistry.desiredPushTypes = Set<AnyHashable>([PKPushType.voIP]) as? Set<PKPushType>
    }
    
    // MARK: PKPushRegistryDelegate
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        Logger.logDebug(tag: "Appdelegate",message:"pushRegistry:didInvalidatePushTokenForType:")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        Logger.logDebug(tag: "Appdelegate", message:"pushRegistry:didUpdatePushCredentials:forType:");
        
        if credentials.token.count == 0 {
            print("VOIP token NULL")
            return
        }
        Logger.logDebug(tag: "Appdelegate", message: "Credentials token: \(credentials.type)")
        Logger.logDebug(tag: "Appdelegate", message: "Credentials token: \(credentials.token)")
        //Note: Inorder to receive only Inapp calls and not while on background, comment out the following line and remove the respective capabilities in your Xcode project Target
        PlivoManager.sharedInstance.registerToken(credentials.token)
    }
    
    /* didReceiveIncomingPushWith
     * Received Voip push,hand over the data to Plivo SDK,that will trigger onIncomingCall method.
     */
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        Logger.logDebug(tag: "Appdelegate",message:"pushRegistry:didReceiveIncomingPushWithPayload:forType:")
        
        if (type == PKPushType.voIP) {
            DispatchQueue.main.async(execute: {() -> Void in
                PlivoManager.sharedInstance.relayVoipPushNotification(payload.dictionaryPayload)
            })
        }
    }
    
    
    // MARK: - PlivoEndpointDelegate method
    /* On an incoming call to a registered endpoint, this delegate receives
     a PlivoIncoming object.
     */
    func onIncomingCall(_ incoming: PlivoIncoming) {
        CallKitInstance.sharedInstance.reportNewIncomingCall(incoming : incoming)
    }
    
    /*
     * Returns the top controller which is visible
     * in screen
     *
     */
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let split = base as? UISplitViewController {
            if split.viewControllers.count > 1 {
                if split.viewControllers[1].presentedViewController != nil {
                    return topViewController(base: split.viewControllers[1])
                } else {
                    return topViewController(base: split.viewControllers.first)
                }
            } else if let controller = split.viewControllers.first {
                return topViewController(base: controller)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
    
}
