# PACE Cloud SDK – iOS

- [PACE Cloud SDK](#pace-cloud-sdk)
    * [Documentation](#documentation)
    * [Source code](#source-code)
    * [Migration](#migration)
        + [2.x.x -> 3.x.x](#from-2xx-to-3xx)
        + [3.x.x -> 4.x.x](#from-3xx-to-4xx)
        + [4.x.x -> 5.x.x](#from-4xx-to-5xx)
        + [5.x.x -> 6.x.x](#from-5xx-to-6xx)
        + [6.x.x -> 7.x.x](#from-6xx-to-7xx)
        + [7.x.x -> 8.x.x](#from-7xx-to-8xx)
        + [8.x.x -> 9.x.x](#from-8xx-to-9xx)
        + [9.x.x -> 10.x.x](#from-9xx-to-10xx)
    * [Contribute](#contribute)
        + [Localizable Strings Generation](#localizable-strings-generation)

## Documentation
The full documentation and instructions on how to integrate PACE Cloud SDK can be found [here](https://docs.pace.cloud/en/integrating/mobile-app).

## Source code
The complete source code of the SDK can be found on [GitHub](https://github.com/pace/cloud-sdk-ios).

## Migration
### From 2.x.x to 3.x.x
In `3.0.0` we've introduced a universal setup method: `PACECloudSDK.shared.setup(with: PACECloudSDK.Configuration)` and removed the setup for `AppKit` and `POIKitManager`.

The `PACECloudSDK.Configuration` almost has the same signature as the previous `AppKit.AppKitConfiguration`, only the `theme` parameter has been removed, which is now defaulted to `.automatic`. In case you want to set a specific theme, you can set it via `AppKit`'s `theme` property: `AppKit.shared.theme`.

### From 3.x.x to 4.x.x
In `4.0.0` we've simplified the setup even further.

The `PACECloudSDK.Configuration` doesn't take an `initialAccessToken` anymore and will (as before) request the token when needed via the `tokenInvalid` callback.

Furthermore, the handling of the redirect scheme has been updated. The SDK automatically retrieves the URL scheme from your app's `Info.plist`, therefore no `clientId` needs to be set within the `PACECloudSDK.shared.setup()` anymore.

The `PoiKitManager` has been removed as `PACECloudSDK`'s instance property. Instead it can be initialized directly via `POIKit.POIKitManager(environment:)`.

### From 4.x.x to 5.x.x
In `5.0.0` we've removed the option to pass a `force` parameter to the `IDKit.refreshSession(...)` call.

### From 5.x.x to 6.x.x
We've added more information in the `tokenInvalid` callback, thus the client can better react to the callback, i.e. a `reason` and the `oldToken` (if one has been passed before), will be included in the callback.

### From 6.x.x to 7.x.x
In version `7.x.x` we've made some big `AppKit` and `IDKit` changes.

- `AppKit`'s `invalidToken` callback has been replaced with a new `getAccessToken` callback.
  + If you're **not** using `IDKit` this callback will be invoked and will have the same functionality as `invalidToken` before.
  + However if you **are** using and having set up `IDKit` the behavior now heavily changes:
    - `getAccessToken` will not be called anymore.
    - Instead `IDKit` first starts an attempt to refresh the session automatically.
    - If the session renewal fails there is a new `func didFailSessionRenewal(with error: IDKit.IDKitError?, _ completion: @escaping (String?) -> Void)` function that you may implement to specify your own behaviour for retrieving a new access token. This can be achieved by specifying an `IDKitDelegate` conformance and setting the `IDKit.delegate` property.
    -  If either this delegate method is not implemented or you didn't set the delegate property at all the SDK will automatically perform an authorization hence showing a sign in mask for the user
- The `IDKit` setup has been combined with the general SDK setup.
  + `IDKit.setup(...)` is no longer accessible.
  + By adding the keys `OIDConfigurationClientID` and `OIDConfigurationRedirectURI` with non-empty values to your `Info.plist` `IDKit` will be initiated with the default PACE OID configuration.
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

- Miscellaneous
  + `API.Communication.ApplePayRequestRequest`, `API.Communication.ApplePayRequestResponse` and the two callbacks in `AppKitDelegate` `paymentRequestMerchantIdentifier(completion: @escaping (String) -> Void)` + `didCreateApplePayPaymentRequest(_ request: PKPaymentRequest, completion: @escaping (API.Communication.ApplePayRequestResponse?) -> Void)` have been removed.
  + The `cofuStatus` property of `CofuGasStation` is now optional. This way it correctly reflects the connected fueling status in case the original value is missing in the API response
  + The methods of `IDKit.TokenValidator` are no longer `static`. Instead create an instance and pass your access token in the initializer.
- API
  + The `GeoJSON` API has been completely removed from the SDK. In case you still need this API, please open up an issue at https://github.com/pace/cloud-sdk-ios/issues and tell us about your use case.
  + The suffix `Request` has been added to all API models that are used as request body.
  + The structure of _all_ API response models has changed (the models have been flattened).
    + Enclosing types like `Attributes`, `Relationships`, `Included` and inner `DataType` have been removed from the response models.
    + The corresponding properties have been added on the same hierarchy level as their respective former enclosing type.
    + Example: `FuelingAPI.Fueling.ApproachingAtTheForecourt`
        ```swift
          let request = FuelingAPI.Fueling.ApproachingAtTheForecourt.Request(gasStationId: "SOME_ID")
        
          // Old respone model structure until SDK version 9.x.x
          API.Fueling.client.makeRequest(request) { [weak self] response in
              switch response.result {
              case .success(let result):
                  let gasStation = result.success?.included?.compactMap { $0.gasStation }.first
                  let gasStationAddress = gasStation?.attributes?.address
                
                  let unsupportedPaymentMethods = result.success?.data?.relationships?.unsupportedPaymentMethods
            
              case .failure(let error):
                  // Some error handling
              }
          }
        
          // New response model structure from SDK version 10.x.x
          API.Fueling.client.makeRequest(request) { [weak self] response in
              switch response.result {
              case .success(let result):
                  let responseData = result.success?.data
        
                  let gasStation = responseData?.gasStation
                  let gasStationAddress = gasStation?.address
                
                  let unsupportedPaymentMethods = responseData?.unsupportedPaymentMethods
            
              case .failure(let error):
                  // Some error handling
              }
          }
        ```
  + `IDKit.resetSession` now either provides a success or a `IDKitError` within it's completion block.

## Contribute
### Localizable Strings Generation
To generate our localized strings that are part of `AppKit` we use [SwiftGen](https://github.com/SwiftGen/SwiftGen).  
Path to `Strings` file: `PACECloudSDK/Generated/Strings.swift`  
Path to `Localizable` files: `PACECloudSDK/AppKit/Localization`
