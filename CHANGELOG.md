x.y.z Release notes (yyyy-MM-dd)
=============================================================

### Breaking Changes

* Added new SDK methods `getAccessToken` and 'logout'. The `getAccessToken` call replaces the `invalidToken` method.
* Update all APIs. Previously included enums have been removed. The corresponding properties that were of type of those enums are now directly of type of their former raw representable. 
* Remove `resetAccessToken()` from the `PACECloudSDK.shared` property. This functionality is no longer needed.
* Implement automatic session handling for apps. If `IDKit` is used the SDK will now try to renew the session automatically when an app requests a new token. In this case the `getAccessToken` callback will no longer be called. If the renewal fails an `IDKitDelegate` may be implemented to specify a custom behaviour for the token retrieval. Otherwise the sign in mask will be shown.

### Enhancements

* Introduce `requestCofuGasStations` to `AppKit` to fetch all available `CofuGasStation` which will have an attribute to tell you, if a gas station is currently online
* If using IDKit it is no longer required to set the `Authorization` header for any requests performed by the SDK. It will be included automatically.
* Close app if it contains a specific redirect uri

### Fixes

* Fix a bug where PWA wasn't closed properly in the AppDrawer
* Don't retrieve any apps if speed threshold is exceeded

### Internal

* Refactored the handling of ApplePay requests. The updated callback now already returns a `PKPaymentRequest`. Additionally a new callback to retrieve the `merchantIdentifier` needs to be implemented
* Improve selection of app drawer icon size
* Rename `GeoGasStation` to `CofuGasStation` to match capabilities of the new Geo API

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
