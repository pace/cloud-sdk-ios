//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

/** POI API */
public struct POIAPI {

    /// Used to encode Dates when uses as string params
    public static var dateEncodingFormatter = DateFormatter(formatString: "yyyy-MM-dd'T'HH:mm:ss'Z'",
                                                            locale: Locale(identifier: "de_DE"),
                                                            calendar: Calendar(identifier: .gregorian))

    public static let version = "2020-4"

    public enum Admin {}
    public enum Apps {}
    public enum DataDumps {}
    public enum Delivery {}
    public enum Events {}
    public enum GasStations {}
    public enum MetadataFilters {}
    public enum POI {}
    public enum Policies {}
    public enum PriceHistories {}
    public enum Prices {}
    public enum Sources {}
    public enum Subscriptions {}
    public enum Tiles {}

    public enum POIAPIServer {
        /** Production server (stable release 2020-4) **/
        public static let main = "https://api.pace.cloud/poi/2020-4"
        /** Production server (deprecated) **/
        public static let server2 = "https://api.pace.cloud/poi/beta"
        /** Production server (retired) **/
        public static let server3 = "https://api.pace.cloud/poi/v1"
    }
}

