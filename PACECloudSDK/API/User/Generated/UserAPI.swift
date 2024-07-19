//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

/** The PACE User API is responsible for user related actions.
# Handling Terms of Service
PACE services often require the acceptance of *Terms of Service* to execute API actions. The terms are required for legal reasons. Some of the API surface may not require the acceptance of terms. Usually, the terms need to be accepted before doing manipulations like `DELETE`, `PUT`, `POST` and similar. If a service requires a user to accept the terms of service a `451 Unavailable For Legal Reasons` status code will be returned together with a `Location` header that indicates the terms that need to be accepted. The URL points to the [GetTerms](#operation/GetTerms) and can then be followed by the [AcceptTerms](#operation/AcceptTerms). The terms can be viewed and accepted with a regular browser.
A simple way to assure that the *terms of service* are accepted, before the user does any action is, to call the [CheckTerms](#operation/CheckTerms) API before the application, together with a `redirectUri` to the next step of the application process.
 */
public struct UserAPI {

    /// Used to encode Dates when uses as string params
    public static var dateEncodingFormatter = DateFormatter(formatString: "yyyy-MM-dd'T'HH:mm:ss'Z'",
                                                            locale: Locale(identifier: "de_DE"),
                                                            calendar: Calendar(identifier: .gregorian))

    public static let version = "2024-2"

    public enum Attributes {}
    public enum AuditLog {}
    public enum Callbacks {}
    public enum Credentials {}
    public enum FederatedIdentity {}
    public enum Maintenance {}
    public enum OAuth2 {}
    public enum Phone {}
    public enum Preferences {}
    public enum Sessions {}
    public enum TOTP {}
    public enum Terms {}
    public enum User {}

    public enum UserAPIServer {
        /** Production server (stable release 2024-2) **/
        public static let main = "https://api.pace.cloud/user/2024-2"
        /** Production server (stable release 2024-2) **/
        public static let server2 = "https://api.pace.cloud/user/master"
    }
}

