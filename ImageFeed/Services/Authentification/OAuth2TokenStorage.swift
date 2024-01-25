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
            } else { fatalError("Уппсс, проблемы с ключом")}
        }
    }
    
    // MARK: - Private properties
    private let key = "bearerToken"
    private let keyWrapper = KeychainWrapper.standard
}
