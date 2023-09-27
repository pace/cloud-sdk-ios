// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Authorize to access secured data
  internal static let appkitSecureDataAuthenticationConfirmation = L10n.tr("Localizable", "appkit_secureData_authentication_confirmation", fallback: "Authorize to access secured data")
  /// Close
  internal static let commonActionClose = L10n.tr("Localizable", "common_action_close", fallback: "Close")
  /// Try again
  internal static let commonRetry = L10n.tr("Localizable", "common_retry", fallback: "Try again")
  /// Pay at the pump
  internal static let defaultDrawerFirstLine = L10n.tr("Localizable", "default_drawer_first_line", fallback: "Pay at the pump")
  /// Connected Fueling
  internal static let defaultDrawerSecondLine = L10n.tr("Localizable", "default_drawer_second_line", fallback: "Connected Fueling")
  /// PACE needs a stable and sufficiently fast network connection to continue.
  /// 
  /// Please make sure that your app is allowed to access your phone’s mobile data. You can also use Wi-Fi.
  internal static let errorConnectionProblemNetwork = L10n.tr("Localizable", "error_connection_problem_network", fallback: "PACE needs a stable and sufficiently fast network connection to continue.\n\nPlease make sure that your app is allowed to access your phone’s mobile data. You can also use Wi-Fi.")
  /// Insufficient network connection
  internal static let errorConnectionProblemNetworkHeadline = L10n.tr("Localizable", "error_connection_problem_network_headline", fallback: "Insufficient network connection")
  /// Sorry, something went wrong. Please try again later.
  internal static let errorGeneric = L10n.tr("Localizable", "error_generic", fallback: "Sorry, something went wrong. Please try again later.")
  /// Confirm the use of biometric authentication
  internal static let idkitBiometryAuthenticationConfirmation = L10n.tr("Localizable", "idkit_biometryAuthentication_confirmation", fallback: "Confirm the use of biometric authentication")
  /// Loading data
  internal static let loadingText = L10n.tr("Localizable", "loading_text", fallback: "Loading data")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
