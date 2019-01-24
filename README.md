# Plivo Voice Swift Quickstart for iOS
![Login](https://github.com/Ankish/PlivoExamplesSwift/blob/master/Images/Login.png)
![DialPad](https://github.com/Ankish/PlivoExamplesSwift/blob/master/Images/DialPad.png)
![Calling](https://github.com/Ankish/PlivoExamplesSwift/blob/master/Images/Calling.png)
![Contacts](https://github.com/Ankish/PlivoExamplesSwift/blob/master/Images/Tab_Contacts.jpg)
![Recents](https://github.com/Ankish/PlivoExamplesSwift/blob/master/Images/Tab_Recents.jpg)


## Get started with Voice on iOS:
1) [Quickstart](https://github.com/Ankish/PlivoExamplesSwift#1-quickstart) - Run the quickstart apps
2) [Integrating into your app](https://github.com/Ankish/PlivoExamplesSwift#2-examples-and-integration-into-your-existing-apps) Details of simple integration of various call features into your existing apps
3) [More Documentation](https://github.com/Ankish/PlivoExamplesSwift#3-more-documentation) - More documentation related to the Voice iOS SDK
4) [Issues and Support](https://github.com/Ankish/PlivoExamplesSwift#4-issues-and-support) - Filing issues and general support

### 1) Quickstart
* [Installation](https://github.com/Ankish/PlivoExamplesSwift#install-the-plivovoicekit-framework-using-cocoapods) - Install the PlivoVoiceKit framework using Cocoapods
* [CreateEndpoints](https://github.com/Ankish/PlivoExamplesSwift#create-endpoints) - Create User Endpoints in Plivo
* [Run the App](https://github.com/Ankish/PlivoExamplesSwift#run-the-app) - Run the app in Xcode and make calls
* [VoIP Service Certificate](https://github.com/Ankish/PlivoExamplesSwift#voip-service-certificate) - Configuring VoIP Service Certificate and push credentials.

#### Install the PlivoVoiceKit framework using Cocoapods
If you are new to iOS development, please download and setup the [Xcode IDE](https://developer.apple.com/xcode/) 

[Cocoapods]((https://cocoapods.org/)) - Its an Xcode framework dependency manager. You can install external frameworks using this manager.

It's easy to install the Voice framework if you manage your dependencies using [Cocoapods](https://cocoapods.org/). Simply add the following to your Podfile:
```
pod 'PlivoVoiceKit'
```
Note: You may need to update the [CocoaPods Master](https://github.com/CocoaPods/Specs) Spec Repo by running pod repo update master in order to fetch the latest specs for Plivo framework.

#### Create Endpoints
Endpoint - A Plivo endpoint, also known as SIP endpoint, can be any IP phone, mobile phone, wireless device, PDA, laptop or desktop PC that uses the Session Initiation Protocol (SIP) to perform communications operations. - [Plivo Endpoint](https://www.plivo.com/docs/getting-started/sip-endpoint/)
[Signup](https://console.plivo.com/accounts/register/) and [create endpoints](https://manage.plivo.com/accounts/login/) with Plivo. 
Each Endpoint is associated with a Username and password, which is used to authenticate. 
![EndPoint](https://github.com/Ankish/PlivoExamplesSwift/blob/master/Images/EndPoint.png)

#### Run the app
Clone or download the repo.

Open the *.xcworkspace.

Build and run the app.

Enter sip endpoint username and password.

After successful login make Voice calls by entering Mobile/Landline numbers or SIP Endpoints.
![Demo](https://github.com/Ankish/PlivoExamplesSwift/blob/master/Images/initial_demo.gif)
#### VoIP Service Certificate

Voice-over-IP (VoIP) apps register for UIRemoteNotificationTypeVoIP push notifications. Using push notifications eliminates the need for a timeout handler to check in with the VoIP service. Instead, when a calls arrives for the user, the VoIP service sends a VoIP push notification to the user’s device. Upon receiving this notification, the device launches or wakes the app as needed so that it can handle the incoming call.
More info and best practices at [VOIP](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/OptimizeVoIP.html)

[Setting up VoIP Service Certificate](https://www.plivo.com/docs/sdk/ios/setting-up-push-credentials/)

Create a VoIP Service Certificate and set Push Credentials with your VoIP Service Certificate. Also explains the various Xcode settings to integrate [Apple's CallKit](https://developer.apple.com/documentation/callkit)

CallKit - CallKit lets you integrate your calling services with the system, making it easier for users to receive calls and to manage calls from your app and from other calling apps.

### 2) Examples and Integration into your existing apps
This section describes the various features of the voice SDK and its easy integration into your existing apps.
Copy the `Util` folder for quick integration.
![Utils](https://github.com/Ankish/PlivoExamplesSwift/blob/master/Images/add_util.gif)

Note: [PlivoManger.swift](https://github.com/Ankish/PlivoExamplesSwift/blob/master/OutGoingCall/OutGoingCall/Util/PlivoManager.swift). PlivoManager manages the login, calling to a sip URI/phone number and all other call related actions. Its alread included in the copied `Util` folder in previous step.

#### Integrating login
PlivoEndpointDelegate - Set of predefined callback functions defined in the framework. 
Conform to PlivoEndpointDelegate to your Login Controller which receives call backs for login and calls related features. 

Set your delegate conformance to Plivo SDK by calling the setDelegate() method.

```
PlivoManager.sharedInstance.setDelegate(self)
```

Pass your Plivo endpoint username and password.

```
PlivoManager.sharedInstance.login(withUserName: userName, andPassword: password)
```

Once Plivo authenticates, you will receive a call back via OnLogin()/OnLoginFailed(). After successful login you are ready to present the dialpad and make calls.

Check [LoginViewController.swift](https://github.com/Ankish/PlivoExamplesSwift/blob/master/OutGoingCall/OutGoingCall/View%20Controllers/LoginViewController.swift) and SplashViewController.swift for more details. 

Note: You will need to authenticate every app startup session with the login call inorder to instantiate the framework to make and receive calls.

#### Integrating only outgoing calls
For integrating only outgoing calls refer to the project in the folder [OutGoingCall](https://github.com/Ankish/PlivoExamplesSwift/tree/master/OutGoingCall)

1) Drag and Drop  [DialPadViewController.swift](https://github.com/Ankish/PlivoExamplesSwift/blob/master/OutGoingCall/OutGoingCall/View%20Controllers/Plivo%20Controller/DialPadViewController.swift), if you intend to use the provided Dialpad UI in your app for user to enter a Phone number.
     Customized version of [Dialpad](https://github.com/jconst/JCDialPad) is used in the project, copy External > Dial Pad complete folder in your project.

Add these to your <ProjectName>-Bridging-Header.h
```
#import "JCDialPad.h"
#import "JCPadButton.h"
```
More about [Bridging header](https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_objective-c_into_swift)

There is already an integration of DialPad with libPhoneNumber_iOS to format the phone numbers with the country code, you can as well remove or implement your own formatting.
To integrate libPhoneNumber, add this in your PodFile
```
pod 'libPhoneNumber-iOS', '0.9.3'
```

2) Drag and Drop  [CallViewController.swift](https://github.com/Ankish/PlivoExamplesSwift/blob/master/OutGoingCall/OutGoingCall/View%20Controllers/Plivo%20Controller/CallViewController.swift) - This manages the complete calling functionality with conformance to PlivoEndpointDelegate. Initialize the controller with a number or sip endpoint and present to initiate the call.
For example, you could simple trigger an outgoing call to a number with:
```
let callController = CallViewController.storyBoardControllerForOutGoing(callerId: number)
self.present(callController, animated: true, completion: nil)
```

3) Drag and Drop  [Plivo.storyboard](https://github.com/Ankish/PlivoExamplesSwift/tree/master/OutGoingCall/OutGoingCall/Storyboards)- Contains the necessary iOS Storyboard Interface for dialpad and calling features.
   Also copy the `Assets.xcassets`, this has all calling related assets and icons used.

#### Integrating outgoing and incoming calls
For integrating outgoing and incoming calls refer to the project in the folder [OutgoingIncomingCall](https://github.com/Ankish/PlivoExamplesSwift/tree/master/OutgoingIncomingCall) and follow the [Integrating only outgoing calls](https://github.com/Ankish/PlivoExamplesSwift/#integrating-only-outgoing-calls) above.

Project configuration for Incoming calls on background modes:
In Project's Target Capabilities Section:

For Configuring VoIP Service Certificate and push credentials - Check [VoIP Service Certificate](https://github.com/Ankish/PlivoExamplesSwift#voip-service-certificate)

i) Select the Background Modes and enable the following items - 
    
    Background Modes
    ✅ Voice over IP
    
    ✅ Remote Notifications
    
    ✅ Audio,Airplay and Picture in Picture
    
ii)  `✅ Push Notifications`

Note: Inorder to receive calls only when the app is active, checkout [PushHandler](https://github.com/Ankish/PlivoExamplesSwift/blob/master/OutgoingIncomingCall/OutgoingIncomingCall/Util/PushHandler.swift)

#### Integrating Contacts and Recents
For quick integration of Contacts and Recents we have added an example project. Checkout [CallingWithContactsRecent](https://github.com/Ankish/PlivoExamplesSwift/tree/master/CallingWithContactsRecent)
ContactsViewController - Integrate this to fetch and search all local contacts to make calls using Plivo.
CallHistoryViewController - This displays the recents call logs and enables quick calling to your recents.

Note:
CallKit and related features might not work in Simulator due to its default designed limitations.

### 3) More Documentation
You can find more documentation on getting started as well as our latest AppleDoc below:
* [Api Reference](https://api-reference.plivo.com/latest/curl/resources/call/make-a-call)
* [Docs](https://www.plivo.com/docs/getting-started/)
* [SDK details](https://www.plivo.com/docs/sdk/ios/v2/)
* [Plivo Branding page](https://www.plivo.com/press/)

### 4) Issues and Support
Please file any issues you find here on Github: [Voice Swift Quickstart Issues](https://github.com/Ankish/PlivoExamplesSwift/issues). 
Please ensure that you are not sharing any Personally Identifiable Information(PII) or sensitive account information (API keys, credentials, etc.) when reporting an issue.
For general inquiries related to the Voice SDK you can file a [support ticket](https://support.plivo.com/support/home).
