//
//  TokenRevocationTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

final class TokenRevocationTests: XCTestCase {

    // MARK: - setUp

    override func setUp() {
        super.setUp()

        PACECloudSDK.shared.setup(with: .init(
            apiKey: "apiKey",
            clientId: "unit-test-dummy",
            environment: .development,
            isRedirectSchemeCheckEnabled: false
        ))
    }

    // MARK: - Tests

    /// Verifies that the token revocation endpoint is loaded from the environment plist.
    func testTokenRevocationEndpointIsConfigured() {
        XCTAssertEqual(
            Settings.shared.tokenRevocationEndpointUrl,
            "https://id.dev.pace.cloud/auth/realms/pace/protocol/openid-connect/revoke"
        )
    }

    /// Verifies that the OIDConfiguration default factory includes the token revocation endpoint.
    func testOIDConfigurationIncludesTokenRevocationEndpoint() {
        guard let idKit = IDKit.shared else {
            XCTFail("IDKit.shared must be available after SDK setup")
            return
        }

        XCTAssertEqual(
            idKit.configuration.tokenRevocationEndpoint,
            "https://id.dev.pace.cloud/auth/realms/pace/protocol/openid-connect/revoke"
        )
    }

    /// Verifies that a custom OIDConfiguration can omit the revocation endpoint (nil by default).
    func testCustomOIDConfigurationDefaultsToNilRevocationEndpoint() {
        let config = IDKit.OIDConfiguration(
            authorizationEndpoint: "https://example.com/auth",
            tokenEndpoint: "https://example.com/token",
            clientId: "test",
            redirectUri: "test://callback"
        )

        XCTAssertNil(config.tokenRevocationEndpoint)
    }
}
