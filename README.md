# Plivo Voice Swift Quickstart for iOS
![Login](https://github.com/Ankish/PlivoExamplesSwift/blob/feature/OutgoingCallEg/Images/Login.png)
![DialPad](https://github.com/Ankish/PlivoExamplesSwift/blob/feature/OutgoingCallEg/Images/DialPad.png)
![Calling](https://github.com/Ankish/PlivoExamplesSwift/blob/feature/OutgoingCallEg/Images/Calling.png)

## Get started with Voice on iOS:
1) [Quickstart](https://gist.github.com/Ankish/ccd5ce325c282baad0295aa9051e52d3#1quickstart) - Run the quickstart apps
2) [Integrating into your app](https://gist.github.com/Ankish/ccd5ce325c282baad0295aa9051e52d3#2-examples-and-integration-into-your-existing-apps) Details of simple integration of various call features into your existing apps
3) [More Documentation](https://gist.github.com/Ankish/ccd5ce325c282baad0295aa9051e52d3#3-more-documentation) - More documentation related to the Voice iOS SDK
4) [Issues and Support](https://gist.github.com/Ankish/ccd5ce325c282baad0295aa9051e52d3#4-issues-and-support) - Filing issues and general support

### 1) Quickstart
* [Installation](https://gist.github.com/Ankish/ccd5ce325c282baad0295aa9051e52d3#install-the-plivovoicekit-framework-using-cocoapods) - Install the PlivoVoiceKit framework using Cocoapods
* [CreateEndpoints](https://gist.github.com/Ankish/ccd5ce325c282baad0295aa9051e52d3#create-endpoints) - Create User Endpoints in Plivo
* [Run the App](https://gist.github.com/Ankish/ccd5ce325c282baad0295aa9051e52d3#run-the-app) - Run the app in Xcode and make calls
* [VoIP Service Certificate](https://gist.github.com/Ankish/ccd5ce325c282baad0295aa9051e52d3#run-the-app) - Configuring VoIP Service Certificate and push credentials.

#### Install the PlivoVoiceKit framework using Cocoapods
It's easy to install the Voice framework if you manage your dependencies using Cocoapods. Simply add the following to your Podfile:
```
pod 'PlivoVoiceKit'
```
Note: You may need to update the [CocoaPods Master](https://github.com/CocoaPods/Specs) Spec Repo by running pod repo update master in order to fetch the latest specs for Plivo framework.

#### Create Endpoints
[Signup](https://console.plivo.com/accounts/register/) and [create endpoints](https://manage.plivo.com/accounts/login/) with Plivo. 
Each Endpoint is associated with a Username and password, which is used to authenticate. 
![EndPoint](https://github.com/Ankish/PlivoExamplesSwift/blob/feature/OutgoingCallEg/Images/EndPoint.png)

#### Run the app
Clone or download the repo.

Open the *.xcworkspace.

Build and run the app.

Enter sip endpoint username and password.

After successful login make Voice calls by entering Mobile/Landline numbers or SIP Endpoints.

#### VoIP Service Certificate
[Setting up VoIP Service Certificate](https://www.plivo.com/docs/sdk/ios/setting-up-push-credentials/)

Create a VoIP Service Certificate and set Push Credentials with your VoIP Service Certificate. Also explains the various Xcode settings to integrate Apple's CallKit

### 2) Examples and Integration into your existing apps
This section describes the various features of the voice SDK and its easy integration into your existing apps.

#### PlivoManager
Copy the [PlivoManger.swift](https://github.com/Ankish/PlivoExamplesSwift/blob/feature/OutgoingCallEg/OutGoingCall/OutGoingCall/Util/PlivoManager.swift)  file in your project. PlivoManager manages the login, calling to a sip URI/phone number and all other call related actions.

#### Integrating login
Conform to PlivoEndpointDelegate to your Controller which receives call backs for login and calls related features. Check [LoginViewController.swift](https://github.com/Ankish/PlivoExamplesSwift/blob/feature/OutgoingCallEg/OutGoingCall/OutGoingCall/View%20Controllers/LoginViewController.swift) for more details. Note: You will need to authenticate every app startup session with the login call.

Set your delegate conformance to Plivo SDK by calling the setDelegate() method.

```
PlivoManager.sharedInstance.setDelegate(self)
```

Pass your Plivo endpoint username and password.

```
PlivoManager.sharedInstance.login(withUserName: userName, andPassword: password)
```

Once Plivo authenticates, you will receive a call back via OnLogin()/OnLoginFailed(). After successful login you are ready to present the dialpad and make calls.

#### Integrating outgoing calls
Drag and Drop 
1) [DialPadViewController.swift](https://github.com/Ankish/PlivoExamplesSwift/tree/feature/OutgoingCallEg/OutGoingCall/OutGoingCall/View%20Controllers/Plivo%20Controller), if you intend to use the provided Dialpad UI in your app for user to enter a SIP URI/Phone number.
     There is already an integration of DialPad with libPhoneNumber_iOS to format the phone numbers with the country code, you can as well remove or implement your own formatting.

2) [CallViewController.swift](https://github.com/Ankish/PlivoExamplesSwift/tree/feature/OutgoingCallEg/OutGoingCall/OutGoingCall/View%20Controllers/Plivo%20Controller) - This manages the complete calling functionality. Initialize the controller with a number or sip endpoint and present to initiate the call.

```
let callController = CallViewController.storyBoardControllerForOutGoing(callerId: number)
self.present(callController, animated: true, completion: nil)
```

3) [Plivo.storyboard](https://github.com/Ankish/PlivoExamplesSwift/tree/feature/OutgoingCallEg/OutGoingCall/OutGoingCall/View)- Contains the necessary iOS Storyboard Interface for dialpad and calling features.

### 3) More Documentation
You can find more documentation on getting started as well as our latest AppleDoc below:
* [Api Reference](https://api-reference.plivo.com/latest/curl/resources/call/make-a-call)
* [Docs](https://www.plivo.com/docs/getting-started/)
* [SDK details](https://www.plivo.com/docs/sdk/ios/v2/)

### 4) Issues and Support
Please file any issues you find here on Github: [Voice Swift Quickstart Issues](https://github.com/Ankish/PlivoExamplesSwift/issues). 
Please ensure that you are not sharing any Personally Identifiable Information(PII) or sensitive account information (API keys, credentials, etc.) when reporting an issue.
For general inquiries related to the Voice SDK you can file a [support ticket](https://support.plivo.com/support/home).
