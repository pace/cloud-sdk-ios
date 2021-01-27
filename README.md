# PACE Cloud SDK

This framework combines multipe functionalities provided by PACE i.e. authorizing via **PACE ID** or requesting and displaying **Apps**. These functionalities are separated and structured into different ***Kits*** by namespaces, i.e. [IDKit](#idkit), [AppKit](#appkit).

- [PACE Cloud SDK](#pace-cloud-sdk)
    * [Specifications](#specifications)
    * [Installation](#installation)
        + [Carthage](#carthage)
        + [Cocoapods](#cocoapods)
        + [Swift Package Manager](#swift-package-manager)
        + [Binary](#binary)
    * [Setup](#setup)
    * [Migration](#migration)
        + [2.x.x -> 3.x.x](#from-2xx-to-3xx)
    * [IDKit](#idkit)
        + [Setup](#setup-1)
        + [Authorization](#authorization)
        + [Token refresh](#token-refresh)
        + [Session refreshToken](#session-refreshtoken)
    * [AppKit](#appkit)
        + [Main Features](#main-features)
        + [Setup](#setup-2)
        + [Native login](#native-login)
        + [Deep Linking](#deep-linking)
        + [AppKitDelegate](#appkitdelegate)
        + [Requesting local Apps](#requesting-local-apps)
        + [Is POI in range?](#is-poi-in-range-)
        + [AppWebView / AppViewController](#appwebview---appviewcontroller)
        + [AppDrawerContainer](#appdrawercontainer)
        + [AppDrawer](#appdrawer)
        + [Custom AppDrawer] (#custom-appdrawer)
        + [AppError](#apperror)
    * [FAQ](#faq)

## Specifications
**PACECloudSDK** currently supports iOS 11 and above.

It has some external dependencies which you will need to inlcude as well:

- [AppAuth](https://github.com/openid/AppAuth-iOS)
- [Base32](https://github.com/mattrubin/Bases)
- [OneTimePassword](https://github.com/mattrubin/OneTimePassword)
- [SwiftProtobuf](https://github.com/apple/swift-protobuf)

## Installation
### Carthage
With [Carthage](https://github.com/Carthage/Carthage), add the following line to your Cartfile and run `carthage update --platform iOS`:
```
github "pace/cloud-sdk-ios" ~> 2.0
```

### Cocoapods
With [CocoaPods](https://guides.cocoapods.org/using/getting-started.html), add the following line to your `Podfile` to use the latest available version:
```
pod 'PACECloudSDK'
```

### Swift Package Manager (experimental)
With [Swift Package Manager](https://swift.org/package-manager/), add the following dependency to your Package.swift:
```swift
dependencies: [
    .package(name: "PACECloudSDK", url: "https://github.com/pace/cloud-sdk-ios", .from(from: "2.0.0"))
]
```

### Binary
Each release has an `XCFramework` attached, which can be added to your application; see [releases](https://github.com/pace/cloud-sdk-ios/releases).

## Setup
The `PACECloudSDK` needs to be setup before any of its `Kits` can be used. Therefore you *must* call `PACECloudSDK.shared.setup(with: PACECloudSDK.Configuration)`. The best way to do this is inside
`applicationDidFinishLaunching` in your `AppDelegate`. It will automatically authorize your application with the provided api key.

`PACECloudSDK.Configuration` only has `clientId` and `apiKey`  as a mandatory property, all others are optional and can be passed as necessary.

**Note**: `PACECloudSDK` is using the `.production` environment as default. In case you are still doing tests, you probably want to change it to `.sandbox` or `.stage`.

Available parameters:

```swift
clientId: String
apiKey: String? // Default: nil
authenticationMode: AuthenticationMode // Default: .web
accessToken: String? // Default: nil
environment: Environment // Default: .production
configValues: [ConfigValue: Any]? // Default: nil
```

## Migration
### From 2.x.x to 3.x.x
In `3.0.0` we've introduced a universal setup method: `PACECloudSDK.shared.setup(with: PACECloudSDK.Configuration)` and removed the setup for `AppKit` and `POIKitManager`.

The `PACECloudSDK.Configuration` almost has the same signature as the previous `AppKit.AppKitConfiguration`, only the `theme` parameter has been removed, which is now defaulted to `.automatic`. In case you want to set a specific theme, you can set it via `AppKit`'s `theme` property: `AppKit.shared.theme`.

## IDKit
**IDKit** manages the OpenID (OID) authorization and the general session flow with its token handling via **PACE ID**.

### Setup
This code example shows how to setup *IDKit*. The parameter `cacheSession` defines if *IDKit* will persist the session.
```swift
let config = IDKit.OIDConfiguration(authorizationEndpoint: AUTH_ENDPOINT,
                                    tokenEndpoint: TOKEN_ENDPOINT,
                                    clientId: CLIENT_ID,
                                    redirectUrl: REDIRECT_URL,
                                    additionalParameters: [KEY: VALUE])

IDKit.setup(with: config, cacheSession: true, presentingViewController: YOUR_VIEWCONTROLLER)
```

### Authorization
To start the authorization process and to retrieve your access token simply call:
```swift
IDKit.authorize { accessToken, error in
    ...
}
```
*IDKit* will automatically try to refresh the previous session if you passed `cacheSession: true` during the setup.
For all devices on iOS 12 and below a native permission prompt for the internally requested `ASWebAuthenticationSession` will be displayed to the user.

### Token refresh
If you prefer to refresh the access token of your current session manually call:
```swift
IDKit.refreshToken { accessToken, error in
    ...
}
```

### Session refreshToken
Resetting the current session works as follows:
```swift
IDKit.resetSession()
```
A new authorization will be required afterwards.


## AppKit
### Main Features
- Check for available Apps at the current location
- Retrieve an App as UIViewController or WKWebView
- Retrieve an App as Drawer/Slider
- Payment Authentication

### Setup
Biometry is needed for 2FA during the payment process, thus make sure that `NSFaceIDUsageDescription` is correctly set in your target properties.

### Native login
You can use *AppKit* with your native login (given that your token has the necessary scopes) as well. In case of a native login,
it is crucial that you set the configuration during setup accordingly, i.e. setting the `authenticationMode` to `.native`,
and passing an initial `accessToken`, if available.

There is a `AppKitDelegate` method that you will need to implement, i.e. `tokenInvalid(completion: ((String) -> Void))`,
which is triggered whenever your access token (or possible lack thereof) is invalid; possible reasons: it has expired, has missing scopes
or has been revoked. You are responsible for retrieving and passing a valid token to the `completion` block.
In case that you can't retrieve a new valid token, don't call the `completion` handler, otherwise you will most likely end up
in an endless loop. Make sure to clean up all the App related views as well.

Pseudocode of implementing the protocol method and passing the response to `AppKit`:

```swift
func tokenInvalid(completion: ((String) -> Void)) {
    retrieveNewToken { newToken in
        completion(newToken)
    }
}
```

### Deep Linking
Some of our services (e.g. `PayPal`) do not open the URL in the App web view, but in a `SFSafariViewController` within the app, due to security reasons. After completion of the process the user is redirected back to the App web view via deep linking. In order to set the redirect URL correctly and to ensure that the client app intercepts the deep link, the following requirements must be met:

- Set the `clientId` in *PACECloudSDK's* configuration during the [setup](#setup), because it is needed for the redirect URL
- Specify the `pace.$clientId` in the app target's custom URL scheme (please refer to [Apple's doc](https://developer.apple.com/documentation/xcode/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app) on how to set up the custom URL scheme).

In your `AppDelegate`'s `application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool` you will have to catch the `redirect` host and call `AppKit.shared.handleRedirectURL` to handle the callback.

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    switch url.host {
    case "redirect":
    AppKit.shared.handleRedirectURL(url)
        return true

    default:
        return false
    }
}
```

### Theming
`AppKit` offers both a `.light` and `.dark` theme. The theme is set to `.automatic` by default, which then takes the system's appearance setting. In case you want to enforce either `.light` or `.dark` theme, you can set it via the public `theme` property: `AppKit.shared.theme`.

### AppKitDelegate
This protocol needs to be implemented in order to receive further information about your requests. It will also provide specific data that allows you to correctly display Apps.
- `didFail(with error: AppKit.AppError)`: Called everytime an error occured during requests
- `didReceiveAppDrawers(_ appDrawers: [AppKit.AppDrawer], _ appDatas: [AppKit.AppData])`: Called if one or more AppDrawers have been fetched successfully
- `didReceiveAppData(_ appData: [AppKit.AppData])`: Called if one or more AppData objects have been fetched successfully

### Requesting local Apps
You need to make sure your users allowed your application to use their location. *AppKit* requires the user's current location but will not request the permissions.
To request the check for available local Apps call `AppKit.shared.requestLocalApps()`. This function will start retrieving the user's current position and return
all available Apps as AppDrawers by asynchronously invoking `AppKitDelegate's` `didReceiveAppDrawers(_ appDrawers: [AppKit.AppDrawer], _ appDatas: [AppKit.AppData])` once for each request. Possible errors during the request will also be passed via the `AppKitDelegate`.
Because of the fact that AppDrawers are dependent on the user's position, it's necessary to call the mentioned method periodically to make sure that Apps
will stay up to date. If a request does not contain a currently presented App / AppDrawer it will be removed by *AppKit* automatically. This may happen if the user changes the position to where the previously fetched App is no longer available at.

### Is POI in range?
To check if there is a App for the given POI ID at the current location, call `AppKit.shared.isPoiInRange(id: String, completion: @escaping ((Bool) -> Void))`.

Note that this method is also triggering `AppKitDelegate`'s `didReceiveAppDrawers` callback.

```swift
AppKit.shared.isPoiInRange(id: poiId) { found in
        NSLog("==== Found id in range: \(found)")
    }
```

### AppWebView / AppViewController
*AppKit* provides a default WKWebView or UIViewController that contains the requested App. There are several methods to obtain this WebView or ViewController. You may either pass a `appUrl` or a `appUrl` with some `reference` (e.g. a gas station reference).
```swift
let webView = AppKit.shared.appWebView(appUrl: "App_URL")
let viewController = AppKit.shared.appViewController(appUrl: "App_URL")
```

```swift
let webView = AppKit.shared.appWebView(appUrl: "App_URL", reference: "REFERENCE")
let viewController = AppKit.shared.appViewController(appUrl: "App_URL", reference: "REFERENCE")

// Example reference
// The reference starts with a specific namespace identifier followed by the gas station id in this case
// It has to conform to the URN format
let reference = "prn:poi:gas-stations:1a3b5c7d-1a3b-12a4-abcd-8c106b8360d3"
```

### AppDrawerContainer
Before being able to display AppDrawers you need an instance of `AppDrawerContainer`. Call `setupContainerView()` to setup the container. It will automatically resize itself based on the amount of available AppDrawers.

### AppDrawer
The `AppDrawer` is a view that functions as a preview for a local App. It has a **collapsed** and **expanded** state. Former shows an icon and expands by tapping. Latter additionally shows a title and subtitle and collapses by tapping the `x-Button`. Tapping the AppDrawer bar will open the corresponding fullscreen
App. The drawers need to be added to a `AppDrawerContainer` in order to work correctly by calling `appDrawerContainer.inject(YOUR_DRAWERS)`.

A AppDrawer and the eventually opened App will automatically remove themselves if the App is no longer available at the user's current position.

### Custom AppDrawer
The responsible class needs to conform to the `AppKitDelegate` and must be set as `AppKit`'s delegate: `AppKit.shared.delegate = self`.

In order to check if there are apps available in the current position call `AppKit.shared.requestLocalApps()`.

As defined in [AppKitDelegate](#appkitdelegate), there are some methods that need to be implemented in, i.e.
`didReceiveAppData(_ appData: [AppKit.AppData])` and
`didEscapeForecourt(_ appDatas: [AppKit.AppData])`.

Each `AppKit.AppData` then contains the information for one connected fueling available gas station.

### AppData
Properties:
- `appID: String`: App id
- `appApiUrl: String?`: Base api url
- `metadata: [AppKit.AppMetadata: AnyHashable]`: Contains metadata like the gas station reference (prn prefix + id)
- `appManifest: AppManifest?`: Contains name, description and icons of the App

#### AppMetadata
Retrieve gas station id via `metadata[AppKit.AppMetadata.references]`.
Note that the id has `prn:poi:gas-stations:` as prefix.

```swift
let prnReference = (appData.metadata[AppKit.AppMetadata.references] as! [String])?.first(where: { $0.contains("prn:poi:gas-stations:") })
let gasstationID = String(prnReference.dropFirst("prn:poi:gas-stations:"))
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
