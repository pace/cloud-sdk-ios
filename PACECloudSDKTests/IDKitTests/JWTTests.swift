//
//  JWTTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class JWTTests: XCTestCase {
    private let validToken = """
    eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImp0aSI6ImI2NDk1YWUyLWE1YjAtNGQyYi04N2Y5LThhMDgzNWIwN2JmMyIsImlhdCI6MTYwNTEwMjMwOSwiZXhwIjoxNjA1MTA1OTA5fQ.BXnkfB5aLcclqKGHpjsQxMYEs5DBN20BQ6FblMkZIIs
    """

    private let invalidToken = """
    eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImp0aSI6ImI2NDk1YWUyLWE1YjAtNGQyYi04N2Y5LThhMDgzNWIwN2JmMyIsImlhdCI6MTYwNTEwMjMwOSwiZXhwIjoxNjA1MTA1OTA5fQ.BXnkfB5aLcclqKGHpjsQxMYEs5DBN20BQ6FblMkZIIs
    """

    func testValidJWTToken() {
        do {
            let _ = try JWTToken(jwt: validToken)
        } catch {
            XCTFail()
        }
    }

    func testInvalidJWTToken() {
        do {
            let _ = try JWTToken(jwt: invalidToken)
            XCTFail()
        } catch {}
    }

    func testRetrieveExpiresAt() {
        do {
            let token = try JWTToken(jwt: validToken)
            let date = token.expiresAt
            XCTAssertNotNil(date)
            XCTAssertEqual(date, Date(timeIntervalSince1970: 1605105909))
        } catch {
            XCTFail()
        }
    }
}

extension JWTTests {
    func testPaymentMethodKindsNoScopes() {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDMyMTU3NjQsImlhdCI6MTY0MzIxNTcwNCwiYXV0aF90aW1lIjoxNjQzMjA2MzgyLCJqdGkiOiIwMTg0YTM4Yy02YzdkLTRiMDEtYjhiYi1mY2ZlYjAyM2M5NjYiLCJpc3MiOiJodHRwczovL2lkLmRldi5wYWNlLmNsb3VkL2F1dGgvcmVhbG1zL3BhY2UiLCJzdWIiOiI3M2VlYWUyZC1mMTE4LTRkZjMtOTFkZS1jZDAwZDM4OGQwNDkiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJjbG91ZC1zZGstZXhhbXBsZS1hcHAiLCJub25jZSI6Ii1Rc3g4UHZxUHV6eFpTeDh3bkJKNHciLCJzZXNzaW9uX3N0YXRlIjoiY2IyMDM1ZjQtMGM3Ni00OTVjLTljYjAtYmE2MmExNTU1ZWMxIiwiYWNyIjoiMCIsInNjb3BlIjoib3BlbmlkIHBvaTphcHBzOnJlYWQgZnVlbGluZzp0cmFuc2FjdGlvbnM6Y3JlYXRlIHVzZXI6cHJlZmVyZW5jZXM6cmVhZDpwYXltZW50LWFwcCBmdWVsaW5nOmRpc2NvdW50czppbnF1aXJ5IHBheTpwYXltZW50LW1ldGhvZHM6cGF0Y2ggdXNlcjpkZXZpY2UtdG90cHM6Y3JlYXRlIHVzZXI6dXNlcnMucGluOmNoZWNrIHBheTp0cmFuc2FjdGlvbnM6cmVhZCBmdWVsaW5nOmdhcy1zdGF0aW9uczphcHByb2FjaGluZyBwYXk6cGF5bWVudC10b2tlbnM6ZGVsZXRlIHBvaTpnYXMtc3RhdGlvbnM6cmVhZCB1c2VyOnByZWZlcmVuY2VzOnJlYWQgZnVlbGluZzpwdW1wczpyZWFkIHVzZXI6b3RwOnZlcmlmeSB1c2VyOm90cDpjcmVhdGUgdXNlcjpwcmVmZXJlbmNlczp3cml0ZSBwYXk6cGF5bWVudC10b2tlbnM6Y3JlYXRlIHBheTp0cmFuc2FjdGlvbnM6cmVjZWlwdCB1c2VyOnVzZXJzLnBpbjp1cGRhdGUgdXNlcmNyZWRpdDp1c2VyLmNyZWRpdDpyZWFkIHVzZXI6ZGV2aWNlLXRvdHBzOmNyZWF0ZS1hZnRlci1sb2dpbiB1c2VyOnVzZXJzLnBhc3N3b3JkOmNoZWNrIHVzZXI6dXNlci5lbWFpbDpyZWFkIHBheTpwYXltZW50LW1ldGhvZHM6ZGVsZXRlIHBheTpwYXltZW50LW1ldGhvZHM6cmVhZCBmdWVsaW5nOnRyYW5zYWN0aW9uczpkZWxldGUgdXNlcjp0ZXJtczphY2NlcHQgdXNlcjp1c2VyLmxvY2FsZTpyZWFkIiwic2lkIjoiY2IyMDM1ZjQtMGM3Ni00OTVjLTljYjAtYmE2MmExNTU1ZWMxIiwiem9uZWluZm8iOiJFdXJvcGUvQmVybGluIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImxvY2FsZSI6ImVuIiwiZW1haWwiOiJob3JzdEBwYWNlLmNhciJ9.mL3eIHDyNLvpTR7tIrnE8NwsLmg61ld5KO4_adl_Q8M"

        let paymentMethodKinds = IDKit.TokenValidator.paymentMethodKinds(for: token)
        XCTAssertNil(paymentMethodKinds)
    }

    // pay:payment-methods:create:dkv
    func testPaymentMethodKindSingleIndividualScope() {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDMyMTU3NjQsImlhdCI6MTY0MzIxNTcwNCwiYXV0aF90aW1lIjoxNjQzMjA2MzgyLCJqdGkiOiIwMTg0YTM4Yy02YzdkLTRiMDEtYjhiYi1mY2ZlYjAyM2M5NjYiLCJpc3MiOiJodHRwczovL2lkLmRldi5wYWNlLmNsb3VkL2F1dGgvcmVhbG1zL3BhY2UiLCJzdWIiOiI3M2VlYWUyZC1mMTE4LTRkZjMtOTFkZS1jZDAwZDM4OGQwNDkiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJjbG91ZC1zZGstZXhhbXBsZS1hcHAiLCJub25jZSI6Ii1Rc3g4UHZxUHV6eFpTeDh3bkJKNHciLCJzZXNzaW9uX3N0YXRlIjoiY2IyMDM1ZjQtMGM3Ni00OTVjLTljYjAtYmE2MmExNTU1ZWMxIiwiYWNyIjoiMCIsInNjb3BlIjoib3BlbmlkIHBvaTphcHBzOnJlYWQgZnVlbGluZzp0cmFuc2FjdGlvbnM6Y3JlYXRlIHBheTphcHBsZXBheS1zZXNzaW9uczpjcmVhdGUgcGF5OnBheW1lbnQtbWV0aG9kczpjcmVhdGU6ZGt2IHVzZXI6cHJlZmVyZW5jZXM6cmVhZDpwYXltZW50LWFwcCBmdWVsaW5nOmRpc2NvdW50czppbnF1aXJ5IHBheTpwYXltZW50LW1ldGhvZHM6cGF0Y2ggdXNlcjpkZXZpY2UtdG90cHM6Y3JlYXRlIHVzZXI6dXNlcnMucGluOmNoZWNrIHBheTp0cmFuc2FjdGlvbnM6cmVhZCBmdWVsaW5nOmdhcy1zdGF0aW9uczphcHByb2FjaGluZyBwYXk6cGF5bWVudC10b2tlbnM6ZGVsZXRlIHBvaTpnYXMtc3RhdGlvbnM6cmVhZCB1c2VyOnByZWZlcmVuY2VzOnJlYWQgZnVlbGluZzpwdW1wczpyZWFkIHVzZXI6b3RwOnZlcmlmeSB1c2VyOm90cDpjcmVhdGUgdXNlcjpwcmVmZXJlbmNlczp3cml0ZSBwYXk6cGF5bWVudC10b2tlbnM6Y3JlYXRlIHBheTp0cmFuc2FjdGlvbnM6cmVjZWlwdCB1c2VyOnVzZXJzLnBpbjp1cGRhdGUgdXNlcmNyZWRpdDp1c2VyLmNyZWRpdDpyZWFkIHVzZXI6ZGV2aWNlLXRvdHBzOmNyZWF0ZS1hZnRlci1sb2dpbiB1c2VyOnVzZXJzLnBhc3N3b3JkOmNoZWNrIHVzZXI6dXNlci5lbWFpbDpyZWFkIHBheTpwYXltZW50LW1ldGhvZHM6ZGVsZXRlIHBheTpwYXltZW50LW1ldGhvZHM6cmVhZCBmdWVsaW5nOnRyYW5zYWN0aW9uczpkZWxldGUgdXNlcjp0ZXJtczphY2NlcHQgdXNlcjp1c2VyLmxvY2FsZTpyZWFkIiwic2lkIjoiY2IyMDM1ZjQtMGM3Ni00OTVjLTljYjAtYmE2MmExNTU1ZWMxIiwiem9uZWluZm8iOiJFdXJvcGUvQmVybGluIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImxvY2FsZSI6ImVuIiwiZW1haWwiOiJob3JzdEBwYWNlLmNhciJ9.IsMUpaCIdP3ASSuafN3fxF9j8aMC_FRPFG2j0OStW_c"

        let paymentMethodKinds = IDKit.TokenValidator.paymentMethodKinds(for: token)
        let result: Set<String>? = ["dkv", "applepay"]
        XCTAssertEqual(result, paymentMethodKinds)
    }

    // pay:payment-methods:create:dkv + pay:payment-methods:create:hoyer
    func testPaymentMethodKindsMultipleIndividualScopes() {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDMyMTU3NjQsImlhdCI6MTY0MzIxNTcwNCwiYXV0aF90aW1lIjoxNjQzMjA2MzgyLCJqdGkiOiIwMTg0YTM4Yy02YzdkLTRiMDEtYjhiYi1mY2ZlYjAyM2M5NjYiLCJpc3MiOiJodHRwczovL2lkLmRldi5wYWNlLmNsb3VkL2F1dGgvcmVhbG1zL3BhY2UiLCJzdWIiOiI3M2VlYWUyZC1mMTE4LTRkZjMtOTFkZS1jZDAwZDM4OGQwNDkiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJjbG91ZC1zZGstZXhhbXBsZS1hcHAiLCJub25jZSI6Ii1Rc3g4UHZxUHV6eFpTeDh3bkJKNHciLCJzZXNzaW9uX3N0YXRlIjoiY2IyMDM1ZjQtMGM3Ni00OTVjLTljYjAtYmE2MmExNTU1ZWMxIiwiYWNyIjoiMCIsInNjb3BlIjoib3BlbmlkIHBvaTphcHBzOnJlYWQgZnVlbGluZzp0cmFuc2FjdGlvbnM6Y3JlYXRlIHBheTphcHBsZXBheS1zZXNzaW9uczpjcmVhdGUgcGF5OnBheW1lbnQtbWV0aG9kczpjcmVhdGU6ZGt2IHBheTpwYXltZW50LW1ldGhvZHM6Y3JlYXRlOmhveWVyIHVzZXI6cHJlZmVyZW5jZXM6cmVhZDpwYXltZW50LWFwcCBmdWVsaW5nOmRpc2NvdW50czppbnF1aXJ5IHBheTpwYXltZW50LW1ldGhvZHM6cGF0Y2ggdXNlcjpkZXZpY2UtdG90cHM6Y3JlYXRlIHVzZXI6dXNlcnMucGluOmNoZWNrIHBheTp0cmFuc2FjdGlvbnM6cmVhZCBmdWVsaW5nOmdhcy1zdGF0aW9uczphcHByb2FjaGluZyBwYXk6cGF5bWVudC10b2tlbnM6ZGVsZXRlIHBvaTpnYXMtc3RhdGlvbnM6cmVhZCB1c2VyOnByZWZlcmVuY2VzOnJlYWQgZnVlbGluZzpwdW1wczpyZWFkIHVzZXI6b3RwOnZlcmlmeSB1c2VyOm90cDpjcmVhdGUgdXNlcjpwcmVmZXJlbmNlczp3cml0ZSBwYXk6cGF5bWVudC10b2tlbnM6Y3JlYXRlIHBheTp0cmFuc2FjdGlvbnM6cmVjZWlwdCB1c2VyOnVzZXJzLnBpbjp1cGRhdGUgdXNlcmNyZWRpdDp1c2VyLmNyZWRpdDpyZWFkIHVzZXI6ZGV2aWNlLXRvdHBzOmNyZWF0ZS1hZnRlci1sb2dpbiB1c2VyOnVzZXJzLnBhc3N3b3JkOmNoZWNrIHVzZXI6dXNlci5lbWFpbDpyZWFkIHBheTpwYXltZW50LW1ldGhvZHM6ZGVsZXRlIHBheTpwYXltZW50LW1ldGhvZHM6cmVhZCBmdWVsaW5nOnRyYW5zYWN0aW9uczpkZWxldGUgdXNlcjp0ZXJtczphY2NlcHQgdXNlcjp1c2VyLmxvY2FsZTpyZWFkIiwic2lkIjoiY2IyMDM1ZjQtMGM3Ni00OTVjLTljYjAtYmE2MmExNTU1ZWMxIiwiem9uZWluZm8iOiJFdXJvcGUvQmVybGluIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImxvY2FsZSI6ImVuIiwiZW1haWwiOiJob3JzdEBwYWNlLmNhciJ9.DjMEaIV4_QLbIruPu33-1GkKQvCFR8957dU-4H8C25M"

        let paymentMethodKinds = IDKit.TokenValidator.paymentMethodKinds(for: token)
        let result: Set<String>? = ["dkv", "hoyer", "applepay"]
        XCTAssertEqual(result, paymentMethodKinds)
    }

    // pay:payment-methods:create
    func testPaymentMethodKindsGeneralScope() {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDMyMTU3NjQsImlhdCI6MTY0MzIxNTcwNCwiYXV0aF90aW1lIjoxNjQzMjA2MzgyLCJqdGkiOiIwMTg0YTM4Yy02YzdkLTRiMDEtYjhiYi1mY2ZlYjAyM2M5NjYiLCJpc3MiOiJodHRwczovL2lkLmRldi5wYWNlLmNsb3VkL2F1dGgvcmVhbG1zL3BhY2UiLCJzdWIiOiI3M2VlYWUyZC1mMTE4LTRkZjMtOTFkZS1jZDAwZDM4OGQwNDkiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJjbG91ZC1zZGstZXhhbXBsZS1hcHAiLCJub25jZSI6Ii1Rc3g4UHZxUHV6eFpTeDh3bkJKNHciLCJzZXNzaW9uX3N0YXRlIjoiY2IyMDM1ZjQtMGM3Ni00OTVjLTljYjAtYmE2MmExNTU1ZWMxIiwiYWNyIjoiMCIsInNjb3BlIjoib3BlbmlkIHBvaTphcHBzOnJlYWQgZnVlbGluZzp0cmFuc2FjdGlvbnM6Y3JlYXRlIHBheTphcHBsZXBheS1zZXNzaW9uczpjcmVhdGUgcGF5OnBheW1lbnQtbWV0aG9kczpjcmVhdGUgdXNlcjpwcmVmZXJlbmNlczpyZWFkOnBheW1lbnQtYXBwIGZ1ZWxpbmc6ZGlzY291bnRzOmlucXVpcnkgcGF5OnBheW1lbnQtbWV0aG9kczpwYXRjaCB1c2VyOmRldmljZS10b3RwczpjcmVhdGUgdXNlcjp1c2Vycy5waW46Y2hlY2sgcGF5OnRyYW5zYWN0aW9uczpyZWFkIGZ1ZWxpbmc6Z2FzLXN0YXRpb25zOmFwcHJvYWNoaW5nIHBheTpwYXltZW50LXRva2VuczpkZWxldGUgcG9pOmdhcy1zdGF0aW9uczpyZWFkIHVzZXI6cHJlZmVyZW5jZXM6cmVhZCBmdWVsaW5nOnB1bXBzOnJlYWQgdXNlcjpvdHA6dmVyaWZ5IHVzZXI6b3RwOmNyZWF0ZSB1c2VyOnByZWZlcmVuY2VzOndyaXRlIHBheTpwYXltZW50LXRva2VuczpjcmVhdGUgcGF5OnRyYW5zYWN0aW9uczpyZWNlaXB0IHVzZXI6dXNlcnMucGluOnVwZGF0ZSB1c2VyY3JlZGl0OnVzZXIuY3JlZGl0OnJlYWQgdXNlcjpkZXZpY2UtdG90cHM6Y3JlYXRlLWFmdGVyLWxvZ2luIHVzZXI6dXNlcnMucGFzc3dvcmQ6Y2hlY2sgdXNlcjp1c2VyLmVtYWlsOnJlYWQgcGF5OnBheW1lbnQtbWV0aG9kczpkZWxldGUgcGF5OnBheW1lbnQtbWV0aG9kczpyZWFkIGZ1ZWxpbmc6dHJhbnNhY3Rpb25zOmRlbGV0ZSB1c2VyOnRlcm1zOmFjY2VwdCB1c2VyOnVzZXIubG9jYWxlOnJlYWQiLCJzaWQiOiJjYjIwMzVmNC0wYzc2LTQ5NWMtOWNiMC1iYTYyYTE1NTVlYzEiLCJ6b25laW5mbyI6IkV1cm9wZS9CZXJsaW4iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibG9jYWxlIjoiZW4iLCJlbWFpbCI6ImhvcnN0QHBhY2UuY2FyIn0.JMdJXhVauxvbkb_fpA8lNZ1HDRlqDYha6ioobimWKBQ"

        let paymentMethodKinds = IDKit.TokenValidator.paymentMethodKinds(for: token)
        let result: Set<String>? = []
        XCTAssertEqual(result, paymentMethodKinds)
    }

    // pay:payment-methods:create + pay:payment-methods:create:dkv + pay:payment-methods:create:hoyer
    func testPaymentMethodKindsGeneralAndIndividualScope() {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDMyMTU3NjQsImlhdCI6MTY0MzIxNTcwNCwiYXV0aF90aW1lIjoxNjQzMjA2MzgyLCJqdGkiOiIwMTg0YTM4Yy02YzdkLTRiMDEtYjhiYi1mY2ZlYjAyM2M5NjYiLCJpc3MiOiJodHRwczovL2lkLmRldi5wYWNlLmNsb3VkL2F1dGgvcmVhbG1zL3BhY2UiLCJzdWIiOiI3M2VlYWUyZC1mMTE4LTRkZjMtOTFkZS1jZDAwZDM4OGQwNDkiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJjbG91ZC1zZGstZXhhbXBsZS1hcHAiLCJub25jZSI6Ii1Rc3g4UHZxUHV6eFpTeDh3bkJKNHciLCJzZXNzaW9uX3N0YXRlIjoiY2IyMDM1ZjQtMGM3Ni00OTVjLTljYjAtYmE2MmExNTU1ZWMxIiwiYWNyIjoiMCIsInNjb3BlIjoib3BlbmlkIHBvaTphcHBzOnJlYWQgZnVlbGluZzp0cmFuc2FjdGlvbnM6Y3JlYXRlIHBheTphcHBsZXBheS1zZXNzaW9uczpjcmVhdGUgcGF5OnBheW1lbnQtbWV0aG9kczpjcmVhdGUgcGF5OnBheW1lbnQtbWV0aG9kczpjcmVhdGU6ZGt2IHBheTpwYXltZW50LW1ldGhvZHM6Y3JlYXRlOmhveWVyIHVzZXI6cHJlZmVyZW5jZXM6cmVhZDpwYXltZW50LWFwcCBmdWVsaW5nOmRpc2NvdW50czppbnF1aXJ5IHBheTpwYXltZW50LW1ldGhvZHM6cGF0Y2ggdXNlcjpkZXZpY2UtdG90cHM6Y3JlYXRlIHVzZXI6dXNlcnMucGluOmNoZWNrIHBheTp0cmFuc2FjdGlvbnM6cmVhZCBmdWVsaW5nOmdhcy1zdGF0aW9uczphcHByb2FjaGluZyBwYXk6cGF5bWVudC10b2tlbnM6ZGVsZXRlIHBvaTpnYXMtc3RhdGlvbnM6cmVhZCB1c2VyOnByZWZlcmVuY2VzOnJlYWQgZnVlbGluZzpwdW1wczpyZWFkIHVzZXI6b3RwOnZlcmlmeSB1c2VyOm90cDpjcmVhdGUgdXNlcjpwcmVmZXJlbmNlczp3cml0ZSBwYXk6cGF5bWVudC10b2tlbnM6Y3JlYXRlIHBheTp0cmFuc2FjdGlvbnM6cmVjZWlwdCB1c2VyOnVzZXJzLnBpbjp1cGRhdGUgdXNlcmNyZWRpdDp1c2VyLmNyZWRpdDpyZWFkIHVzZXI6ZGV2aWNlLXRvdHBzOmNyZWF0ZS1hZnRlci1sb2dpbiB1c2VyOnVzZXJzLnBhc3N3b3JkOmNoZWNrIHVzZXI6dXNlci5lbWFpbDpyZWFkIHBheTpwYXltZW50LW1ldGhvZHM6ZGVsZXRlIHBheTpwYXltZW50LW1ldGhvZHM6cmVhZCBmdWVsaW5nOnRyYW5zYWN0aW9uczpkZWxldGUgdXNlcjp0ZXJtczphY2NlcHQgdXNlcjp1c2VyLmxvY2FsZTpyZWFkIiwic2lkIjoiY2IyMDM1ZjQtMGM3Ni00OTVjLTljYjAtYmE2MmExNTU1ZWMxIiwiem9uZWluZm8iOiJFdXJvcGUvQmVybGluIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImxvY2FsZSI6ImVuIiwiZW1haWwiOiJob3JzdEBwYWNlLmNhciJ9.dI9FdvGb9uS4c9AqlL5uqK4-MI2BWPdvB_mzOnuDAu0"

        let paymentMethodKinds = IDKit.TokenValidator.paymentMethodKinds(for: token)
        let result: Set<String>? = []
        XCTAssertEqual(result, paymentMethodKinds)
    }

    // token does not contain pay:applepay-sessions:create but pay:payment-methods:create:dkv pay:payment-methods:create:hoyer
    func testPaymentMethodKindsContainsNoApplePay() {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDMyMTU3NjQsImlhdCI6MTY0MzIxNTcwNCwiYXV0aF90aW1lIjoxNjQzMjA2MzgyLCJqdGkiOiIwMTg0YTM4Yy02YzdkLTRiMDEtYjhiYi1mY2ZlYjAyM2M5NjYiLCJpc3MiOiJodHRwczovL2lkLmRldi5wYWNlLmNsb3VkL2F1dGgvcmVhbG1zL3BhY2UiLCJzdWIiOiI3M2VlYWUyZC1mMTE4LTRkZjMtOTFkZS1jZDAwZDM4OGQwNDkiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJjbG91ZC1zZGstZXhhbXBsZS1hcHAiLCJub25jZSI6Ii1Rc3g4UHZxUHV6eFpTeDh3bkJKNHciLCJzZXNzaW9uX3N0YXRlIjoiY2IyMDM1ZjQtMGM3Ni00OTVjLTljYjAtYmE2MmExNTU1ZWMxIiwiYWNyIjoiMCIsInNjb3BlIjoib3BlbmlkIHBvaTphcHBzOnJlYWQgZnVlbGluZzp0cmFuc2FjdGlvbnM6Y3JlYXRlIHBheTpwYXltZW50LW1ldGhvZHM6Y3JlYXRlOmRrdiBwYXk6cGF5bWVudC1tZXRob2RzOmNyZWF0ZTpob3llciB1c2VyOnByZWZlcmVuY2VzOnJlYWQ6cGF5bWVudC1hcHAgZnVlbGluZzpkaXNjb3VudHM6aW5xdWlyeSBwYXk6cGF5bWVudC1tZXRob2RzOnBhdGNoIHVzZXI6ZGV2aWNlLXRvdHBzOmNyZWF0ZSB1c2VyOnVzZXJzLnBpbjpjaGVjayBwYXk6dHJhbnNhY3Rpb25zOnJlYWQgZnVlbGluZzpnYXMtc3RhdGlvbnM6YXBwcm9hY2hpbmcgcGF5OnBheW1lbnQtdG9rZW5zOmRlbGV0ZSBwb2k6Z2FzLXN0YXRpb25zOnJlYWQgdXNlcjpwcmVmZXJlbmNlczpyZWFkIGZ1ZWxpbmc6cHVtcHM6cmVhZCB1c2VyOm90cDp2ZXJpZnkgdXNlcjpvdHA6Y3JlYXRlIHVzZXI6cHJlZmVyZW5jZXM6d3JpdGUgcGF5OnBheW1lbnQtdG9rZW5zOmNyZWF0ZSBwYXk6dHJhbnNhY3Rpb25zOnJlY2VpcHQgdXNlcjp1c2Vycy5waW46dXBkYXRlIHVzZXJjcmVkaXQ6dXNlci5jcmVkaXQ6cmVhZCB1c2VyOmRldmljZS10b3RwczpjcmVhdGUtYWZ0ZXItbG9naW4gdXNlcjp1c2Vycy5wYXNzd29yZDpjaGVjayB1c2VyOnVzZXIuZW1haWw6cmVhZCBwYXk6cGF5bWVudC1tZXRob2RzOmRlbGV0ZSBwYXk6cGF5bWVudC1tZXRob2RzOnJlYWQgZnVlbGluZzp0cmFuc2FjdGlvbnM6ZGVsZXRlIHVzZXI6dGVybXM6YWNjZXB0IHVzZXI6dXNlci5sb2NhbGU6cmVhZCIsInNpZCI6ImNiMjAzNWY0LTBjNzYtNDk1Yy05Y2IwLWJhNjJhMTU1NWVjMSIsInpvbmVpbmZvIjoiRXVyb3BlL0JlcmxpbiIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJsb2NhbGUiOiJlbiIsImVtYWlsIjoiaG9yc3RAcGFjZS5jYXIifQ.M4Ie0Id3u_PhPKr6qnM6Y6DDmsFVTKJOTVq83sQ-cBw"

        let paymentMethodKinds = IDKit.TokenValidator.paymentMethodKinds(for: token)
        let result: Set<String>? = ["dkv", "hoyer"]
        XCTAssertEqual(result, paymentMethodKinds)
    }

    // token only contains pay:applepay-sessions:create
    func testPaymentMethodKindsOnlyApplePay() {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDMyMTU3NjQsImlhdCI6MTY0MzIxNTcwNCwiYXV0aF90aW1lIjoxNjQzMjA2MzgyLCJqdGkiOiIwMTg0YTM4Yy02YzdkLTRiMDEtYjhiYi1mY2ZlYjAyM2M5NjYiLCJpc3MiOiJodHRwczovL2lkLmRldi5wYWNlLmNsb3VkL2F1dGgvcmVhbG1zL3BhY2UiLCJzdWIiOiI3M2VlYWUyZC1mMTE4LTRkZjMtOTFkZS1jZDAwZDM4OGQwNDkiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJjbG91ZC1zZGstZXhhbXBsZS1hcHAiLCJub25jZSI6Ii1Rc3g4UHZxUHV6eFpTeDh3bkJKNHciLCJzZXNzaW9uX3N0YXRlIjoiY2IyMDM1ZjQtMGM3Ni00OTVjLTljYjAtYmE2MmExNTU1ZWMxIiwiYWNyIjoiMCIsInNjb3BlIjoib3BlbmlkIHBvaTphcHBzOnJlYWQgZnVlbGluZzp0cmFuc2FjdGlvbnM6Y3JlYXRlIHBheTphcHBsZXBheS1zZXNzaW9uczpjcmVhdGUgdXNlcjpwcmVmZXJlbmNlczpyZWFkOnBheW1lbnQtYXBwIGZ1ZWxpbmc6ZGlzY291bnRzOmlucXVpcnkgcGF5OnBheW1lbnQtbWV0aG9kczpwYXRjaCB1c2VyOmRldmljZS10b3RwczpjcmVhdGUgdXNlcjp1c2Vycy5waW46Y2hlY2sgcGF5OnRyYW5zYWN0aW9uczpyZWFkIGZ1ZWxpbmc6Z2FzLXN0YXRpb25zOmFwcHJvYWNoaW5nIHBheTpwYXltZW50LXRva2VuczpkZWxldGUgcG9pOmdhcy1zdGF0aW9uczpyZWFkIHVzZXI6cHJlZmVyZW5jZXM6cmVhZCBmdWVsaW5nOnB1bXBzOnJlYWQgdXNlcjpvdHA6dmVyaWZ5IHVzZXI6b3RwOmNyZWF0ZSB1c2VyOnByZWZlcmVuY2VzOndyaXRlIHBheTpwYXltZW50LXRva2VuczpjcmVhdGUgcGF5OnRyYW5zYWN0aW9uczpyZWNlaXB0IHVzZXI6dXNlcnMucGluOnVwZGF0ZSB1c2VyY3JlZGl0OnVzZXIuY3JlZGl0OnJlYWQgdXNlcjpkZXZpY2UtdG90cHM6Y3JlYXRlLWFmdGVyLWxvZ2luIHVzZXI6dXNlcnMucGFzc3dvcmQ6Y2hlY2sgdXNlcjp1c2VyLmVtYWlsOnJlYWQgcGF5OnBheW1lbnQtbWV0aG9kczpkZWxldGUgcGF5OnBheW1lbnQtbWV0aG9kczpyZWFkIGZ1ZWxpbmc6dHJhbnNhY3Rpb25zOmRlbGV0ZSB1c2VyOnRlcm1zOmFjY2VwdCB1c2VyOnVzZXIubG9jYWxlOnJlYWQiLCJzaWQiOiJjYjIwMzVmNC0wYzc2LTQ5NWMtOWNiMC1iYTYyYTE1NTVlYzEiLCJ6b25laW5mbyI6IkV1cm9wZS9CZXJsaW4iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibG9jYWxlIjoiZW4iLCJlbWFpbCI6ImhvcnN0QHBhY2UuY2FyIn0.N5h_GERtqMW_DQgGZQKoy-Fcfw7k1q2PfMBeTY4PfHc"

        let paymentMethodKinds = IDKit.TokenValidator.paymentMethodKinds(for: token)
        let result: Set<String>? = ["applepay"]
        XCTAssertEqual(result, paymentMethodKinds)
    }
}
