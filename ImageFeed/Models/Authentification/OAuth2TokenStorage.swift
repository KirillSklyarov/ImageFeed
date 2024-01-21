import Foundation

final class OAuth2TokenStorage {
    
    // MARK: - Public properties
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: key)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
    
    // MARK: - Private properties
    private let key = "bearerToken"
}

