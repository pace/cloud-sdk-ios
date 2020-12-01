# PACE Cloud SDK
This framework combines multipe functionalities provided by PACE i.e. authorizing via **PACE ID** or requesting and displaying **Apps**. These functionalities are separated and structured into different ***Kits*** by namespacing as follows:

- [IDKit](#idkit)
- [AppKit](#appkit)

## Specifications
**PACECloudSDK** currently supports iOS 11 and above.

It has some external dependencies which you will need to inlcude as well:

- [AppAuth](https://github.com/openid/AppAuth-iOS)
- [Base32](https://github.com/mattrubin/Bases)
- [OneTimePassword](https://github.com/mattrubin/OneTimePassword)
- [SwiftProtobuf](https://github.com/apple/swift-protobuf)

## Setup
### Carthage
With [Carthage](https://github.com/Carthage/Carthage), add the following line to your Cartfile:
```
github "tdb"
```

### Cocoapods
With [CocoaPods](https://guides.cocoapods.org/using/getting-started.html), add the following line to your Podfile:
```
pod "tbd"
```

### Swift Package Manager
With [Swift Package Manager](https://swift.org/package-manager/), add the following dependency to your Package.swift:
```swift
dependencies: [
    .package(url: "tbd", .from(from: "tbd"))
]
```

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
In order to use **AppKit** it is necessary to call `AppKit.shared.setup(config: AppKit.AppKitConfiguration)`. The best way to do this is inside 
`applicationDidFinishLaunching` in your `AppDelegate`. It will automatically authorize your application with the provided api key. 

`AppKitConfiguration` only has `clientId` and `environment` as a mandatory property, all others are optional and can be passed as necessary.
Available parameters:

```swift
    clientId: String
    apiKey: String? // Default: nil
    authenticationMode: AuthenticationMode // Default: .web
    accessToken: String? // Default: nil
    theme: AppKitTheme // Default: .automatic
    environment: AppEnvironment
    configValues: [ConfigValue: Any]? // Default: nil
```

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
Some of our services (e.g. `PayPal`) do not open the URL in the App web view, but in a `SFSafariViewController` within the app. After completion of the process the user is redirected back to the App web view via deep linking. In order to set the redirect URL correctly and to ensure that the client app intercepts the deep link, the following requirements must be met:

- Set the `clientId` in *AppKit's* configuration during the setup, because it is needed for the redirect URL
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

### AppKitDelegate
This protocol needs to be implemented in order to receive further information about your requests. It will also provide specific data that allows you to correctly display Apps.
- `didFail(with error: AppKit.AppError)`: Called everytime an error occured during requests
- `didReceiveAppDrawers(_ appDrawers: [AppKit.AppDrawer], _ appDatas: [AppKit.AppData])`: Called if one or more AppDrawers have been fetched successfully

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
App. The drawers need to be added to a `AppDrawerContaine` in order to work correctly by calling `appDrawerContainer.inject(YOUR_DRAWERS)`.

A AppDrawer and the eventually opened App will automatically remove themselves if the App is no longer available at the user's current position. 

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
