# PayAPI

This is an api generated from a OpenAPI 3.0 spec with [SwagGen](https://github.com/pace/SwagGen)

## Operation

Each operation lives under the `PayAPI` namespace and within an optional tag: `PayAPI(.tagName).operationId`. If an operation doesn't have an operationId one will be generated from the path and method.

Each operation has a nested `Request` and a `Response`, as well as a static `service` property

#### Service

This is the struct that contains the static information about an operation including it's id, tag, method, pre-modified path, and authorization requirements. It has a generic `ResponseType` type which maps to the `Response` type.
You shouldn't really need to interact with this service type.

#### Request

Each request is a subclass of `PayAPIRequest` and has an `init` with a body param if it has a body, and a `options` struct for other url and path parameters. There is also a convenience init for passing parameters directly.
The `options` and `body` structs are both mutable so they can be modified before actually sending the request.

#### Response

The response is an enum of all the possible responses the request can return. it also contains getters for the `statusCode`, whether it was `successful`, and the actual decoded optional `success` response. If the operation only has one type of failure type there is also an optional `failure` type.

## Model
Models that are sent and returned from the API are mutable classes. Each model is `Equatable` and `Codable`.

`Required` properties are non optional and non-required are optional

All properties can be passed into the initializer, with `required` properties being mandatory.

If a model has `additionalProperties` it will have a subscript to access these by string

## PayAPIClient
The `PayAPIClient` is used to encode, authorize, send, monitor, and decode the requests. There is a `PayAPIClient.default` that uses the default `baseURL` otherwise a custom one can be initialized:

```swift
public init(baseURL: String, sessionManager: SessionManager = .default, defaultHeaders: [String: String] = [:], behaviours: [PayAPIRequestBehaviour] = [])
```

#### PayAPIClient properties

- `baseURL`: The base url that every request `path` will be appended to
- `behaviours`: A list of [Request Behaviours](#requestbehaviour) to add to every request
- `session`: An `URLSession` that can be customized
- `defaultHeaders`: Headers that will be applied to every request
- `decodingQueue`: The `DispatchQueue` to decode responses on

#### Making a request
To make a request first initialize a [Request](#request) and then pass it to `makeRequest`. The `complete` closure will be called with an `PayAPIResponse`

```swift
func makeRequest<T>(_ request: PayAPIRequest<T>, behaviours: [PayAPIRequestBehaviour] = [], queue: DispatchQueue = DispatchQueue.main, complete: @escaping (PayAPIResponse<T>) -> Void) -> Request? {
```

Example request (that is not neccessarily in this api):

```swift

let getUserRequest = PayAPI.User.GetUser.Request(id: 123)
let apiClient = PayAPIClient.default

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

Each [Request](#request) also has a `makeRequest` convenience function that uses `PayAPI.shared`.

#### PayAPIResponse
The `PayAPIResponse` that gets passed to the completion closure contains the following properties:

- `request`: The original request
- `result`: A `Result` type either containing an `APIClientError` or the [Response](#response) of the request
- `urlRequest`: The `URLRequest` used to send the request
- `urlResponse`: The `HTTPURLResponse` that was returned by the request
- `data`: The `Data` returned by the request.

#### Encoding and Decoding
Only JSON requests and responses are supported. These are encoded and decoded by `JSONEncoder` and `JSONDecoder` respectively, using Swift's `Codable` apis.
There are some options to control how invalid JSON is handled when decoding and these are available as static properties on `PayAPI`:

Dates are encoded and decoded differently according to the swagger date format. They use different `DateFormatter`'s that you can set.
- `date-time`
    - `DateTime.dateEncodingFormatter`: defaults to `yyyy-MM-dd'T'HH:mm:ss.Z`
    - `DateTime.dateDecodingFormatters`: an array of date formatters. The first one to decode successfully will be used
- `date`
    - `DateDay.dateFormatter`: defaults to `yyyy-MM-dd`

#### APIClientError
This is error enum that `PayAPIResponse.result` may contain:

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

#### PayAPIRequestBehaviour
Request behaviours are used to modify, authorize, monitor or respond to requests. They can be added to the `PayAPIClient.behaviours` for all requests, or they can passed into `makeRequest` for just that single request.

`PayAPIRequestBehaviour` is a protocol you can conform to with each function being optional. As the behaviours must work across multiple different request types, they only have access to a typed erased `AnyPayAPIRequest`.

```swift
public protocol PayAPIRequestBehaviour {

    /// runs first and allows the requests to be modified. If modifying asynchronously use validate
    func modifyRequest(request: AnyPayAPIRequest, urlRequest: URLRequest) -> URLRequest

    /// validates and modifies the request. complete must be called with either .success or .fail
    func validate(request: AnyPayAPIRequest, urlRequest: URLRequest, complete: @escaping (RequestValidationResult) -> Void)

    /// called before request is sent
    func beforeSend(request: AnyPayAPIRequest)

    /// called when request successfuly returns a 200 range response
    func onSuccess(request: AnyPayAPIRequest, result: Any)

    /// called when request fails with an error. This will not be called if the request returns a known response even if the a status code is out of the 200 range
    func onFailure(request: AnyPayAPIRequest, error: APIClientError)

    /// called if the request recieves a network response. This is not called if request fails validation or encoding
    func onResponse(request: AnyPayAPIRequest, response: AnyPayAPIResponse)
}
```

### Authorization
Each request has an optional `securityRequirement`. You can create a `PayAPIRequestBehaviour` that checks this requirement and adds some form of authorization (usually via headers) in `validate` or `modifyRequest`. An alternative way is to set the `PayAPIClient.defaultHeaders` which applies to all requests.

#### Reactive and Promises
To add support for a specific asynchronous library, just add an extension on `PayAPIClient` and add a function that wraps the `makeRequest` function and converts from a closure based syntax to returning the object of choice (stream, future...ect)

## Models

- **PCPayApplePaySession**
- **PCPayCurrency**
- **PCPayDiscount**
- **PCPayDiscountRelationship**
- **PCPayDiscounts**
- **PCPayErrors**
- **PCPayFleetPaymentMethod**
- **PCPayFleetPaymentMethodOMVCreateRequest**
- **PCPayFuel**
- **PCPayPRN**
- **PCPayPagingMeta**
- **PCPayPaymentMethodRequest**
- **PCPayPaymentMethod**
- **PCPayPaymentMethodCreditCardCreateRequest**
- **PCPayPaymentMethodDKVCreateRequest**
- **PCPayPaymentMethodEssoCreateRequest**
- **PCPayPaymentMethodGiropayCreateRequest**
- **PCPayPaymentMethodHoyerCreateRequest**
- **PCPayPaymentMethodKind**
- **PCPayPaymentMethodKindMinimal**
- **PCPayPaymentMethodKindRelationship**
- **PCPayPaymentMethodKinds**
- **PCPayPaymentMethodLogpayCreateRequest**
- **PCPayPaymentMethodLogpaysandboxCreateRequest**
- **PCPayPaymentMethodModel**
- **PCPayPaymentMethodOMVCreateRequest**
- **PCPayPaymentMethodPayDirektCreateRequest**
- **PCPayPaymentMethodPayPalCreateRequest**
- **PCPayPaymentMethodRelationship**
- **PCPayPaymentMethodRoadrunnerCreateRequest**
- **PCPayPaymentMethodSepaCreateRequest**
- **PCPayPaymentMethodTFCCreateRequest**
- **PCPayPaymentMethodTFCSandboxCreateRequest**
- **PCPayPaymentMethodVendor**
- **PCPayPaymentMethodVendorRelationship**
- **PCPayPaymentMethodZGMCreateRequest**
- **PCPayPaymentMethods**
- **PCPayPaymentToken**
- **PCPayPaymentTokenCreateRequest**
- **PCPayPaymentTokenCreateApplePayRequest**
- **PCPayPaymentTokenCreateGooglePayRequest**
- **PCPayPaymentTokens**
- **PCPayPaymentTokensRelationship**
- **PCPayReadOnlyLocation**
- **PCPayRequestApplePaySessionRequest**
- **PCPayRequestPaymentMethodModelRequest**
- **PCPayTransaction**
- **PCPayTransactionCreateRequest**
- **PCPayTransactionIDListRequest**
- **PCPayTransactionLinks**
- **PCPayTransactionMetadata**
- **PCPayTransactions**

## Requests

- **PayAPI.FleetPaymentMethods**
	- **CreateFleetPaymentMethodOMV**: POST `/fleet/payment-methods/omv`
	- **DeleteFleetPaymentMethod**: DELETE `/fleet/payment-methods/{paymentmethodid}`
	- **GetFleetPaymentMethod**: GET `/fleet/payment-methods/{paymentmethodid}`
- **PayAPI.NewPaymentMethods**
	- **CreatePaymentMethodCreditCard**: POST `/payment-methods/creditcard`
	- **CreatePaymentMethodDKV**: POST `/payment-methods/dkv`
	- **CreatePaymentMethodEsso**: POST `/payment-methods/esso`
	- **CreatePaymentMethodGiropay**: POST `/payment-methods/giropay`
	- **CreatePaymentMethodHoyer**: POST `/payment-methods/hoyer`
	- **CreatePaymentMethodLogpay**: POST `/payment-methods/logpay`
	- **CreatePaymentMethodLogpaysandbox**: POST `/payment-methods/logpaysandbox`
	- **CreatePaymentMethodOMV**: POST `/payment-methods/omv`
	- **CreatePaymentMethodPACECardSandbox**: POST `/payment-methods/pacecardsandbox`
	- **CreatePaymentMethodPayDirekt**: POST `/payment-methods/paydirekt`
	- **CreatePaymentMethodPayPal**: POST `/payment-methods/paypal`
	- **CreatePaymentMethodRoadrunner**: POST `/payment-methods/roadrunner`
	- **CreatePaymentMethodSEPA**: POST `/payment-methods/sepa-direct-debit`
	- **CreatePaymentMethodTFC**: POST `/payment-methods/tfc`
	- **CreatePaymentMethodTFCSandbox**: POST `/payment-methods/tfcsandbox`
	- **CreatePaymentMethodZGM**: POST `/payment-methods/zgm`
- **PayAPI.PaymentMethodKinds**
	- **GetPaymentMethodKinds**: GET `/payment-method-kinds`
	- **GetPaymentMethodKindsByClientID**: GET `/payment-method-kinds/{clientid}`
- **PayAPI.PaymentMethods**
	- **ConfirmPaymentMethod**: GET `/payment-methods/confirm/{token}`
	- **DeletePaymentMethod**: DELETE `/payment-methods/{paymentmethodid}`
	- **DeletePaymentMethods**: DELETE `/payment-methods`
	- **GetPaymentMethod**: GET `/payment-methods/{paymentmethodid}`
	- **GetPaymentMethods**: GET `/payment-methods`
	- **GetPaymentMethodsIncludingCreditCheck**: GET `/payment-methods`
	- **GetPaymentMethodsIncludingCreditCheckMultiStatus**: GET `/payment-methods`
	- **GetPaymentMethodsIncludingPaymentToken**: GET `/payment-methods`
	- **NotificationForPaymentMethod**: POST `/payment-methods/{paymentmethodid}/notification`
	- **PatchPaymentMethod**: PATCH `/payment-methods/{paymentmethodid}`
	- **PaymentMethodModel**: POST `/payment-methods/{paymentmethodid}/model`
- **PayAPI.PaymentTokens**
	- **AuthorizeApplePayPaymentToken**: POST `/payment-method-kinds/applepay/authorize`
	- **AuthorizeGooglePayPaymentToken**: POST `/payment-method-kinds/googlepay/authorize`
	- **AuthorizePaymentToken**: POST `/payment-methods/{paymentmethodid}/authorize`
	- **DeletePaymentToken**: DELETE `/payment-tokens/{paymenttokenid}`
	- **GetPaymentToken**: GET `/payment-tokens/{paymenttokenid}`
	- **GetPaymentTokens**: GET `/payment-tokens`
	- **RequestApplePaySession**: POST `/payment-method-kinds/applepay/session`
- **PayAPI.PaymentTransactions**
	- **CancelPreAuthPayment**: POST `/transactions/{transactionid}/cancel`
	- **GetReceipt**: GET `/receipts/{transactionid}`
	- **GetReceiptByFormat**: GET `/receipts/{transactionid}.{fileformat}`
	- **GetTransaction**: GET `/transactions/{transactionid}`
	- **ListTransactions**: GET `/transactions`
	- **ListTransactionsCSV**: GET `/transactions.csv`
	- **ListTransactionsForContractID**: GET `/transactions/contracts/{contractid}`
	- **ProcessPayment**: POST `/transactions`
	- **ResendReceipt**: POST `/receipts/resend`
