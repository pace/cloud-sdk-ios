//
//  Localizable.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public protocol PACELocalizable {
    /// The text for the native alert when an app is trying to access or set secure data.
    ///
    /// Used for generating OTPs during the payment process. Examples:
    ///
    /// Default `de`: _Jetzt autorisieren, um auf gesicherte Daten zuzugreifen_
    ///
    /// Default `en`: _Authorize to access secured data_
    var appkitSecureDataAuthenticationConfirmation: String { get }

    /// A common text for a `close` action.
    ///
    /// Used in native error screens. Examples:
    ///
    /// Default `de`: _Schließen_
    ///
    /// Default `en`: _Close_
    var commonClose: String { get }

    /// A common text for a `retry` action.
    ///
    /// Used in native error screens. Examples:
    ///
    /// Default `de`: _Erneut versuchen_
    ///
    /// Default `en`: _Try again_
    var commonRetry: String { get }

    /// A common text in case an error has occured.
    ///
    /// Used in native error screens. Examples:
    ///
    /// Default `de`: _Es ist ein Fehler aufgetreten. Bitte probiere es später noch einmal._
    ///
    /// Default `en`: _Sorry, something went wrong. Please try again later._
    var errorGeneric: String { get }

    /// The text for the native alert when initially requesting to use biometric authentication.
    ///
    /// Used when requesting biometric authentication via `IDKit`.
    ///
    /// Default `de`: _Bestätige die Verwendung der biometrischen Authentifizierung_
    ///
    /// Default `en`: _Confirm the use of biometric authentication_
    var idkitBiometryAuthenticationConfirmation: String { get }

    /// A common text for a `loading` action.
    ///
    /// Used in native loading screen, e.g. when starting an app. Examples:
    ///
    /// Default `de`: _Daten werden geladen_
    ///
    /// Default `en`: _Loading data_
    var loadingText: String { get }
}

extension PACECloudSDK {
    open class Localizable: PACELocalizable {
        public var appkitSecureDataAuthenticationConfirmation: String = L10n.appkitSecureDataAuthenticationConfirmation
        public var commonClose: String = L10n.commonActionClose
        public var commonRetry: String = L10n.commonRetry
        public var errorGeneric: String = L10n.errorGeneric
        public var idkitBiometryAuthenticationConfirmation: String = L10n.idkitBiometryAuthenticationConfirmation
        public var loadingText: String = L10n.loadingText

        public init() {}
    }
}
