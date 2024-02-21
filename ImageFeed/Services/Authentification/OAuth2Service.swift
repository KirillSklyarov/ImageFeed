import UIKit

final class OAuth2Service {
    
    // MARK: - Public properties
    static let shared = OAuth2Service()
    private init() {}
    
    // MARK: - Private properties
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    // MARK: - Public methods
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        let request = authTokenRequest(code: code)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) -> Void in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let body):
                    self.authToken = body.accessToken
                    completion(.success(body.accessToken))
                case .failure(let error):
                    completion(.failure(error))
                    self.lastCode = nil
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
}

// MARK: - Extensions: private methods
extension OAuth2Service {
    private func authTokenRequest(code: String) -> URLRequest {
        
        let params = AuthConfiguration.standart
        
        return URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(params.accessKey)"
            + "&&client_secret=\(params.secretKey)"
            + "&&redirect_uri=\(params.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "https://unsplash.com")!
        )
    }
    
    private func makeRequest(code: String) -> URLRequest? {
        if let url = URL(string: "...\(code)") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            return request
        } else {
            print("Failed to create URL")
            return nil
        }
    }
}
