//
//  SessionCache.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import AppAuth

class SessionCache {
    static func loadSession(for environment: PACECloudSDK.Environment) -> OIDAuthState? {
        IDKitLogger.d("Attempting to load previous session...")

        // Migrate old fallback key first
        SDKUserDefaults.migrateDataIfNeeded(key: IDKitConstants.UserDefaults.sessionCache, isUserSensitiveData: false)

        let sessionCacheKey = sessionCacheKey(for: environment)
        SDKUserDefaults.migrateDataIfNeeded(key: sessionCacheKey, isUserSensitiveData: false)

        guard let data = SDKUserDefaults.data(for: sessionCacheKey, isUserSensitiveData: false) else { return nil }

        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data)
        } catch {
            IDKitLogger.e("Failed unarchiving session with error \(error)")
        }

        return nil
    }

    static func persistSession(_ session: OIDAuthState?, for environment: PACECloudSDK.Environment) {
        IDKitLogger.d("Persisting session")

        var data: Data?

        if let session = session {
            do {
                data = try NSKeyedArchiver.archivedData(withRootObject: session, requiringSecureCoding: false)
            } catch {
                IDKitLogger.e("Failed archiving session with error \(error)")
            }
        }

        SDKUserDefaults.set(data, for: sessionCacheKey(for: environment), isUserSensitiveData: false)
    }

    static func reset(for environment: PACECloudSDK.Environment) {
        // Remove session for old key as well
        [sessionCacheKey(for: environment), IDKitConstants.UserDefaults.sessionCache].forEach {
            SDKUserDefaults.set(nil, for: $0, isUserSensitiveData: false)
        }
    }

    private static func sessionCacheKey(for environment: PACECloudSDK.Environment) -> String {
        "\(IDKitConstants.UserDefaults.sessionCache)_\(environment.rawValue)"
    }
}
