x.y.z Release notes (yyyy-MM-dd)
=============================================================

<!-- ### Breaking Changes - Include, if needed -->
### Enhancements

### Fixes
* Fix PWA communication for iOS < 13

### Internal
* Remove PWA preloading in AppDrawer

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
