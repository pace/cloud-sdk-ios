# PACE Cloud SDK – iOS

- [PACE Cloud SDK](#pace-cloud-sdk)
    * [Getting Started](#getting-started)
        + [Installation](#step-1-installation)
            * [Swift Package Manager](#swift-package-manager)
            * [CocoaPods](#cocoapods)
            * [Carthage](#carthage)
            * [Binary](#binary)
        + [Initialize SDK](#step-2-initialize-sdk)
        + [Configure authentication](#step-3-configure-authentication)
        + [Setup deep linking](#step-4-setup-deep-linking)
        + [Add permissions](#step-5-add-permissions)
    * [Usage](#usage)
        + [Fetching Connected Fueling Stations](#fetching-connected-fueling-stations)
        + [Show slider for Connected Fueling Stations](#show-slider-for-connected-fueling-stations)
        + [Initiating Fueling Process](#initiating-fueling-process)
        + [Show Payment Methods](#show-payment-methods)
    * [IDKit](#idkit)
        + [Setup](#setup-1)
        + [Custom OIDC setup](#custom-oidc-setup)
        + [Authorization](#authorization)
        + [Token refresh](#token-refresh)
        + [Session reset](#session-reset)
        + [2FA setup](#2fa-setup)
            * [Mail-OTP](#mail-otp)
            * [Biometry](#biometry)
            * [PIN](#pin)
    * [AppKit](#appkit)
        + [Main Features](#main-features)
        + [Setup](#setup-2)
        + [Native login](#native-login)
        + [Deep Linking](#deep-linking)
        + [AppKitDelegate](#appkitdelegate)
        + [Requesting local Apps](#requesting-local-apps)
        + [AppWebView / AppViewController](#appwebview-appviewcontroller)
        + [AppDrawerContainer](#appdrawercontainer)
        + [AppDrawer](#appdrawer)
        + [Custom AppDrawer](#custom-appdrawer)
        + [AppError](#apperror)
    * [POIKit](#poikit)
        + [Is POI in range?](#is-poi-in-range)
        + [Fetching Connected Fueling Stations](#fetching-connected-fueling-stations)
    * [Miscellaneous](#miscellaneous)
        + [Preset Urls](#preset-urls)
        + [Logging](#logging)
        + [Handling `401` API responses](#handling-401-api-responses)
    * [Migration](#migration)
        + [2.x.x -> 3.x.x](#from-2xx-to-3xx)
        + [3.x.x -> 4.x.x](#from-3xx-to-4xx)
        + [4.x.x -> 5.x.x](#from-4xx-to-5xx)
        + [5.x.x -> 6.x.x](#from-5xx-to-6xx)
        + [6.x.x -> 7.x.x](#from-6xx-to-7xx)
        + [7.x.x -> 8.x.x](#from-7xx-to-8xx)
        + [8.x.x -> 9.x.x](#from-8xx-to-9xx)
    * [Source code](#source-code)
    * [FAQ](#faq)

## Getting Started

You need to perform the following steps in order to use the `PACECloudSDK`.

### Step 1: Installation

### Swift Package Manager
With [Swift Package Manager](https://swift.org/package-manager/), add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(name: "PACECloudSDK", url: "https://github.com/pace/cloud-sdk-ios", .from(from: "9.1.0"))
]
```

### CocoaPods
With [CocoaPods](https://guides.cocoapods.org/using/getting-started.html), add the following line to your `Podfile` to use the latest available version:

```
pod 'PACECloudSDK'
```

### Carthage
With [Carthage](https://github.com/Carthage/Carthage), add the following line to your `Cartfile` and run `carthage update --platform iOS`:

```
github "pace/cloud-sdk-ios" ~> 9.1.0
```

Building `XCFramework` via the `--use-xcframeworks` parameter is currently not supported.

### Binary
Each release has an `XCFramework` attached, which can be added to your application; see [releases](https://github.com/pace/cloud-sdk-ios/releases).

### Specifications
**PACECloudSDK** currently supports iOS 11 and above.

`PACECloudSDK` has some external dependencies which you will need to include as well:

- [AppAuth](https://github.com/openid/AppAuth-iOS)
- [Base32](https://github.com/mattrubin/Bases)
- [OneTimePassword](https://github.com/mattrubin/OneTimePassword)
- [SwiftProtobuf](https://github.com/apple/swift-protobuf)

### Step 2: Initialize SDK

The `PACECloudSDK` needs to be initialized before _any_ of its functionalities can be used. Therefore you *must* call `PACECloudSDK.shared.setup(with: PACECloudSDK.Configuration)`. The best way to do this is inside `applicationDidFinishLaunching` in your `AppDelegate`. It will automatically authorize your application with the provided API key.

```swift
let config: PACECloudSDK.Configuration = .init(apiKey: "<YOUR_API_KEY>",
                                               authenticationMode: .native,
                                               environment: .production)

PACECloudSDK.shared.setup(with: config)
```

<dl>
  <dt>apiKey</dt>
  <dd>Contact PACE to retrieve an API key.</dd>
  <dt>authenticationMode</dt>
  <dd>The default authentication mode is .native. If you're not using native authentication set this value to .web</dd>
  <dt>environment</dt>
  <dd>Default is .production. During development this should be set to .sandbox</dd>
</dl>

More information can be found in [Configuration](#configuration)

### Step 3: Configure authentication

Add the `OIDConfigurationClientID` and the `OIDConfigurationRedirectURI` to your `Info.plist`:

```xml
<key>PACECloudSDKIDKitSetup</key>
<dict>
    <key>OIDConfigurationRedirectURI</key>
    <string>REDIRECT_URI</string>
    <key>OIDConfigurationClientID</key>
    <string>CLIENT_ID</string>

    // If you use your own identity provider
    // you have to add this value as well
    <key>OIDConfigurationIDPHint</key>
    <string>OPTIONAL_IDP_HINT</string>
</dict>
```

Contact PACE to setup `REDIRECT_URI` and `CLIENT_ID`.

Please refer to [IDKit](#idkit) for more information, e.g. if you want to use custom OIDC configurations.

### Step 4: Setup deep linking

Some of our services (e.g. the onboarding of PayPal payment methods) open the URL in the `SFSafariViewController`, due to security reasons. After completion of the process the user is redirected back to the app's web view via deep linking.

To ensure this works as expected you have to specify the `pace.YOUR_CLIENT_ID` in the app target’s custom URL scheme (please refer to [Apple’s doc](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app) on how to set up the custom URL scheme).

Catch redirect in `AppDelegate`'s `application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool` and forward it to `PACECloudSDK.shared.application(open:)`

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    PACECloudSDK.shared.application(open: url)
}
```

More information can be found in [Deep Linking](#deep-linking)

### Step 5: Add permissions

The SDK needs the `Privacy - Face ID Usage Description` (`NSFaceIDUsageDescription`) and the `Photo Library Usage` (`NSPhotoLibraryUsageDescription`) permissions to be set in the `Info.plist`.

`NSFaceIDUsageDescription` is needed to be able to authorize the payments with `FaceID` or `TouchID`. `NSPhotoLibraryUsageDescription` is needed in order to download and save receipts to the user's photo library. Your app _**will**_ crash, when the SDK tries to use those functionalities, but the properties have not been granted.

## Usage

### Fetching Connected Fueling Stations

```swift
func fetchCofuStations() {
    // Request connected fueling stations with a radius of 'SOME_RADIUS' around 'SOME_LOCATION'
    POIKit.requestCofuGasStations(center: SOME_LOCATION, radius: SOME_RADIUS) { result in
        switch result {
        case .success(let cofuStations):
            // Handle online cofu stations

        case .failure(let error):
            // Handle error
        }
    }
}
```

### Show slider for Connected Fueling Stations

```swift
class AppControl: AppKitDelegate {
    private init() {
        AppKit.delegate = self
    }

    func didFail(with error: AppKit.AppError) {
        // Handle error
    }

    func didReceiveAppDrawers(_ appDrawers: [AppKit.AppDrawer], _ appDatas: [AppKit.AppData]) {
        // Inject inject into AppKit.AppDrawerContainer
    }
}

class MyViewController: UIViewController {
    private lazy var appDrawerContainer: AppKit.AppDrawerContainer = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    func setup() {
        appDrawerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appDrawerContainer)

        appDrawerContainer.setupContainerView()
        appDrawerContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150).isActive = true
        appDrawerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    func inject(_ appDrawers: [AppKit.AppDrawer]) {
        view.bringSubviewToFront(appDrawerContainer)
        appDrawerContainer.inject(appDrawers, theme: .light)
    }
}
```

### Initiating Fueling Process

```swift
class MyViewController: UIViewController {
    func initiateFuelingProcess() {
        // Request a fueling view controller without having the gas station id
        let fuelingViewController = AppKit.appViewController(presetUrl: .fueling(id: nil))

        // Request a fueling view controller with a gas station id in hand
        let fuelingViewController = AppKit.appViewController(presetUrl: .fueling(id: "GAS_STATION_ID"))

        // Request a fueling view controller with a custom app url
        let fuelingViewController = AppKit.appViewController(appUrl: "CUSTOM_APP_URL")

        present(fuelingViewController, animated: true)
    }
}
```

### Show Payment Methods

```swift
class MyViewController: UIViewController {
    func showPaymentMethods() {
        let paymentViewController = AppKit.appViewController(presetUrl: .payment)
        present(paymentViewController, animated: true)
    }
}
```

## Configuration

The `PACECloudSDK` needs to be set up before any of its `Kits` can be used. Therefore you *must* call `PACECloudSDK.shared.setup(with: PACECloudSDK.Configuration)`. The best way to do this is inside
`applicationDidFinishLaunching` in your `AppDelegate`. It will automatically authorize your application with the provided API key.

`PACECloudSDK.Configuration` only has `apiKey` as a mandatory property, all other parameter either have a default value or are optional .

**Note**: `PACECloudSDK` is using the `.production` environment as default. In case you are still doing tests, you probably want to change it to `.sandbox` or `.stage`.

Available parameters:

```swift
apiKey: String
authenticationMode: AuthenticationMode // Default: .native
environment: Environment // Default: .production
customOIDConfiguration: IDKit.OIDConfiguration? // Default: nil
isRedirectSchemeCheckEnabled: Bool // Default: true
domainACL: [String]? // Default: ["pace.cloud"]
allowedLowAccuracy: Double? // Default: nil
speedThresholdInKmPerHour: Double? // Default: nil
geoAppsScope: String? // Default: nil
allowedAppDrawerLocationOffset: Double? // Default nil
enableLogging: Bool // Default: false
```

- `apiKey` Is mandatory to be set. Your API key provided by PACE.
- `authenticationMode` The default authentication mode is `.native`. If you're not using native authentication set this value to `.web`.
- `environment` Default is `.production`. During development this should be set to `.sandbox`.
- `customOIDConfiguration` Set if you want to use your own OID Configuration. (More information in [Custom OIDC setup](#custom-oidc-setup))
- `isRedirectSchemeCheckEnabled` Per Default this is `true`. If you don't want to allow redirects set to `false`.
- `domainACL` List of domains which are allowed to access secured data.
- `allowedLowAccuracy` Accuracy in meters the user location has to have at least to check for Connected Fueling Stations around them.
- `speedThresholdInKmPerHour` The speed in km/h users have to move to stop checking for Connected Fueling Stations around them.
- `geoAppsScope` Can be specified if special Connected Fueling requirements are needed.
- `allowedAppDrawerLocationOffset` Maximum distance of Cofu station to user in meters to still be shown.
- `enableLogging` Set to `true` if you want to make use of the Logger provided by `PACECloudSDK`

## IDKit
**IDKit** manages the OpenID (OID) authorization and the general session flow with its token handling via **PACE ID**.

### Setup
All that needs to be done to use `IDKit` is to specify the OID Configuration. If you want to use the PACE default configuration you'll at least have to add `OIDConfigurationRedirectURI` and `OIDConfigurationClientID` with non-empty values to your `Info.plist`. `OIDConfigurationIDPHint` is only needed if required in your specific situation.

```xml
<key>PACECloudSDKOIDConfigurationClientID</key>
<string>YOUR_CLIENT_ID</string>
<key>PACECloudSDKOIDConfigurationRedirectURI</key>
<string>YOUR_REDIRECT_URI</string>

<key>PACECloudSDKIDKitSetup</key>
<dict>
    <key>OIDConfigurationRedirectURI</key>
    <string>pace://cloud-sdk-example</string>
    <key>OIDConfigurationClientID</key>
    <string>cloud-sdk-example-app</string>
    <key>OIDConfigurationIDPHint</key>
    <string>OPTIONAL_IDP_HINT</string>
</dict>
```

### Custom OIDC setup
In case you would like to use your own OID Configuration create it like so and pass it to the `PACECloudSDK.Configuration`:

```swift
let config = IDKit.OIDConfiguration(authorizationEndpoint: AUTH_ENDPOINT,
                                    tokenEndpoint: TOKEN_ENDPOINT,
                                    clientId: CLIENT_ID,
                                    redirectUrl: REDIRECT_URL,
                                    additionalParameters: [KEY: VALUE])

let config: PACECloudSDK.Configuration =
    .init(
        apiKey: "YOUR_API_KEY",
        authenticationMode: .native,
        environment: ENV,
        customOIDConfiguration: config
    )

// Keep in mind to set up the 'PACECloudSDK' before setting any 'IDKit' properties
PACECloudSDK.shared.setup(with: config)

IDKit.presentingViewController = YOUR_VIEWCONTROLLER
IDKit.delegate = YOUR_DELEGATE

// In case you want to set additional properties to you OIDConfiguration after its initialization
IDKit.OIDConfiguration.appendAdditionalParameters([String: String])
```

### Authorization
To start the authorization process and to retrieve your access token simply call:

```swift
IDKit.authorize { result in
    switch result {
    case .success(let accessToken):
    case .failure(let error):
    }
}
```

*IDKit* will automatically try to refresh the previous session.
For all devices on iOS 12 and below a native permission prompt for the internally requested `ASWebAuthenticationSession` will be displayed to the user.

### Token refresh
If you prefer to refresh the access token of your current session manually call:

```swift
IDKit.refreshToken { result in
    switch result {
    case .success(let accessToken):
    case .failure(let error):
    }
}
```

### Session reset
Resetting the current session works as follows:

```swift
IDKit.resetSession()
```

A new authorization will be required afterwards.

### 2FA setup
In numerous cases a second authentication factor is required when using Connected Fueling, e.g. when authorizing a payment. Following are methods that can be used to setup biometric authentication on the user's device or setup an account PIN.

In order to prevent websites from accessing your TOTP secrets (used when biometric authentication is used), a domain access control list may be passed to the `domainACL` property of the `Configuration` object in the [setup phase](#setup). If you're not using a custom app, you can ignore this property as it is set to `"pace.cloud"` by default.

#### Mail-OTP
For some of the below mentioned methods an OTP is needed, which can be requested to be sent to the user's email via

```swift
IDKit.sendMailOTP(completion: ((Result<Bool, IDKitError>) -> Void)? = nil)
```

#### Biometry
The `PACECloudSDK` provides the following methods to enable and disable biometric authentication:

* Check if biometric authentication has been enabled on the device

    ```swift
    IDKit.isBiometricAuthenticationEnabled()
    ```

* Enable biometric authentication with either PIN, password or OTP (see [OTP](#mail-otp)).  
_**NOTE:**_ Up until 5 minutes after a successful authorization you may enable biometry without having to pass any of the aforementioned credentials.

    ```swift
    IDKit.enableBiometricAuthentication(pin: String, completion: ((Result<Bool, IDKitError>) -> Void)?)
    IDKit.enableBiometricAuthentication(otp: String, completion: ((Result<Bool, IDKitError>) -> Void)?)
    IDKit.enableBiometricAuthentication(password: String, completion: ((Result<Bool, IDKitError>) -> Void)?)

    // After a successful authorization
    IDKit.enableBiometricAuthentication(completion: ((Result<Bool, IDKitError>) -> Void)?)
    ```

* Disable biometric authentication on the device:

    ```swift
    IDKit.disableBiometricAuthentication()
    ```

#### PIN
The `PACECloudSDK` provides the following methods to check and set the PIN:

* Check if the user PIN has been set

    ```swift
    IDKit.isPINSet(completion: @escaping (Result<Bool, IDKitError>) -> Void)
    ```

* Check if the user password has been set

    ```swift
    IDKit.isPasswordSet(completion: @escaping (Result<Bool, IDKitError>) -> Void)   
    ```

* Check if the user PIN or password has been set

    ```swift
    IDKit.isPINOrPasswordSet(completion: @escaping (Result<Bool, IDKitError>) -> Void)
    ```

* Set the user PIN with biometry; only works, if biometry has been setup before

    ```swift
    IDKit.setPINWithBiometry(pin: String, completion: ((Result<Bool, IDKitError>) -> Void)? = nil)
    ```

* Set the user PIN and authorize with the user password

    ```swift
    IDKit.setPIN(pin: String, password: String, completion: @escaping (Result<Bool, IDKitError>) -> Void)
    ```

* Set the user PIN and authorize with an OTP previously sent by mail (see [OTP](#mail-otp))

    ```swift
    IDKit.setPIN(pin: String, otp: String, completion: @escaping (Result<Bool, IDKitError>) -> Void)
    ```

## AppKit
### Main Features
- Check for available Apps at the current location
- Retrieve an App as UIViewController or WKWebView
- Retrieve an App as Drawer/Slider
- Payment Authentication

### Native login
By default *AppKit* is used with your native login (given that your token has the necessary scopes) as well.

There is a `AppKitDelegate` method that you will need to implement, i.e. `func getAccessToken(reason: AppKit.GetAccessTokenReason, oldToken: String?, completion: @escaping ((AppKit.GetAccessTokenResponse) -> Void))`,
which is triggered whenever your access token (or possible lack thereof) is invalid; possible reasons: it has expired, has missing scopes
or has been revoked. You are responsible for retrieving a valid access token and passing a `GetAccessTokenResponse` with the token and wether it is a initial token or not (defaults to `false`) to the `completion` block.
In case that you can't retrieve a new valid token, don't call the `completion` handler, otherwise you will most likely end up
in an endless loop. Make sure to clean up all the App related views as well.

**_NOTE:_** With SDK version `7.x.x` this callback will only be sent if you're not using `IDKit` (see [6.x.x -> 7.x.x](#from-6xx-to-7xx)).

Pseudocode of implementing the protocol method and passing the response to `AppKit`:

```swift
func getAccessToken(reason: AppKit.GetAccessTokenReason, oldToken: String?, completion: @escaping ((AppKit.GetAccessTokenResponse) -> Void)) {
    retrieveNewToken { newToken in
        let response = AppKit.GetAccessTokenResponse(accessToken: newToken)
        completion(response)
    }
}
```

The `GetAccessTokenReponse` struct:

```swift
struct GetAccessTokenResponse: Codable {
    let accessToken: String
    let isInitialToken: Bool

    public init(accessToken: String, isInitialToken: Bool =
    public init(from decoder: Decoder) throws
}
```

### Deep Linking
Some of our services (e.g. the onboarding of `PayPal` payment methods) open the URL in the `SFSafariViewController` due to security reasons. After completion of the process the user is redirected back to the App web view via deep linking.

**_NOTE:_** In case you're not using deep linking at all you may want to set `isRedirectSchemeCheckEnabled` to `false` in the configuration during the setup (see [Setup](#setup)) to prevent warning messages to be logged.

In order to set the redirect URL correctly and to ensure that the client app intercepts the deep link, the following requirements must be met:

- Specify the `pace.YOUR_CLIENT_ID` in the app target's custom URL scheme (please refer to [Apple's doc](https://developer.apple.com/documentation/xcode/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app) on how to set up the custom URL scheme).
- After successfully having set the scheme, your `Info.plist` should look as follows:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>YOUR_TARGET_NAME</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>pace.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>
```

- In case that you're not using native development, you may also set the redirect scheme directly as shown below:

```swift
PACECloudSDK.shared.redirectScheme = "pace.YOUR_CLIENT_ID"
```

In your `AppDelegate`'s `application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool` you will have to catch the `redirect` host and call `AppKit.handleRedirectURL` to handle the callback.

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    switch url.host {
    case "redirect":
    AppKit.handleRedirectURL(url)
        return true

    default:
        return false
    }
}
```

### Theming
`AppKit` offers both a `.light` and `.dark` theme. The theme is set to `.automatic` by default, which then takes the system's appearance setting. In case you want to enforce either `.light` or `.dark` theme, you can set it via the public `theme` property: `AppKit.theme`.

### AppKitDelegate
This protocol needs to be implemented in order to receive further information about your requests. It will also provide specific data that allows you to correctly display Apps.
- `didFail(with error: AppKit.AppError)`: Called everytime an error occured during requests
- `didReceiveAppDrawers(_ appDrawers: [AppKit.AppDrawer], _ appDatas: [AppKit.AppData])`: Called if one or more AppDrawers have been fetched successfully

### Requesting local Apps
You need to make sure your users allowed your application to use their location. *AppKit* requires the user's current location but will not request the permissions.
To request the check for available local Apps call `AppKit.requestLocalApps()`. This function will start retrieving the user's current position and return
all available Apps as AppDrawers by asynchronously invoking `AppKitDelegate's` `didReceiveAppDrawers(_ appDrawers: [AppKit.AppDrawer], _ appDatas: [AppKit.AppData])` once for each request. Possible errors during the request will also be passed via the `AppKitDelegate`.
Because of the fact that AppDrawers are dependent on the user's position, it's necessary to call the mentioned method periodically to make sure that Apps
will stay up to date. If a request does not contain a currently presented App / AppDrawer it will be removed by *AppKit* automatically. This may happen if the user changes the position to where the previously fetched App is no longer available at.

> _**NOTE:**_ If the user moves faster than the default value of 13 m/s (~50 km/h) the delegate method will not be called. A different speed threshold can be set during the setup (see [Setup](#setup-2)).


### AppWebView / AppViewController
*AppKit* provides a default WKWebView or UIViewController that contains the requested App. There are several methods to obtain this WebView or ViewController. You may either pass a `appUrl`, a `appUrl` with some `reference` (e.g. a gas station reference) or a `presetUrl` (see [Preset Urls](#preset-urls)).

```swift
let webView = AppKit.appWebView(appUrl: "App_URL")
let viewController = AppKit.appViewController(appUrl: "App_URL")
```

```swift
let webView = AppKit.appWebView(appUrl: "App_URL", reference: "REFERENCE")
let viewController = AppKit.appViewController(appUrl: "App_URL", reference: "REFERENCE")

// Example reference
// The reference starts with a specific namespace identifier followed by the gas station id in this case
// It has to conform to the URN format
let reference = "1a3b5c7d-1a3b-12a4-abcd-8c106b8360d3"
```

```swift
let webView = AppKit.appWebView(presetUrl: .paceID)
let viewController = AppKit.appViewController(presetUrl: .payment)
```

> _**NOTE:**_ With SDK version >= 9.0.0 all `AppViewController` instances have their `isModalInPresentation` property set to `true` by default. This prevents the view controller from being dismissed when swiping down. To set the value back to `false` either pass it to the initializer or directly access the property afterwards.

### AppDrawerContainer
Before being able to display AppDrawers you need an instance of `AppDrawerContainer`. Call `setupContainerView()` to setup the container. It will automatically resize itself based on the amount of available AppDrawers.

### AppDrawer
The `AppDrawer` is a view that functions as a preview for a local App. It has a **collapsed** and **expanded** state. Former shows an icon and expands by tapping. Latter additionally shows a title and subtitle and collapses by tapping the `x-Button`. Tapping the AppDrawer bar will open the corresponding fullscreen
App. The drawers need to be added to a `AppDrawerContainer` in order to work correctly by calling `appDrawerContainer.inject(YOUR_DRAWERS)`.

A AppDrawer and the eventually opened App will automatically remove themselves if the App is no longer available at the user's current position.

### Custom AppDrawer
The responsible class needs to conform to the `AppKitDelegate` and must be set as `AppKit`'s delegate: `AppKit.delegate = self`.

In order to check if there are apps available in the current position call `AppKit.requestLocalApps()`.

As defined in [AppKitDelegate](#appkitdelegate), there are some methods that need to be implemented in, i.e.
`didReceiveAppData(_ appData: [AppKit.AppData])` and
`didEscapeForecourt(_ appDatas: [AppKit.AppData])`.

Each `AppKit.AppData` then contains the information for one connected fueling available gas station.

### AppData
Properties:

- `appID: String?`: App id
- `title: String?`: Title for slider
- `subtitle: String?`: Subtitle for slider
- `appBaseUrl: String?`: Base api url
- `metadata: [AppKit.AppMetadata: AnyHashable]`: Contains metadata like the gas station reference

#### AppMetadata
Retrieve the gas station id:

```swift
let gasstationID = (appData.metadata[AppKit.AppMetadata.references] as! [String])?.first
```

#### AppManifest
Properties:

- `name`: App Name
- `description`: App description
- `icons`: Gas station icons in different sizes

##### AppIcon
`AppIcon` only contains the source string for the icon image. You will need to fetch it yourself.
To get the source url you need to combine `AppData.appApiUrl` and `AppIcon.source` with "/".

```swift
AppData.appApiUrl + "/" + AppIcon.source
```

### AppError
This enum will provide several error messages during App requests and overall processing to give you a better understanding on what went wrong.

Possible errors:

- `noLocationFound`: GPS is unavailable or inaccurate
- `locationNotAuthorized`: Missing location permission
- `couldNotFetchApp`: *AppKit* was unable to retrieve the App
- `failedRetrievingUrl`: The App url couldn't be loaded
- `fetchAlreadyRunning`: App fetch is currently running
- `paymentError`: The payment couldn't be processed
- `badRequest`: The request does not match the expected format
- `invalidURNFormat`: The passed POI reference value does not conform to our URN format
- `customURLSchemeNotSet`: The App tried to open an URL in `SFSafariViewController`, but deep linking has not been correctly configured
- `other(Error)`: Generic error

## POIKit
### Is POI in range?
To check if there is a App for the given POI ID at the current location, call `POIKit.isPoiInRange(id: String, at location: CLLocation? = nil, completion: @escaping ((Bool) -> Void))`.

> _**NOTE:**_ If the user moves faster than the default value of 13 m/s (~50 km/h) this method will return `false`. A different speed threshold can be set during the setup (see [Setup](#setup)).

```swift
POIKit.isPoiInRange(id: poiId) { found in
    NSLog("==== Found id in range: \(found)")
}
```

### Fetching Connected Fueling Stations
The following request will fetch cofu gas stations that are included in the specified bounding box, defined by a location and a radius. The response contains detailed information about the gas stations e.g. opening hours, prices, services, etc.

```swift
func fetchCofuStations() {
    // Request connected fueling stations with a radius of 'SOME_RADIUS' around 'SOME_LOCATION'
    POIKit.requestCofuGasStations(center: SOME_LOCATION, radius: SOME_RADIUS) { result in
        switch result {
        case .success(let cofuStations):
            // Handle cofu stations

        case .failure(let error):
            // Handle error
        }
    }
}   
```

## Miscellaneous
### Preset Urls
`PACECloudSDK` provides preset URLs for the most common apps, such as `PACE ID`, `payment`, `transactions` and `fueling` based on the enviroment the SDK was initialized with. You may access these URLs via the enum `PACECloudSDK.URL`.

### Logger
Logging in the `PACECloudSDK` is done by our `Logger`. By default persisting logs is disabled.

#### Config Logger
If you want to enable logging you need to set `enableLogging` to `true` in `PACECloudSDK.Configuration`.

#### Custom Logger
Since our `Logger` is an `open class` you can create your custom Logger and inherit from our `Logger` to make use of its features.
You can override the following parameters:
* `logTag`: Should be the name of your app. Will be added as prefix to every log. Default is `"[Logger]"`.
* `moduleTag`: This can be set if you want to implement a custom Logger for a specific module in your app. Will be added as prefix to every log after the `logTag`. Default is `""` (empty String).
* `maxNumberOfFiles`: Determines the maximum number of files to be persisted. One file is persisted for each day. Default is `7` and maximum is also `7`.
* `maxFileSize`: Determines the maximum size of each file. Default is `10 * 1000 * 1000` (10MB) and maximum is also `10 * 1000 * 1000` (10MB).

```swift
class ExampleLogger: Logger {
    override class var logTag: String {
        "[YOUR_APP_NAME]"
    }

    override class var moduleTag: String {
        "[YOUR_MODLUE_NAME]"
    }

    override class var maxNumberOfFiles: Int {
        5 // 5 files or your custom max number of files
    }

    override class var maxFileSize: Int {
        5 * 1000 * 1000 // 5MB or your custom max file size
    }
}
```

Our `Logger` will automatically add the time as prefix to every log with `"yyyy-MM-dd HH:mm:ss.SSS"` as date format. Every custom Logger which inherits from `Logger` will do the same.

#### Logging
To log a message call one of its static functions.

```swift
// Log with log level `verbose`
ExampleLogger.v("YOUR_LOG_MESSAGE")

// Log with log level `inform`
ExampleLogger.i("YOUR_LOG_MESSAGE")

// Log with log level `warning`
ExampleLogger.w("YOUR_LOG_MESSAGE")

// Log with log level `error`
ExampleLogger.e("YOUR_LOG_MESSAGE")

// Log with custom log level
ExampleLogger.log(message: "YOUR_LOG_MESSAGE", level: "YOUR_LOG_LEVEL")
```

#### Import and export logs
You can import and export logs.

```swift
// Import logs
ExampleLogger.importLogs(<YOUR_LOGS_AS_[String]>)

// Export logs
ExampleLogger.exportLogs { logs in
  // use logs here (logs are an array of String)
}
```

#### Debug bundle
Get URL to all persisted log files

```swift
 ExampleLogger.debugBundleDirectory { url in
   // use url here
 }
```

### Handling `401` API responses
> **_NOTE:_** The following only applies if you're making use of `IDKit` to handle your session.

When receiving a status code of `401` during API requests the SDK will first try to refresh your access token before returning the `401`. If the token refresh fails this indicates that your session isn't valid anymore. At this point the SDK resets all of the available session variables, then returns the `401`. Asking the user to authorize again is highly recommended in this sitation. Go to [Authorization](#authorization) for further information on how to authorize your user.

## Migration
### From 2.x.x to 3.x.x
In `3.0.0` we've introduced a universal setup method: `PACECloudSDK.shared.setup(with: PACECloudSDK.Configuration)` and removed the setup for `AppKit` and `POIKitManager`.

The `PACECloudSDK.Configuration` almost has the same signature as the previous `AppKit.AppKitConfiguration`, only the `theme` parameter has been removed, which is now defaulted to `.automatic`. In case you want to set a specific theme, you can set it via `AppKit`'s `theme` property: `AppKit.shared.theme`.

### From 3.x.x to 4.x.x
In `4.0.0` we've simplified the setup even further.

The `PACECloudSDK.Configuration` doesn't take an `initialAccessToken` anymore and will (as before) request the token when needed via the `tokenInvalid` callback (see [Native login](#native-login)).

Furthermore, the handling of the redirect scheme has been updated. The SDK automatically retrieves the URL scheme from your app's `Info.plist` (see [Deep Linking](#deep-linking)), therefore no `clientId` needs to be set within the `PACECloudSDK.shared.setup()` anymore.

The `PoiKitManager` has been removed as `PACECloudSDK`'s instance property. Instead it can be initialized directly via `POIKit.POIKitManager(environment:)`.

### From 4.x.x to 5.x.x
In `5.0.0` we've removed the option to pass a `force` parameter to the `IDKit.refreshSession(...)` call (see [Token refresh](#token-refresh)).

### From 5.x.x to 6.x.x
We've added more information in the `tokenInvalid` callback, thus the client can better react to the callback, i.e. a `reason` and the `oldToken` (if one has been passed before), will be included in the callback. Please refer to  [Native login](#native-login) for more information.

### From 6.x.x to 7.x.x
In version `7.x.x` we've made some big `AppKit` and `IDKit` changes.

- `AppKit`'s `invalidToken` callback has been replaced with a new `getAccessToken` callback. Please refer to [Native login](#native-login) for more information.
  + If you're **not** using `IDKit` this callback will be invoked and will have the same functionality as `invalidToken` before.
  + However if you **are** using and having set up `IDKit` the behavior now heavily changes:
    - `getAccessToken` will not be called anymore.
    - Instead `IDKit` first starts an attempt to refresh the session automatically.
    - If the session renewal fails there is a new `func didFailSessionRenewal(with error: IDKit.IDKitError?, _ completion: @escaping (String?) -> Void)` function that you may implement to specify your own behaviour for retrieving a new access token. This can be achieved by specifying an `IDKitDelegate` conformance and setting the `IDKit.delegate` property.
    -  If either this delegate method is not implemented or you didn't set the delegate property at all the SDK will automatically perform an authorization hence showing a sign in mask for the user
- The `IDKit` setup has been combined with the general SDK setup.
  + `IDKit.setup(...)` is no longer accessible.
  + By adding the keys `OIDConfigurationClientID` and `OIDConfigurationRedirectURI` with non-empty values to your `Info.plist` `IDKit` will be initiated with the default PACE OID configuration. Please head over to [IDKit setup](#setup-1) to learn how to set up this functionality.
  + A custom OID configuration can still be passed to the `PACECloudSDK.Configuration` if desired.
- `resetAccessToken()` has been removed from the `PACECloudSDK.shared` proprety. This functionality is simply no longer needed.  
- `IDKit.OIDConfiguration`'s property `redirectUrl` has been renamed to `redirectUri`.
- `IDKit.swapPresentingViewController(...)` has been removed. The presenting view controller for the sign in mask now needs to be set directy via `IDKit.presentingViewController`.

#### Noteworthy changes
- If using IDKit it is no longer required to set the `Authorization` header for any requests performed by the SDK. It will be included automatically.
- A new `logout` callback has been added to `AppKitDelegate`
- All APIs used by the SDK have been updated. Previously included enums have been removed. The corresponding properties that were of type of those enums are now directly of type of their former raw representable.

### From 7.x.x to 8.x.x
- We've set the default `authenticationMode` of the SDK to `.native`.  
> **_NOTE:_** If you are not using native authentication make sure to explicitely set the mode to `.web` in the SDK configuration if it isn't already.

- IDKit
    + The data type of the completion parameter of the `authorize(...)` call has been changed from `(String?, IDKitError?)` to `(Result<String?, IDKitError>)`
    + The data type of the completion parameter of the `refreshToken(...)` call has been changed from `(String?, IDKitError?)` to `(Result<String?, IDKitError>)`
    + The data type of the completion parameter of the `discoverConfiguration(...)` call has been changed from `(String?, String?, IDKitError?)` to `(Result<OIDConfiguration.Response, IDKitError>)`
    + The data type of the completion parameter of the `userInfo(...)` call has been changed from `(UserInfo?, IDKitError?)` to `(Result<UserInfo, IDKitError>)`

- AppKit:
    + The data type of the completion parameter for AppKitDelegate's `didCreateApplePayPaymentRequest` callback has been changed from `[String: Any]?` to `API.Communication.ApplePayRequestResponse?`
    + The data type of the completion parameter for AppKitDelegate's `getAccessToken` callback has been changed from `AppKit.GetAccessTokenResponse` to `API.Communication.GetAccessTokenResponse`
    + The `isPoiInRange(...)` call is now part of `POIKit`, available under `POIKit.isPoiInRange(...)`
    + The `requestCofuGasStations(...)` call is now part of `POIKit`, available under `POIKit.requestCofuGasStations(...)`
    + The model `CofuGasStation` is now part of `POIKit`, available under `POIKit.CofuGasStation`
    + AppKit's `shared` property is no longer publicly accessible. All methods and properties of type `AppKit.shared.fooBar()` are now accessible via `AppKit.fooBar()`
    + The data type of the completion parameter of the `fetchListOfApps(...)` call has been changed from `([AppKit.AppData]?, AppKit.AppError?)` to `(Result<[AppKit.AppData], AppKit.AppError>)`

- POIKit:
    + The parameter `poisOfType` has been removed from POIKitManager's methods `fetchPOIs(boundingBox:)` and `loadPOIs(boundingBox:)`
    + POIKitManager's `loadPOIs(locations:)` has been renamed to `fetchPOIs(locations:)`

### From 8.x.x to 9.x.x

+ `TokenValidator` is now part of `IDKit` instead of `AppKit`
+ The response of `POIKit.requestCoFuGasStation(center:, radius:)` does not filter the stations by their online status any more. The response may now also include **offline** stations
+ Implement default receipt image download handling (Requires `NSPhotoLibraryUsageDescription` to be set in target properties)
+ Update all apis to v2021-2 - GeoJSON, Fueling, Pay, POI and User ([Documentation](https://developer.pace.cloud/api))
+ `PACECloudSDKLoggingDelegate` does not exist any more.
+ Change default geo apps scope - When not specifying a custom `geoAppsScope` in the SDK configuration the `POIKit.CofuGasStation` property `polygon` will from now on be `nil`.
+ For all `AppViewController` instances the property `isModalInPresentation` is now `true` by default. Setting it to `false` can be done via the initializer or afterwards by directly accessing the property.

### From 9.x.x to 10.x.x

+ `API.Communication.ApplePayRequestRequest`, `API.Communication.ApplePayRequestResponse` and the two callbacks in `AppKitDelegate` `paymentRequestMerchantIdentifier(completion: @escaping (String) -> Void)` + `didCreateApplePayPaymentRequest(_ request: PKPaymentRequest, completion: @escaping (API.Communication.ApplePayRequestResponse?) -> Void)` have been removed.

## Source code
The complete source code of the SDK can be found on [GitHub](https://github.com/pace/cloud-sdk-ios).


## FAQ

<details>
  <summary>
    Error "Failed to build module 'PACECloudSDK' from its module interface; the compiler that produced it may have used features that aren't supported by this compiler"
  </summary>

  Make sure that all dependencies mentioned in [specifications](#specifications) have been included and set to `Embed & Sign`.
</details>

<details>
  <summary>
    What is the `PACECloudSlimSDK` target?
  </summary>

  The slimmed version doesn't use any external dependencies and can therefore not handle 2FA and the vector tile data. This reduces the size of the framework significantly and can therefore be used in situations where app size is critical, e.g. App Clips.
</details>
