# POIAPI

This is an api generated from a OpenAPI 3.0 spec with [SwagGen](https://github.com/pace/SwagGen)

## Operation

Each operation lives under the `POIAPI` namespace and within an optional tag: `POIAPI(.tagName).operationId`. If an operation doesn't have an operationId one will be generated from the path and method.

Each operation has a nested `Request` and a `Response`, as well as a static `service` property

#### Service

This is the struct that contains the static information about an operation including it's id, tag, method, pre-modified path, and authorization requirements. It has a generic `ResponseType` type which maps to the `Response` type.
You shouldn't really need to interact with this service type.

#### Request

Each request is a subclass of `POIAPIRequest` and has an `init` with a body param if it has a body, and a `options` struct for other url and path parameters. There is also a convenience init for passing parameters directly.
The `options` and `body` structs are both mutable so they can be modified before actually sending the request.

#### Response

The response is an enum of all the possible responses the request can return. it also contains getters for the `statusCode`, whether it was `successful`, and the actual decoded optional `success` response. If the operation only has one type of failure type there is also an optional `failure` type.

## Model
Models that are sent and returned from the API are mutable classes. Each model is `Equatable` and `Codable`.

`Required` properties are non optional and non-required are optional

All properties can be passed into the initializer, with `required` properties being mandatory.

If a model has `additionalProperties` it will have a subscript to access these by string

## POIAPIClient
The `POIAPIClient` is used to encode, authorize, send, monitor, and decode the requests. There is a `POIAPIClient.default` that uses the default `baseURL` otherwise a custom one can be initialized:

```swift
public init(baseURL: String, sessionManager: SessionManager = .default, defaultHeaders: [String: String] = [:], behaviours: [POIAPIRequestBehaviour] = [])
```

#### POIAPIClient properties

- `baseURL`: The base url that every request `path` will be appended to
- `behaviours`: A list of [Request Behaviours](#requestbehaviour) to add to every request
- `session`: An `URLSession` that can be customized
- `defaultHeaders`: Headers that will be applied to every request
- `decodingQueue`: The `DispatchQueue` to decode responses on

#### Making a request
To make a request first initialize a [Request](#request) and then pass it to `makeRequest`. The `complete` closure will be called with an `POIAPIResponse`

```swift
func makeRequest<T>(_ request: POIAPIRequest<T>, behaviours: [POIAPIRequestBehaviour] = [], queue: DispatchQueue = DispatchQueue.main, complete: @escaping (POIAPIResponse<T>) -> Void) -> Request? {
```

Example request (that is not neccessarily in this api):

```swift

let getUserRequest = POIAPI.User.GetUser.Request(id: 123)
let apiClient = POIAPIClient.default

apiClient.makeRequest(getUserRequest) { apiResponse in
    switch apiResponse {
        case .result(let apiResponseValue):
        	if let user = apiResponseValue.success {
        		print("GetUser returned user \(user)")
        	} else {
        		print("GetUser returned \(apiResponseValue)")
        	}
        case .error(let apiError):
        	print("GetUser failed with \(apiError)")
    }
}
```

Each [Request](#request) also has a `makeRequest` convenience function that uses `POIAPI.shared`.

#### POIAPIResponse
The `POIAPIResponse` that gets passed to the completion closure contains the following properties:

- `request`: The original request
- `result`: A `Result` type either containing an `APIClientError` or the [Response](#response) of the request
- `urlRequest`: The `URLRequest` used to send the request
- `urlResponse`: The `HTTPURLResponse` that was returned by the request
- `data`: The `Data` returned by the request.

#### Encoding and Decoding
Only JSON requests and responses are supported. These are encoded and decoded by `JSONEncoder` and `JSONDecoder` respectively, using Swift's `Codable` apis.
There are some options to control how invalid JSON is handled when decoding and these are available as static properties on `POIAPI`:

Dates are encoded and decoded differently according to the swagger date format. They use different `DateFormatter`'s that you can set.
- `date-time`
    - `DateTime.dateEncodingFormatter`: defaults to `yyyy-MM-dd'T'HH:mm:ss.Z`
    - `DateTime.dateDecodingFormatters`: an array of date formatters. The first one to decode successfully will be used
- `date`
    - `DateDay.dateFormatter`: defaults to `yyyy-MM-dd`

#### APIClientError
This is error enum that `POIAPIResponse.result` may contain:

```swift
public enum APIClientError: Error {
    case unexpectedStatusCode(statusCode: Int, data: Data)
    case decodingError(DecodingError)
    case requestEncodingError(String)
    case validationError(String)
    case networkError(Error)
    case unknownError(Error)
}
```

#### POIAPIRequestBehaviour
Request behaviours are used to modify, authorize, monitor or respond to requests. They can be added to the `POIAPIClient.behaviours` for all requests, or they can passed into `makeRequest` for just that single request.

`POIAPIRequestBehaviour` is a protocol you can conform to with each function being optional. As the behaviours must work across multiple different request types, they only have access to a typed erased `AnyPOIAPIRequest`.

```swift
public protocol POIAPIRequestBehaviour {

    /// runs first and allows the requests to be modified. If modifying asynchronously use validate
    func modifyRequest(request: AnyPOIAPIRequest, urlRequest: URLRequest) -> URLRequest

    /// validates and modifies the request. complete must be called with either .success or .fail
    func validate(request: AnyPOIAPIRequest, urlRequest: URLRequest, complete: @escaping (RequestValidationResult) -> Void)

    /// called before request is sent
    func beforeSend(request: AnyPOIAPIRequest)

    /// called when request successfuly returns a 200 range response
    func onSuccess(request: AnyPOIAPIRequest, result: Any)

    /// called when request fails with an error. This will not be called if the request returns a known response even if the a status code is out of the 200 range
    func onFailure(request: AnyPOIAPIRequest, error: APIClientError)

    /// called if the request recieves a network response. This is not called if request fails validation or encoding
    func onResponse(request: AnyPOIAPIRequest, response: AnyPOIAPIResponse)
}
```

### Authorization
Each request has an optional `securityRequirement`. You can create a `POIAPIRequestBehaviour` that checks this requirement and adds some form of authorization (usually via headers) in `validate` or `modifyRequest`. An alternative way is to set the `POIAPIClient.defaultHeaders` which applies to all requests.

#### Reactive and Promises
To add support for a specific asynchronous library, just add an extension on `POIAPIClient` and add a function that wraps the `makeRequest` function and converts from a closure based syntax to returning the object of choice (stream, future...ect)

## Models

- **PCPOIAppPOIsRelationshipsRequest**
- **PCPOIAppPOIsRelationships**
- **PCPOICategories**
- **PCPOICategory**
- **PCPOICommonCountryId**
- **PCPOICommonGeoJSONPoint**
- **PCPOICommonGeoJSONPolygon**
- **PCPOICommonLatLong**
- **PCPOICommonOpeningHours**
- **PCPOICurrency**
- **PCPOIDedupeRequest**
- **PCPOIErrors**
- **PCPOIEvent**
- **PCPOIEvents**
- **PCPOIFieldData**
- **PCPOIFieldMetaData**
- **PCPOIFieldName**
- **PCPOIFuel**
- **PCPOIFuelAmountUnit**
- **PCPOIFuelPrice**
- **PCPOIFuelPriceResponse**
- **PCPOIFuelType**
- **PCPOIGasStation**
- **PCPOIGasStations**
- **PCPOILocationBasedAppRequest**
- **PCPOILocationBasedApp**
- **PCPOILocationBasedAppWithRefs**
- **PCPOILocationBasedApps**
- **PCPOILocationBasedAppsWithRefs**
- **PCPOIMoveRequest**
- **PCPOIPOIRequest**
- **PCPOIPOI**
- **PCPOIPOIType**
- **PCPOIPOIs**
- **PCPOIPolicies**
- **PCPOIPolicyRequest**
- **PCPOIPolicy**
- **PCPOIPolicyRule**
- **PCPOIPolicyRulePriority**
- **PCPOIPriceHistory**
- **PCPOIReferenceStatusRequest**
- **PCPOIReferenceStatus**
- **PCPOIReferenceStatuses**
- **PCPOIRegionalPrices**
- **PCPOISourceRequest**
- **PCPOISource**
- **PCPOISources**
- **PCPOIStats**
- **PCPOISubscriptionRequest**
- **PCPOISubscription**

## Requests

- **POIAPI.Admin**
	- **DeduplicatePoi**: PATCH `/admin/poi/dedupe`
	- **MovePoiAtPosition**: PATCH `/admin/poi/move`
- **POIAPI.Apps**
	- **CheckForPaceApp**: GET `/apps/query`
	- **CreateApp**: POST `/apps`
	- **DeleteApp**: DELETE `/apps/{appid}`
	- **GetApp**: GET `/apps/{appid}`
	- **GetAppPOIsRelationships**: GET `/apps/{appid}/relationships/pois`
	- **GetAppRedirect**: GET `/apps/{appid}/redirect`
	- **GetApps**: GET `/apps`
	- **UpdateApp**: PUT `/apps/{appid}`
	- **UpdateAppPOIsRelationships**: PATCH `/apps/{appid}/relationships/pois`
- **POIAPI.DataDumps**
	- **GetDuplicatesKML**: GET `/datadumps/duplicatemap/{countrycode}`
	- **GetPoisDump**: GET `/datadumps/pois`
- **POIAPI.Delivery**
	- **DeleteGasStationReferenceStatus**: DELETE `/delivery/gas-stations/{gasstationid}/reference-status/{reference}`
	- **PutGasStationReferenceStatus**: PUT `/delivery/gas-stations/{gasstationid}/reference-status/{reference}`
- **POIAPI.Events**
	- **GetEvents**: GET `/events`
- **POIAPI.GasStations**
	- **GetGasStation**: GET `/gas-stations/{id}`
	- **GetGasStationFuelTypeNameMapping**: GET `/gas-stations/{id}/fueltype`
	- **GetGasStations**: GET `/gas-stations`
- **POIAPI.MetadataFilters**
	- **GetMetadataFilters**: GET `/meta`
- **POIAPI.POI**
	- **ChangePoi**: PATCH `/pois/{poiid}`
	- **GetPoi**: GET `/pois/{poiid}`
	- **GetPois**: GET `/pois`
- **POIAPI.Policies**
	- **CreatePolicy**: POST `/policies`
	- **GetPolicies**: GET `/policies`
	- **GetPolicy**: GET `/policies/{policyid}`
- **POIAPI.PriceHistories**
	- **GetPriceHistory**: GET `/gas-stations/{id}/fuel-price-histories/{fuel_type}`
- **POIAPI.Prices**
	- **GetRegionalPrices**: GET `/prices/regional`
- **POIAPI.Sources**
	- **CreateSource**: POST `/sources`
	- **DeleteSource**: DELETE `/sources/{sourceid}`
	- **GetSource**: GET `/sources/{sourceid}`
	- **GetSources**: GET `/sources`
	- **UpdateSource**: PUT `/sources/{sourceid}`
- **POIAPI.Stats**
	- **GetStats**: GET `/stats`
- **POIAPI.Subscriptions**
	- **DeleteSubscription**: DELETE `/subscriptions/{id}`
	- **GetSubscriptions**: GET `/subscriptions`
	- **StoreSubscription**: PUT `/subscriptions/{id}`
- **POIAPI.Tiles**
	- **GetTiles**: POST `/v1/tiles/query`
