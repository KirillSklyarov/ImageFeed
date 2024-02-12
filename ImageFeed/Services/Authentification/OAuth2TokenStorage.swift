import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    // MARK: - Public properties
    var token: String? {
        get {
            return keyWrapper.string(forKey: key)
        }
        set {
            if let newValue = newValue {
            keyWrapper.set(newValue, forKey: key)
            } else {
                print("Уппсс, проблемы с ключом")
                return
            }
        }
    }
    
    // MARK: - Private properties
    private let key = "bearerToken"
    private let keyWrapper = KeychainWrapper.standard
}
