//
//  URLBuilderTests.swift
//  AppKitTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class URLBuilderTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        PACECloudSDK.shared.setup(with: .init(clientId: "clientId",
                                              apiKey: "apiKey",
                                              authenticationMode: .web,
                                              accessToken: nil,
                                              environment: .development))
        PACECloudSDK.shared.initialAccessToken = nil
    }

    func testBuildManifestUrl() {
        let rootUrl = URLBuilder.buildAppManifestUrl(with: "https://pace.com")!
        XCTAssertEqual(rootUrl, "https://pace.com/manifest.json")

        let urlWithPath = URLBuilder.buildAppManifestUrl(with: "https://pace.com/path/foo/bar")!
        XCTAssertEqual(urlWithPath, "https://pace.com/manifest.json")

        let urlWithParams = URLBuilder.buildAppManifestUrl(with: "https://pace.com?foo=bar&bar=foo")!
        XCTAssertEqual(urlWithParams, "https://pace.com/manifest.json")

        let urlWithPort = URLBuilder.buildAppManifestUrl(with: "https://pace.com:8888")!
        XCTAssertEqual(urlWithPort, "https://pace.com:8888/manifest.json")

        let urlWithPortAndPath = URLBuilder.buildAppManifestUrl(with: "https://pace.com:8888/path/foo/bar")!
        XCTAssertEqual(urlWithPortAndPath, "https://pace.com:8888/manifest.json")

        let urlWithPortAndPathAndParams = URLBuilder.buildAppManifestUrl(with: "https://pace.com:8888/path/foo/bar?foo=bar&bar=foo")!
        XCTAssertEqual(urlWithPortAndPathAndParams, "https://pace.com:8888/manifest.json")
    }

    func testBuildAppStartUrl() {
        guard let result = URLBuilder.buildAppStartUrl(with: "https://pace.com", decomposedParams: [.references], references: "prn:poi:gas-stations:f582e5b4-5424-453f-9d7d-8c106b8360d3") else { XCTFail(); return }
        XCTAssertEqual(result, "https://pace.com?r=prn:poi:gas-stations:f582e5b4-5424-453f-9d7d-8c106b8360d3")
    }

    func testBuildAppPaymentRedirectUrlError() {
        let query = "amount=123&redirect_uri=https://pace.com&state=1234"
        guard var paymentConfirmationData = PaymentConfirmationData(from: query) else { XCTFail(); return }
        paymentConfirmationData.statusCode = PaymentConfirmationData.StatusCode.canceled.rawValue
        guard let result = URLBuilder.buildAppPaymentRedirectUrl(for: paymentConfirmationData) else { XCTFail(); return }
        XCTAssertEqual(result, "https://pace.com?state=1234&status_code=499")
    }

    func testBuildAppPaymentRedirectUrlSuccess() {
        let query = "amount=123&redirect_uri=https://pace.com&state=1234"
        guard var paymentConfirmationData = PaymentConfirmationData(from: query) else { XCTFail(); return }
        paymentConfirmationData.statusCode = PaymentConfirmationData.StatusCode.success.rawValue
        guard let result = URLBuilder.buildAppPaymentRedirectUrl(for: paymentConfirmationData) else { XCTFail(); return }
        XCTAssertEqual(result, "https://pace.com?state=1234&status_code=200")
    }

    func testBuildImageUrl() {
        guard let result = URLBuilder.buildAppIconUrl(baseUrl: "base", iconSrc: "image") else { XCTFail(); return }
        XCTAssertEqual(result, "base/image")
    }

    func testBuildReopenUrl() {
        let query = "state=123&reopen_url=https://pace.com&reopen_title=Hello&reopen_subtitle=world"
        let reopenData = ReopenData(from: query)
        guard let result = URLBuilder.buildAppReopenUrl(for: reopenData) else { XCTFail(); return }
        XCTAssertEqual(result, "https://pace.com?state=123")
        XCTAssertEqual(reopenData.reopenTitle, "Hello")
        XCTAssertEqual(reopenData.reopenSubtitle, "world")
        XCTAssertEqual(reopenData.reopenUrl, "https://pace.com")
    }

    func testPaymentConfirmationData() {
        let url = URL(string: "pacepwasdk://action/payment-confirm?amount=83.62&currency=EUR&payment_method_name=ING-DiBa%20XX%209427&payment_method_kind=sepa&purpose_text=Diesel&recipient=PACE%20Company&redirect_uri=https%3A%2F%2Fpace.car%2Frequest-payment-token%2Fcallback&state=4ae876f2-1df2-4d55-b45e-fca7765c8cb3")!
        let query = url.query!

        guard let paymentConfirmationData = PaymentConfirmationData(from: query) else { XCTFail(); return }

        XCTAssertEqual(paymentConfirmationData.price, 83.62)
        XCTAssertEqual(paymentConfirmationData.currency, "EUR")
        XCTAssertEqual(paymentConfirmationData.account, "ING-DiBa XX 9427")
        XCTAssertEqual(paymentConfirmationData.paymentMethodKind, "sepa")
        XCTAssertEqual(paymentConfirmationData.redirectUri, "https://pace.car/request-payment-token/callback")
        XCTAssertEqual(paymentConfirmationData.recipient, "PACE Company")
        XCTAssertEqual(paymentConfirmationData.purpose, "Diesel")
    }

    // - MARK: 2FA
    func testBiometricStatusUrl() {
        let query = "redirect_uri=https%3A%2F%2Fpace.cloud%2Ffoo%2Fcallback&state=1337"
        guard var biometricStatusData = BiometryAvailabilityData(from: query, host: "") else { XCTFail(); return }

        biometricStatusData.statusCode = BiometryAvailabilityData.StatusCode.init(available: true).rawValue

        guard let result = URLBuilder.buildBiometricStatusResponse(for: biometricStatusData) else { XCTFail(); return }

        XCTAssertEqual(result, "https://pace.cloud/foo/callback?state=1337&status_code=200")
    }

    func testTOTPSecretData() {
        let query = "secret=10101&period=30&digits=6&algorithm=sha1&key=foobar&redirect_uri=https%3A%2F%2Fpace.cloud%2Ffoo%2Fcallback&state=1337"
        guard let data = TOTPSecretData(from: query) else { XCTFail(); return }

        XCTAssertEqual(data.secret, "10101")
        XCTAssertEqual(data.period, 30)
        XCTAssertEqual(data.digits, 6)
        XCTAssertEqual(data.algorithm, "sha1")
        XCTAssertEqual(data.key, "foobar")
    }

    func testSetTOTPResponse() {
        let query = "secret=10101&period=30&digits=6&algorithm=sha1&redirect_uri=https%3A%2F%2Fpace.cloud%2Ffoo%2Fcallback&state=1337"
        guard var data = SetTOTPResponse(from: query, host: "") else { XCTFail(); return }

        data.statusCode = SetTOTPResponse.StatusCode.init(success: false).rawValue
        guard let failureResult = URLBuilder.buildSetTOTPResponse(for: data) else { XCTFail(); return }
        XCTAssertEqual(failureResult, "https://pace.cloud/foo/callback?state=1337&status_code=500")

        data.statusCode = SetTOTPResponse.StatusCode.init(success: true).rawValue
        guard let successResult = URLBuilder.buildSetTOTPResponse(for: data) else { XCTFail(); return }
        XCTAssertEqual(successResult, "https://pace.cloud/foo/callback?state=1337&status_code=200")
    }

    func testGetTOTP() {
        let query = "server_time=1591780142&key=foobar&redirect_uri=https%3A%2F%2Fpace.cloud%2Ffoo%2Fcallback&state=1337"
        guard let data = GetTOTPData(from: query, host: "") else { XCTFail(); return }

        XCTAssertEqual(data.serverTime, 1591780142)
        XCTAssertEqual(data.key, "foobar")
        XCTAssertEqual(data.redirectUri, "https://pace.cloud/foo/callback")
        XCTAssertEqual(data.state, "1337")
        XCTAssertEqual(data.statusCode, nil)
        XCTAssertEqual(data.totp, nil)
    }

    func testGetTOTPResponse() {
        let query = "server_time=1591780142&key=foobar&redirect_uri=https%3A%2F%2Fpace.cloud%2Ffoo%2Fcallback&state=1337"
        guard var data = GetTOTPData(from: query, host: "") else { XCTFail(); return }

        data.statusCode = GetTOTPData.StatusCode.notFound.rawValue
        guard let failureResult1 = URLBuilder.buildGetTOTPResponse(for: data) else { XCTFail(); return }
        XCTAssertEqual(failureResult1, "https://pace.cloud/foo/callback?state=1337&status_code=404")

        data.statusCode = GetTOTPData.StatusCode.notAllowed.rawValue
        guard let failureResult2 = URLBuilder.buildGetTOTPResponse(for: data) else { XCTFail(); return }
        XCTAssertEqual(failureResult2, "https://pace.cloud/foo/callback?state=1337&status_code=405")

        data.statusCode = GetTOTPData.StatusCode.internalError.rawValue
        guard let failureResult3 = URLBuilder.buildGetTOTPResponse(for: data) else { XCTFail(); return }
        XCTAssertEqual(failureResult3, "https://pace.cloud/foo/callback?state=1337&status_code=500")

        data.statusCode = nil
        data.totp = "foo"
        data.biometryMethod = .face
        guard let successResult = URLBuilder.buildGetTOTPResponse(for: data) else { XCTFail(); return }
        XCTAssertEqual(successResult, "https://pace.cloud/foo/callback?state=1337&totp=foo&biometry_method=face")
    }

    func testSetSecureData() {
        let query = "key=foo&value=bar&redirect_uri=https%3A%2F%2Fpace.cloud%2Ffoo%2Fcallback&state=1337"
        guard let data = SetSecureData(from: query, host: "") else { XCTFail(); return }

        XCTAssertEqual(data.key, "foo")
        XCTAssertEqual(data.value, "bar")
    }

    func testSetSecureDataResponseData() {
        let query = "key=foo&value=bar&redirect_uri=https%3A%2F%2Fpace.cloud%2Ffoo%2Fcallback&state=1337"
        guard let data = SetSecureDataResponse(from: query, host: "") else { XCTFail(); return }

        XCTAssertEqual(data.redirectUri, "https://pace.cloud/foo/callback")
        XCTAssertEqual(data.state, "1337")
    }

    func testSetSecureDataResponse() {
        let query = "key=foo&value=bar&redirect_uri=https%3A%2F%2Fpace.cloud%2Ffoo%2Fcallback&state=1337"
        guard var data = SetSecureDataResponse(from: query, host: "") else { XCTFail(); return }

        data.statusCode = SetSecureDataResponse.StatusCode.success.rawValue
        guard let successResult = URLBuilder.buildSetSecureDataResponse(for: data) else { XCTFail(); return }
        XCTAssertEqual(successResult, "https://pace.cloud/foo/callback?state=1337&status_code=200")

        data.statusCode = SetSecureDataResponse.StatusCode.failure.rawValue
        guard let failureResult = URLBuilder.buildSetSecureDataResponse(for: data) else { XCTFail(); return }
        XCTAssertEqual(failureResult, "https://pace.cloud/foo/callback?state=1337&status_code=500")
    }
}
