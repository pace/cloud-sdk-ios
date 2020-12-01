//
//  App+2FA.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Base32
import LocalAuthentication
import OneTimePassword

protocol SecureDataCommunication {
    func handleBiometryAvailbilityRequest(query: String, host: String)
    func setTOTPSecret(query: String, host: String)
    func getTOTP(query: String, host: String)
    func setSecureData(query: String, host: String)
    func getSecureData(query: String, host: String)
}

extension App {
    var userDefaults: UserDefaults {
        UserDefaults.standard
    }

    var laPolicy: LAPolicy {
        return .deviceOwnerAuthenticationWithBiometrics
    }

    func retrieveKey(for key: String, host: String) -> String {
        // We are appending a device id, because the Keychain is
        // persisted outside of the app's sandbox, therefore
        // we cannot guarantee that it will be deleted, when
        // the app is deleted.
        // However, to ensure that the secret is only ever available in
        // the current app, the device id, which is generated per
        // app install, will be appended to the given key.

        return "\(DeviceInformation.id)_\(host)_\(key)"
    }

    func handleBiometryAvailbilityRequest(query: String, host: String) {
        guard var biometryAvailbility = BiometryAvailabilityData(from: query, host: host) else {
            AppKit.shared.notifyDidFail(with: .badRequest)
            return
        }

        let laContext = LAContext()
        var authError: NSError?

        let isBiometryAvailable = laContext.canEvaluatePolicy(laPolicy, error: &authError)

        biometryAvailbility.statusCode = BiometryAvailabilityData.StatusCode.init(available: isBiometryAvailable).rawValue
        appSecureCommunicationDelegate?.sendBiometryStatus(data: biometryAvailbility)
   }

    func setTOTPSecret(query: String, host: String) {
        guard let totpData = TOTPSecretData(from: query), var setTOTPResponse = SetTOTPResponse(from: query, host: host) else {
            AppKit.shared.notifyDidFail(with: .badRequest)
            return
        }

        let laContext = LAContext()
        var authError: NSError?
        let reasonText = "payment.authentication.confirmation".localized

        guard laContext.canEvaluatePolicy(laPolicy, error: &authError) else {
            setTOTPResponse.statusCode = SetTOTPResponse.StatusCode.init(success: false).rawValue
            appSecureCommunicationDelegate?.sendSetTOTPResponse(data: setTOTPResponse)

            return
        }

        laContext.evaluatePolicy(laPolicy, localizedReason: reasonText) { [weak self] success, error in
            guard error == nil, success, let unwrappedSelf = self else {
                setTOTPResponse.statusCode = SetTOTPResponse.StatusCode.init(success: false).rawValue
                self?.appSecureCommunicationDelegate?.sendSetTOTPResponse(data: setTOTPResponse)
                return
            }

            do {
                let data = try PropertyListEncoder().encode(totpData)
                let secretKey: String = unwrappedSelf.retrieveKey(for: totpData.key, host: setTOTPResponse.host)
                unwrappedSelf.userDefaults.set(data, forKey: secretKey)
            } catch {
                setTOTPResponse.statusCode = SetTOTPResponse.StatusCode.init(success: false).rawValue
                unwrappedSelf.appSecureCommunicationDelegate?.sendSetTOTPResponse(data: setTOTPResponse)
            }

            setTOTPResponse.statusCode = SetTOTPResponse.StatusCode.init(success: true).rawValue
            unwrappedSelf.appSecureCommunicationDelegate?.sendSetTOTPResponse(data: setTOTPResponse)
        }
    }

    func getTOTP(query: String, host: String) {
        guard var getTOTPData = GetTOTPData(from: query, host: host) else {
            AppKit.shared.notifyDidFail(with: .badRequest)
            return
        }

        let secretKey: String = retrieveKey(for: getTOTPData.key, host: getTOTPData.host)

        guard userDefaults.data(forKey: secretKey) != nil else {
            getTOTPData.statusCode = GetTOTPData.StatusCode.notFound.rawValue
            appSecureCommunicationDelegate?.sendGetTOTPResponse(data: getTOTPData)
            return
        }

        let laContext = LAContext()
        let reasonText = "payment.authentication.confirmation".localized

        var authError: NSError?

        guard laContext.canEvaluatePolicy(laPolicy, error: &authError) else {
            getTOTPData.statusCode = GetTOTPData.StatusCode.notAllowed.rawValue
            appSecureCommunicationDelegate?.sendGetTOTPResponse(data: getTOTPData)

            return
        }

        laContext.evaluatePolicy(laPolicy, localizedReason: reasonText) { [weak self] success, error in
            guard error == nil, success else {
                getTOTPData.statusCode = GetTOTPData.StatusCode.unauthorized.rawValue
                self?.appSecureCommunicationDelegate?.sendGetTOTPResponse(data: getTOTPData)
                return
            }

            guard let totp = self?.generateTOTP(with: getTOTPData) else {
                getTOTPData.statusCode = GetTOTPData.StatusCode.internalError.rawValue
                self?.appSecureCommunicationDelegate?.sendGetTOTPResponse(data: getTOTPData)
                return
            }

            getTOTPData.totp = totp

            switch laContext.biometryType {
            case .faceID:
                getTOTPData.biometryMethod = .face

            case .touchID:
                getTOTPData.biometryMethod = .fingerprint

            default:
                getTOTPData.biometryMethod = .other
            }

            self?.appSecureCommunicationDelegate?.sendGetTOTPResponse(data: getTOTPData)
        }
    }

    private func generateTOTP(with data: GetTOTPData) -> String? {
        let secretKey: String = retrieveKey(for: data.key, host: data.host)

        guard let storedData: Data = userDefaults.data(forKey: secretKey),
            let storedTOTPSecretData = try? PropertyListDecoder().decode(TOTPSecretData.self, from: storedData) else {
                return nil
        }

        guard let secretData = MF_Base32Codec.data(fromBase32String: storedTOTPSecretData.secret), !secretData.isEmpty else { return nil }

        let algorithm: Generator.Algorithm

        switch storedTOTPSecretData.algorithm {
        case "SHA1":
            algorithm = .sha1

        case "SHA256":
            algorithm = .sha256

        case "SHA512":
            algorithm = .sha512

        default:
            algorithm = .sha1
        }

        guard let generator = Generator(
            factor: .timer(period: storedTOTPSecretData.period),
            secret: secretData,
            algorithm: algorithm,
            digits: storedTOTPSecretData.digits) else {
                return nil
        }

        let token = Token(name: "TOTP", issuer: "PACE", generator: generator)
        let time = Date(timeIntervalSince1970: data.serverTime)

        do {
            let passwordAtTime = try token.generator.password(at: time)
            return passwordAtTime
        } catch {
            // Cannot generate password for invalid time
            return nil
        }
    }

    func setSecureData(query: String, host: String) {
        guard let secureData = SetSecureData(from: query, host: host), var setSecureDataResponse = SetSecureDataResponse(from: query, host: host) else {
            AppKit.shared.notifyDidFail(with: .badRequest)
            return
        }

        let key = retrieveKey(for: secureData.key, host: setSecureDataResponse.host)

        userDefaults.set(secureData.value, forKey: key)

        setSecureDataResponse.statusCode = SetSecureDataResponse.StatusCode.init(success: true).rawValue

        appSecureCommunicationDelegate?.sendSetSecureDataResponse(data: setSecureDataResponse)
    }

    func getSecureData(query: String, host: String) {
        guard var getSecureData = GetSecureData(from: query, host: host) else {
            AppKit.shared.notifyDidFail(with: .badRequest)
            return
        }

        let key = retrieveKey(for: getSecureData.key, host: getSecureData.host)
        let laContext = LAContext()
        let reasonText = "secureData.authentication.confirmation".localized

        var authError: NSError?

        guard let value = userDefaults.string(forKey: key) else {
            getSecureData.statusCode = GetTOTPData.StatusCode.notFound.rawValue
            appSecureCommunicationDelegate?.sendGetSecureDataResponse(data: getSecureData)
            return
        }

        guard laContext.canEvaluatePolicy(laPolicy, error: &authError) else {
            getSecureData.statusCode = GetSecureData.StatusCode.notAllowed.rawValue
            appSecureCommunicationDelegate?.sendGetSecureDataResponse(data: getSecureData)

            return
        }

        laContext.evaluatePolicy(laPolicy, localizedReason: reasonText) { [weak self] success, error in
            guard error == nil, success else {
                getSecureData.statusCode = GetTOTPData.StatusCode.unauthorized.rawValue
                self?.appSecureCommunicationDelegate?.sendGetSecureDataResponse(data: getSecureData)
                return
            }

            getSecureData.value = value

            self?.appSecureCommunicationDelegate?.sendGetSecureDataResponse(data: getSecureData)
        }
    }
}
