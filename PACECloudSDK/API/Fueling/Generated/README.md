# FuelingAPI

This is an api generated from a OpenAPI 3.0 spec with [SwagGen](https://github.com/pace/SwagGen)

## Operation

Each operation lives under the `FuelingAPI` namespace and within an optional tag: `FuelingAPI(.tagName).operationId`. If an operation doesn't have an operationId one will be generated from the path and method.

Each operation has a nested `Request` and a `Response`, as well as a static `service` property

#### Service

This is the struct that contains the static information about an operation including it's id, tag, method, pre-modified path, and authorization requirements. It has a generic `ResponseType` type which maps to the `Response` type.
You shouldn't really need to interact with this service type.

#### Request

Each request is a subclass of `FuelingAPIRequest` and has an `init` with a body param if it has a body, and a `options` struct for other url and path parameters. There is also a convenience init for passing parameters directly.
The `options` and `body` structs are both mutable so they can be modified before actually sending the request.

#### Response

The response is an enum of all the possible responses the request can return. it also contains getters for the `statusCode`, whether it was `successful`, and the actual decoded optional `success` response. If the operation only has one type of failure type there is also an optional `failure` type.

## Model
Models that are sent and returned from the API are mutable classes. Each model is `Equatable` and `Codable`.

`Required` properties are non optional and non-required are optional

All properties can be passed into the initializer, with `required` properties being mandatory.

If a model has `additionalProperties` it will have a subscript to access these by string

## FuelingAPIClient
The `FuelingAPIClient` is used to encode, authorize, send, monitor, and decode the requests. There is a `FuelingAPIClient.default` that uses the default `baseURL` otherwise a custom one can be initialized:

```swift
public init(baseURL: String, sessionManager: SessionManager = .default, defaultHeaders: [String: String] = [:], behaviours: [FuelingAPIRequestBehaviour] = [])
```

#### FuelingAPIClient properties

- `baseURL`: The base url that every request `path` will be appended to
- `behaviours`: A list of [Request Behaviours](#requestbehaviour) to add to every request
- `session`: An `URLSession` that can be customized
- `defaultHeaders`: Headers that will be applied to every request
- `decodingQueue`: The `DispatchQueue` to decode responses on

#### Making a request
To make a request first initialize a [Request](#request) and then pass it to `makeRequest`. The `complete` closure will be called with an `FuelingAPIResponse`

```swift
func makeRequest<T>(_ request: FuelingAPIRequest<T>, behaviours: [FuelingAPIRequestBehaviour] = [], queue: DispatchQueue = DispatchQueue.main, complete: @escaping (FuelingAPIResponse<T>) -> Void) -> Request? {
```

Example request (that is not neccessarily in this api):

```swift

let getUserRequest = FuelingAPI.User.GetUser.Request(id: 123)
let apiClient = FuelingAPIClient.default

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

Each [Request](#request) also has a `makeRequest` convenience function that uses `FuelingAPI.shared`.

#### FuelingAPIResponse
The `FuelingAPIResponse` that gets passed to the completion closure contains the following properties:

- `request`: The original request
- `result`: A `Result` type either containing an `APIClientError` or the [Response](#response) of the request
- `urlRequest`: The `URLRequest` used to send the request
- `urlResponse`: The `HTTPURLResponse` that was returned by the request
- `data`: The `Data` returned by the request.

#### Encoding and Decoding
Only JSON requests and responses are supported. These are encoded and decoded by `JSONEncoder` and `JSONDecoder` respectively, using Swift's `Codable` apis.
There are some options to control how invalid JSON is handled when decoding and these are available as static properties on `FuelingAPI`:

Dates are encoded and decoded differently according to the swagger date format. They use different `DateFormatter`'s that you can set.
- `date-time`
    - `DateTime.dateEncodingFormatter`: defaults to `yyyy-MM-dd'T'HH:mm:ss.Z`
    - `DateTime.dateDecodingFormatters`: an array of date formatters. The first one to decode successfully will be used
- `date`
    - `DateDay.dateFormatter`: defaults to `yyyy-MM-dd`

#### APIClientError
This is error enum that `FuelingAPIResponse.result` may contain:

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

#### FuelingAPIRequestBehaviour
Request behaviours are used to modify, authorize, monitor or respond to requests. They can be added to the `FuelingAPIClient.behaviours` for all requests, or they can passed into `makeRequest` for just that single request.

`FuelingAPIRequestBehaviour` is a protocol you can conform to with each function being optional. As the behaviours must work across multiple different request types, they only have access to a typed erased `AnyFuelingAPIRequest`.

```swift
public protocol FuelingAPIRequestBehaviour {

    /// runs first and allows the requests to be modified. If modifying asynchronously use validate
    func modifyRequest(request: AnyFuelingAPIRequest, urlRequest: URLRequest) -> URLRequest

    /// validates and modifies the request. complete must be called with either .success or .fail
    func validate(request: AnyFuelingAPIRequest, urlRequest: URLRequest, complete: @escaping (RequestValidationResult) -> Void)

    /// called before request is sent
    func beforeSend(request: AnyFuelingAPIRequest)

    /// called when request successfuly returns a 200 range response
    func onSuccess(request: AnyFuelingAPIRequest, result: Any)

    /// called when request fails with an error. This will not be called if the request returns a known response even if the a status code is out of the 200 range
    func onFailure(request: AnyFuelingAPIRequest, error: APIClientError)

    /// called if the request recieves a network response. This is not called if request fails validation or encoding
    func onResponse(request: AnyFuelingAPIRequest, response: AnyFuelingAPIResponse)
}
```

### Authorization
Each request has an optional `securityRequirement`. You can create a `FuelingAPIRequestBehaviour` that checks this requirement and adds some form of authorization (usually via headers) in `validate` or `modifyRequest`. An alternative way is to set the `FuelingAPIClient.defaultHeaders` which applies to all requests.

#### Reactive and Promises
To add support for a specific asynchronous library, just add an extension on `FuelingAPIClient` and add a function that wraps the `makeRequest` function and converts from a closure based syntax to returning the object of choice (stream, future...ect)

## Models

- **PCFuelingApproachingResponse**
- **PCFuelingCommonOpeningHours**
- **PCFuelingDiscount**
- **PCFuelingDiscountInquiryRequest**
- **PCFuelingDiscounts**
- **PCFuelingErrors**
- **PCFuelingFuelPrice**
- **PCFuelingFuelPriceResponse**
- **PCFuelingGasStation**
- **PCFuelingGasStationNote**
- **PCFuelingGetPumpsResponse**
- **PCFuelingPaymentMethod**
- **PCFuelingPaymentMethodKind**
- **PCFuelingProcessPaymentResponse**
- **PCFuelingProduct**
- **PCFuelingPump**
- **PCFuelingPumpResponse**
- **PCFuelingTransaction**
- **PCFuelingTransactionMetadata**
- **PCFuelingTransactionRequest**

## Requests

- **FuelingAPI.Discount**
	- **InquireDiscountsForPump**: POST `/gas-stations/{gasstationid}/pumps/{pumpid}/discounts`
- **FuelingAPI.Fueling**
	- **ApproachingAtTheForecourt**: POST `/gas-stations/{gasstationid}/approaching`
	- **CancelPreAuth**: DELETE `/gas-stations/{gasstationid}/transactions/{transactionid}`
	- **GetPump**: GET `/gas-stations/{gasstationid}/pumps/{pumpid}`
	- **GetPumps**: GET `/gas-stations/{gasstationid}/pumps`
	- **ProcessPayment**: POST `/gas-stations/{gasstationid}/transactions`
	- **WaitOnPumpStatusChange**: GET `/gas-stations/{gasstationid}/pumps/{pumpid}/wait-for-status-change`
- **FuelingAPI.Notification**
	- **CreateNotification**: POST `/notifications`
