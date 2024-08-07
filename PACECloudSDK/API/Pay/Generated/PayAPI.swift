//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

/** The PACE Payment API is responsible for managing payment methods for users as well as authorizing payments on behalf of PACE services.
 */
public struct PayAPI {

    /// Used to encode Dates when uses as string params
    public static var dateEncodingFormatter = DateFormatter(formatString: "yyyy-MM-dd'T'HH:mm:ss'Z'",
                                                            locale: Locale(identifier: "de_DE"),
                                                            calendar: Calendar(identifier: .gregorian))

    public static let version = "2024-2"

    public enum FleetPaymentMethods {}
    public enum NewPaymentMethods {}
    public enum PaymentMethodKinds {}
    public enum PaymentMethods {}
    public enum PaymentTokens {}
    public enum PaymentTransactions {}

    public enum PayAPIServer {
        /** Production server (stable release 2024-2) **/
        public static let main = "https://api.pace.cloud/pay/2024-2"
        /** Production server (stable release 2024-2) **/
        public static let server2 = "https://api.pace.cloud/pay/master"
    }
}

