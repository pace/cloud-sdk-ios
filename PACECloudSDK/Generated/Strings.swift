// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Pay now
  internal static let appkitPaymentAuthenticationConfirmation = L10n.tr("Localizable", "appkit_payment_authentication_confirmation")
  /// Authorize to access secured data
  internal static let appkitSecureDataAuthenticationConfirmation = L10n.tr("Localizable", "appkit_secureData_authentication_confirmation")
  /// Close
  internal static let commonActionClose = L10n.tr("Localizable", "common_action_close")
  /// Try again
  internal static let commonRetry = L10n.tr("Localizable", "common_retry")
  /// PACE needs a stable and sufficiently fast network connection to continue.\n\nPlease make sure that your app is allowed to access your phone’s mobile data. You can also use Wi-Fi.
  internal static let errorConnectionProblemNetwork = L10n.tr("Localizable", "error_connection_problem_network")
  /// Insufficient network connection
  internal static let errorConnectionProblemNetworkHeadline = L10n.tr("Localizable", "error_connection_problem_network_headline")
  /// Sorry, something went wrong. Please try again later.
  internal static let errorGeneric = L10n.tr("Localizable", "error_generic")
  /// Confirm the use of biometric authentication
  internal static let idkitBiometryAuthenticationConfirmation = L10n.tr("Localizable", "idkit_biometryAuthentication_confirmation")
  /// Loading data
  internal static let loadingText = L10n.tr("Localizable", "loading_text")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
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
