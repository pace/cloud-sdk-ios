24.0.1 Release notes (2024-09-30)
=============================================================

### Internal

* Update fueling API

24.0.0 Release notes (2024-09-26)
=============================================================

### Breaking Changes

* Add optional context to logEvent request

23.3.2 Release notes (2024-09-23)
=============================================================

### Fixes

* Add missing DisableDiscount to project

23.3.1 Release notes (2024-09-19)
=============================================================

### Internal

* Update Pay API

23.3.0 Release notes (2024-09-06)
=============================================================

### Enhancements

* Add sdk handlers for optional receipt email and receipt attachments

### Fixes

* Handling of 401 for authorized HTTP requests"
* Fix setting access token for non IDKit use cases"
* Fix network requests may not complete when no access token available"
* Fix network requests may not complete when no access token available

23.2.1 Release notes (2024-08-13)
=============================================================

### Fixes

* Fix setting access token for non IDKit use cases

23.2.0 Release notes (2024-07-25)
=============================================================

### Enhancements

* Add exponential backoff to refresh token request

### Internal

* Handling of 401 for authorized HTTP requests
* Fetch cofu payment methods from geojson instead of tiles

23.1.1 Release notes (2024-07-18)
=============================================================

### Internal

* Update fueling api to 2024-3

23.1.0 Release notes (2024-07-11)
=============================================================

### Enhancements

* Extend AppDrawer customizability
* Add userLocationAccuracy to AppData

23.0.1 Release notes (2024-06-13)
=============================================================

### Internal

* Adjust SDK for a better api code generation

23.0.0 Release notes (2024-05-23)
=============================================================

### Breaking Changes

* Update poi api to 2024-1
* Update pay api to 2024-2
* Update fueling api to 2024-2

### Internal

* Adjust bump script to correctly prune tags
* Bump version to 23.0.1"
* Bump version to 23.0.1
* Bump version to 23.0.0"
* Bump version to 23.0.0
* Adjust review deploy tag version
* Adjust unit tests to appropriate locale

22.0.1 Release notes (2024-05-14)
=============================================================

### Fixes

* Fix webview resets

### Internal

* Make AppDrawer class more accessible
* Integrate swiftlint as build tool plugin

22.0.0 Release notes (2024-04-18)
=============================================================

### Breaking Changes

* Update User API

21.0.0 Release notes (2024-02-19)
=============================================================

### Breaking Changes

* Update PayAPI
* Add fetch cofu stations within POIKit.BoundingBox

### Enhancements

* Implement shareFile message handler

20.0.0 Release notes (2023-11-29)
=============================================================

### Breaking Changes

* Add `POIKit.CofuGasStation` property to `POIKit.GasStation` if available
* Remove obsolete `POIModelConvertible`

### Fixes

* Fix completion handler of appviewcontroller not always being called

19.0.0 Release notes (2023-10-16)
=============================================================

### Breaking Changes

* Raise deployment target to ios 15

18.0.1 Release notes (2023-10-04)
=============================================================

### Internal

* Add privacy manifest
* Add fallback texts for `AppDrawer`

18.0.0 Release notes (2023-09-21)
=============================================================

### Breaking Changes

* Introduce `clientId` as required property for the SDK to be set up

### Internal

* Replace `pace-min` as the default `geoAppsScope` with the `clientId`

17.0.0 Release notes (2023-09-18)
=============================================================

### Breaking Changes

* Remove deprecated `AppKit` method `handleRedirectURL(URL)`
* Drop support for iOS 11 and 12

### Internal

* Upgrade project to Xcode 15

16.0.4 Release notes (2023-08-08)
=============================================================

### Fixes

* Fix building of app manifest url

### Internal

* Rename brand id field in tiles

16.0.3 Release notes (2023-07-06)
=============================================================

### Fixes

* Fix use of access token for custom requests

16.0.2 Release notes (2023-07-03)
=============================================================

### Internal

* Use the same user agent for every request
* Add missing utm_source parameter to CDN requests
* Remove `CMSAPIClient`
* Provide functionality to request navigation from client

16.0.1 Release notes (2023-06-27)
=============================================================

### Internal

* Update SwiftProtobuf to 1.22.0

16.0.0 Release notes (2023-06-16)
=============================================================

### Breaking Changes

* Update Fueling, Pay, POI and User API

### Enhancements

* [POIKit+GeoService] Provide requests using Swift Concurrency
* [API] Provide `makeRequest` function using Swift Concurrency
* [IDKit] Provide requests using swift concurrency

### Fixes

* Fix logger unit tests

### Internal

* Add `brandId` property to `POIKit.GasStation`

15.1.0 Release notes (2023-05-03)
=============================================================

### Enhancements

* Add danish localization

### Internal

* Revert "Only support arm64 architecture in Watch SDK"
* Only support arm64 architecture in Watch SDK
* Enable library evolution support for slim and watch SDK

15.0.1 Release notes (2023-04-26)
=============================================================

### Fixes

* Fix replyHandler called twice

15.0.0 Release notes (2023-04-20)
=============================================================

### Breaking Changes

* Remove geofence functionality

### Enhancements

* Add distance to AppDrawers when multiple apps are in range

### Fixes

* Fix pull in deploy jobs
* Fix push in deploy jobs
* Fix deploy dev job
* Fix opening hours calculations

### Internal

* Adjust deployment of dev and prod versions
* Remove atomic push in deploy jobs
* Correctly set branch for dev deploy job
* Integrate Slim and Watch SDK as SPM binaries
* Upgrade to Xcode 14.3

14.0.0 Release notes (2023-03-06)
=============================================================

### Breaking Changes

* Generate API 2022-1 for Fueling and Payment service
* Add method to `POIKit.POIKitManager` that returns a list of `POIKit.GasStation` for the specified ids
* Remove database delegates
* Rework logging

### Fixes

* Reset user API to 2021-2
* Add openid as default scope to authorization request
* Fix `POIKit.GasStation` initializer

### Internal

* Make `generateTOTP(Data, TimeInterval) -> String?` of `BiometryPolicy` publicly accessible
* Remove SDK dependency OneTimePassword
* Implement OneTimePassword and Base32
* Improve debug bundle handling

13.1.0 Release notes (2023-01-12)
=============================================================

### Enhancements

* Add new message handling for PWA communication

### Internal

* UserInfo request falls back to use `API.accessToken` if token of IDKit is not available
* Clean up environment variables

13.0.1 Release notes (2022-12-13)
=============================================================

### Fixes

* Area below app drawers is not hittable
* Fix InfoPlist of FuelingExampleApp
* Update persisted session in refresh

### Internal

* Make default OID configuration publicly accessible
* Remove enterprise account

13.0.0 Release notes (2022-12-01)
=============================================================

### Breaking Changes

* Implement exponential backoff for request connection errors and timeouts

### Enhancements

* Implement meta collector

### Fixes

* Fix accessing logger functions if logging is disabled

### Internal

* Improve log system
* Remove upload to repo server
* Upgrade to Xcode 14.1
* Make DeviceInformation publicly accessible
* Cleanup variables
* Adjust GitLab base URL
* Strip debug symbols during copy
* Remove user sensitive data from logs
* Rework log levels
* Adjust example app to SDK changes
* Add fuel.site to list of trusted domains
* Add migration guide for 11->12

12.0.0 Release notes (2022-10-06)
=============================================================

### Breaking Changes

* Upgrade to XCode 14

### Enhancements

* Scope user specific data to user id
* Implement fueling example app
* Add options to retrieve an OTP via biometry, pin and password

### Fixes

* Fix handling activated links in AppWebViews
* Fix showing error screen in webviews and enhance error handling
* Adjust modifying requests via request behaviors

### Internal

* Remove GeoJSON API leftovers
* Update Fueling API
* Update Pay API
* Update User API
* Update POI API
* Use Xcode 14 runner
* Support absolute paths in manifest
* Make ci jobs interruptible
* Adjust repo upload params

11.0.0 Release notes (2022-08-11)
=============================================================

### Breaking Changes

* Remove the stage environment
* Remove unnecessary fatal error calls

### Fixes

* 0 instead of nil accuracy in verifyLocation
* Fix dispatching the completion block on the main thread when ending a session
* Fix payment method vendor icons url

### Internal

* Add migration guide for stage removal
* Retrieve geojson from cdn
* Scope session object to environment
* Make createdAt property of Double type
* Remove bot configs
* Add createdAt to UserInfo
* Update documentation link
* Update gems

10.0.0 Release notes (2022-06-08)
=============================================================

### Breaking Changes

* Properly remove keycloak session
* Integrate adapted pay api
* Remove geojson api
* Integrate adapted poi api
* Integrate adapted user api
* Integrate adapted fueling api
* Fix token expiry date validation
* Introduce CDN client to fetch payment method vendors and icons
* Integrate adjusted poly type generation
* Check cofustatus of cofugasstation
* Remove native apple pay handling

### Enhancements

* Add callback to report breadcrumbs and general sdk errors to client
* Implement interface for customized localization
* Adjust `isCoFuGasStation` property to also reflect geojson online status
* Add `isCoFuGasStation` to `POIKit.GasStation` model
* Implement alternative user agent for authorization flow
* Add functionality to extract payment method kinds from jwt"
* Add more localization
* Add functionality to extract payment method kinds from jwt

### Fixes

* Fix required label name
* Fix typo in GitLab bot config
* Fix general logging issues and rework logging tests
* Return correct unix timestamps of closing times
* Correct type of `logo` property in `PaymentMethodVendor`
* Intercept app webview redirect
* Use pace cloud sdk environment for log files

### Internal

* Upgrade OneTimePassword to 3.3.2
* Update cocoapods dependency
* Integrate Japx
* Add `fuelingURLs` property to `POIKit.CofuGasStation` model and extract its value from geojson file
* Add label config for PACEBot
* Remove GitLab issue templates
* Update GitLab templates
* Make `BiometryTOTPData` publicly accessible
* Add function to retrieve a single payment method vendor icon
* Introduce authorization canceled error
* Add default implementations for `AppKitDelegate` `didReceiveAppDrawers(...)` and `didFail(...)`
* Improve error handling of api requests on failed token refreshs
* Make AnyCodable value accessible
* Add IDKit to PACECloudSlimSDK
* Make logger functions overridable
* Add url to api request failure log message
* Remove apps query fallback
* Cleanup documentation in index md
* Correctly open new tab webview on multiple openInNewTab requests
* Remove all obsolete POI files from PACECloudSlimSDK
* Extract apple pay session scope from access token"
* Lokalise updates
* Extract apple pay session scope from access token
* Add job to build a xcframework for the slim sdk
* Add issue templates
* Introduce decimal decoding tests
* Update Fueling and Pay API

9.2.1 Release notes (2022-01-21)
=============================================================

### Fixes

* Fix Swift variable shadowing problems

### Internal

* Add job to validate commit messages
* Remove changelog template
* Add script for auto semantic versioning

9.2.0 Release notes (2021-12-07)
=============================================================

### Enhancements

* Add `additionalProperties` property to `POIKit.GasStation`
* The `domainACL` will now be set to `pace.cloud` by default
* Introduce `PACECloudSDK.shared.application(open:)` to handle deep links. Please use this method to handle incoming redirect URLs as `AppKit.handleRedirectURL(url:)` is now deprecated and will be removed in a future version.
* Add option to evaluate the biometry policy without handling a totp

### Fixes

* Fix default implementation for `didReceiveImageData(UIImage)` and `didReceiveText(String,String)` in `AppKitDelegate` when triggered multiple times

### Internal

* Adjust API URLs
* Adjust invalidation token handling for `POIKit.BoundingBoxNotitficationToken`
* Forward `PACECloudSDK.shared.additionalQueryParams` to `IDKit.OIDConfiguration.additionalParameters`
* Adjust `Bundle.main.bundleName` to now return bundle name with whitespaces.
* Add `Bundle.main.bundleNameWithoutWhitespaces` which returns bundle name without whitespaces.
* Add `integrated` parameter to `openURLInNewTab` communication request

9.1.0 Release notes (2021-11-09)
=============================================================

### Fixes

* Regenerate Fueling and Pay 2021-2 API which replaces number types with decimal format from Double to Decimal due to floating precision problems of Double when using JSONDecoder and JSONEncoder.
### Enhancements

* Add `IDKitDelegate` method `willResetSession()` that is triggered when a session is about to be reset.
* Introduce share text call `handleShareText`
* Add dashboard url to `PACECloudSDK.URL`

### Internal

* Adjust TOTP secret handling

9.0.0 Release notes (2021-10-14)
=============================================================

### Breaking Changes

* `TokenValidator` is now part of `IDKit` instead of `AppKit`
* The response of `POIKit.requestCoFuGasStation(center:, radius:)` does not filter the stations by their online status any more.
* Implement default receipt image download handling (Requires `NSPhotoLibraryUsageDescription` to be set in target properties)
* Update all apis to v2021-2 - GeoJSON, Fueling, Pay, POI and User ([Documentation](https://developer.pace.cloud/api))
* Change default geo apps scope - When not specifying a custom `geoAppsScope` in the SDK configuration the `POIKit.CofuGasStation` property `polygon` will from now on be `nil`.
* For all `AppViewController` instances the property `isModalInPresentation` is now `true` by default. Setting it to `false` can be done via the initializer or afterwards by directly accessing the property.
* Rework Logger - `PACECloudSDKLoggingDelegate` does not exist any more.

### Enhancements

* Implement new price history endpoints
* Add bearing to `GetLocation` call
* Add 'isSignedIn' sdk call
* Add `isRemoteConfigAvailable` call

### Fixes

* Fix Fueling PWA's URL for non-prod environments
* Correctly remove app drawers based on the user's location if the speed threshold has been exceeded
* Fix close call in `redirect_uri`
* Fix system passcode fallback for biometric authentication

### Internal

* Remove default timeout in communication api
* Respond with 405 if communication operation doesn't exist
* Enable bitcode for the `PACECloudSDK` target
* Upgrade to XCode 13
* Use system font instead of embedding SFUIDisplay

8.0.0 Release notes (2021-08-16)
=============================================================

### Breaking Changes

* Set default `authenticationMode` of the SDK to `.native`.  
> **_NOTE:_** If you are not using native authentication make sure to explicitely set the mode to `.web` in the SDK configuration if it isn't already.
* The data type of the completion parameter for the `didCreateApplePayPaymentRequest` callback has been changed from `[String: Any]?` to `API.Communication.ApplePayRequestResponse?`
* The data type of the completion parameter for the `getAccessToken` callback has been changed from `AppKit.GetAccessTokenResponse` to `API.Communication.GetAccessTokenResponse`
* AppKit's `isPoiInRange(...)` is now part of `POIKit`, available under `POIKit.isPoiInRange(...)`
* AppKit's `requestCofuGasStations(...)` is now part of `POIKit`, available under `POIKit.requestCofuGasStations(...)`
* AppKit's model `CofuGasStation` is now part of `POIKit`, available under `POIKit.CofuGasStation`
* AppKit's `shared` property is no longer publicly accessible. All methods and properties of type `AppKit.shared.fooBar()` are now accessible via `AppKit.fooBar()`
* The data type of the completion parameter of AppKit's `fetchListOfApps(...)` has been changed from `([AppKit.AppData]?, AppKit.AppError?)` to `(Result<[AppKit.AppData], AppKit.AppError>)`
* The parameter `poisOfType` has been removed from POIKitManager's methods `fetchPOIs(boundingBox:)` and `loadPOIs(boundingBox:)`
* POIKitManager's `loadPOIs(locations:)` has been renamed to `fetchPOIs(locations:)`
* The data type of the completion parameter of IDKit's `authorize(...)` has been changed from `(String?, IDKitError?)` to `(Result<String?, IDKitError>)`
* The data type of the completion parameter of IDKit's `refreshToken(...)` has been changed from `(String?, IDKitError?)` to `(Result<String?, IDKitError>)`
* The data type of the completion parameter of IDKit's `discoverConfiguration(...)` has been changed from `(String?, String?, IDKitError?)` to `(Result<OIDConfiguration.Response, IDKitError>)`
* The data type of the completion parameter of IDKit's `userInfo(...)` has been changed from `(UserInfo?, IDKitError?)` to `(Result<UserInfo, IDKitError>)`

### Enhancements

* Add callback `didPerformAuthorization` to `IDKitDelegate` to inform client about an authentication triggered via an app
* Show AppDrawer based on distance instead of an area
* Add new `func currentLocation(completion: @escaping (CLLocation?) -> Void)` callback to `AppKitDelegate`. This request only gets called if an app requests the user's current location and the SDK can't retrieve a valid one.
* Add new target for watch application
* Add code documentation for most of AppKit's and POIKit's / POIKitManager's calls
* Add `AppRedirect` handler to PWA communication to let the client app decide if a redirect from the current PWA to another specified PWA should be allowed
* Add methods to `IDKit` that returns the user's payment methods, transactions and checks the PIN requirements
* Add `requestCofuGasStations` method to `POIKit` with location and radius parameter that returns connected fueling gas stations with detailed information
* Add optional location parameter to `isPoiInRange` call

### Fixes

* Don't reset session before refreshing if session isn't even available
* Fix overlapping labels in AppDrawer
* Fix generation of accept headers
* Adjust handling of too large bounding boxes when requesting tiles
* Adjust sdk error view
* Fix encoding issue when enabling biometric authentication
* Fix string encoding when evaluating javascript
* Make multiple cofu gas station requests in quick succcession possible and return correct response to all of them
* Fix decoding of `ApproachingAtForecourt` success response 

### Internal

* Rework communication between apps and SDK
* Implement `isBiometryAuthEnabled` call
* Include `POIKit` in `PACECloudWatchSDK`

7.0.0 Release notes (2021-06-30)
=============================================================

### Breaking Changes

* Added new SDK methods `getAccessToken` and 'logout'. The `getAccessToken` call replaces the `invalidToken` method.
* Update all APIs. Previously included enums have been removed. The corresponding properties that were of type of those enums are now directly of type of their former raw representable. 
* Remove `resetAccessToken()` from the `PACECloudSDK.shared` property. This functionality is no longer needed.
* Implement automatic session handling for apps. If `IDKit` is used the SDK will now try to renew the session automatically when an app requests a new token. In this case the `getAccessToken` callback will no longer be called. If the renewal fails an `IDKitDelegate` may be implemented to specify a custom behaviour for the token retrieval. Otherwise the sign in mask will be shown.
* Combine IDKit setup with PACECloudSDK setup. `IDKit.setup(...)` is no longer accessible. The IDKit may now be set up by either passing a custom oid configuration to the `PACECloudSDK.Configuration` or by adding both `PACECloudSDKOIDConfigurationClientID` and `PACECloudSDKOIDConfigurationRedirectURI` with non-empty values to your Info.plist which invokes the setup with the default PACE OID configuration.  
* The presenting view controller for the sign in mask now needs to be set directy via `IDKit.presentingViewController`
* `IDKit.OIDConfiguration`'s property `redirectUrl` has been renamed to `redirectUri`.

### Enhancements

* Introduce `requestCofuGasStations` to `AppKit` to fetch all available `CofuGasStation` which will have an attribute to tell you, if a gas station is currently online
* If using IDKit it is no longer required to set the `Authorization` header for any requests performed by the SDK. It will be included automatically.
* Close app if it contains a specific redirect uri
* Add function to load pois based on their location via the tiles request
* Automatically retry unauthorized api requests

### Fixes

* Fix a bug where PWA wasn't closed properly in the AppDrawer
* Don't retrieve any apps if speed threshold is exceeded

### Internal

* Refactored the handling of ApplePay requests. The updated callback now already returns a `PKPaymentRequest`. Additionally a new callback to retrieve the `merchantIdentifier` needs to be implemented
* Improve selection of app drawer icon size
* Rename `GeoGasStation` to `CofuGasStation` to match capabilities of the new Geo API
* Upgrade to XCode 12.5

6.3.0 Release notes (2021-06-01)
=============================================================

### Enhancements

* Make 'Keychain' wrapper accessible
* Make app drawer more robust by allowing a threshold of 150m in which it won't be removed if no other apps are available
* Implemented console warning for a missing `domainACL` if using 2FA methods

### Fixes

* Fix date encoding to use UTC time format instead of local
* Handle 403 response correctly for `setPIN(with otp:)`
* Fix wrong status code data type in PWA communication
* Fix faulty message when authorizing biometric authentication
* Implement default completion handlers for `AppKitDelegate` 

### Internal

* Speed up verify location call
* Set default utm source
* Don't send empty network list to Apple Pay availability check
* Return location accuracy in `verifyLocation` call

6.2.0 Release notes (2021-05-12)
=============================================================

### Enhancements

* Refactor `isPoiInRange` check so that it no longer checks if the position is within the POI's polygon, but if the beeline distance to the POI is within 500m

### Internal

* Improve completion handling of location manager

6.1.1 Release notes (2021-05-04)
=============================================================

### Fixes

* Fix accept header of Pay API
* Fix completion call for isPoiInRange

### Internal

* Introduce tracing identifier

6.1.0 Release notes (2021-04-28)
=============================================================

### Enhancements

* Adjust error case of tile request
* Add `cofuPaymentMethods` property to `GasStation`
* Enable biometry after authorization
* Add pre check during setup

### Fixes

* Fix PWA communication for iOS < 13
* Regenerate Pay API `2020-4`, which includes removal of enums to prevent the clients from crashing when new values are added

### Internal

* Remove PWA preloading in AppDrawer
* Implement PWA callback cache
* Improve error handling for PWA communication
* Cleanup Xcode warnings
* Make PACECloudSDK's environment short name accessible
* Introduce timeouts for PWA communication

6.0.0 Release notes (2021-04-08)
=============================================================
### Breaking Changes

* Remove raw representable conformance of `URL`
* Changed handling of Apple Pay responses
* Pass `reason` and `oldToken` in the `tokenInvalid` callback.
> **_NOTE:_** Remember to adjust the implementation of your `tokenInvalid` function.

### Enhancements

* Make more `AppManifest` properties publicly accessible
* Add interfaces to handle pin and biometry actions
* Enable the passcode fallback for 2FA
* Add `presetUrl` for `fueling`
* Add raw representable `init` to `URL` for cases without parameters
* Add optional invalidation token use to poi requests
* Implement analytic events

### Internal

* Adjust POIKit's user agent to include the client's name
* Adjust dependencies for SPM support
* Refactor the 2FA communication with the PWAs

5.0.1 Release notes (2021-03-23)
=============================================================

### Fixes

* Fix PWA communication for request without message content

5.0.0 Release notes (2021-03-22)
=============================================================
### Breaking Changes

* Remove `force` parameter from `refreshSession`
* AppData's `appManifest` and `appID` aren't publicly settable anymore 

### Enhancements

* Always force refresh session
* Reset session if refresh fails with error other than `noNetwork`
* Use geo service cache for `isPoiInRange()` check
* Do not fetch an `AppManifest` for `isPoiInRange()` check
* Make AppData's `poiId` and `appStartUrl` accessible

### Fixes

* Fix tiles API
* Fix accept header for api requests 

### Internal

* Improve communication with PWA
* Fix threading issue in `InvalidationTokenCache`

4.0.0 Release notes (2021-03-04)
=============================================================
### Breaking Changes

* Remove PoiKitManager property from SDK singleton
* Remove passing of initial access token
* Adjust handling of redirect scheme

### Enhancements

* Add slimmed version of SDK as target
* Implement `verifyLocation` check communication between SDK and web apps
* Pass location verification threshold to client
* Add option to add additional query params to request
* Add generated Pay API
* Adjust QueryParamHandler to ignore set of pre-defined URLs
* Change PWA URL actions to JS message handlers
* Add dynamic zoom level changes
* Implement functionality to retrieve live response from POIKitObserverTokens
* Make PWA manifest's data accessible
* Add generated Fueling API
* Add convenience methods for most common urls, i.e. fueling, payment, and transaction
* Add generated User API
* Intercept PWA logs and pass all logs to client
* Make appViewController of drawer more accessible
* Always call isPoiInRange completion handler
* Implement back handler for PWAs
* Add generated GeoJson API
* Support invalidation token when requesting tiles
* Add functionality to check for available apps on device by using a cached version of all app polygons

### Fixes

* Fix auto closing AppViewController if presenting view is the rootViewController
* Fix API Key header
* Fix acccess to bundle when integrating the SDK via SPM

### Internal

* Update Xcode version tag and fix CI script
* Use SPM instead of Carthage as package dependency manager
* Change PWA actions to message handlers

3.0.1 Release notes (2020-12-22)
=============================================================

### Fixes

* Include property lists in CocoaPods resources

3.0.0 Release notes (2020-12-22)
=============================================================

### Breaking changes

* Introduce universal setup for PACE Cloud SDK

### Enhancements

* Automatically update CocoaPods trunk on tag
* Upload docs to Developer Hub on tag

2.0.2 Release notes (2020-12-17)
=============================================================

### Enhancements

* Remove obsolete references to Alamofire and CloudSDK from SDK and example app
* Add Apple Pay communication with web apps
* Remove "Enter password" as fallback when biometric authentication fails

### Fixes

* Fix problem where the manifest.json couldn't be fetched
* Fix missing localization and assets

2.0.1 Release notes (2020-12-08)
=============================================================

### Enhancements

* Add support for CocoaPods

2.0.0 Release notes (2020-12-07)
=============================================================

* Initial PACE Cloud SDK replacing the old Cloud SDK
