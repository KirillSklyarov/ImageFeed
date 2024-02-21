import Foundation

let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
let AccessKey = "dHiIDhuhIUdaW45CcwS5VwQ0Jx0rZkhEVIQrgfmH0OA"
let SecretKey = "DFslzgjbIal_OLGBVdM4Hw-YtpTa-SqJ2czxvFGIvv8"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"
let DefaultBaseURL: URL = URL(string: "https://api.unsplash.com")!


struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standart: AuthConfiguration {
        return AuthConfiguration(accessKey: AccessKey,
                                 secretKey: SecretKey,
                                 redirectURI: RedirectURI,
                                 accessScope: AccessScope,
                                 defaultBaseURL: DefaultBaseURL,
                                 authURLString: UnsplashAuthorizeURLString)
    }
}
