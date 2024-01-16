import Foundation

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
        
        let completionInMainThread: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let request = authTokenRequest(code: code)
        let task = object(for: request) { [weak self] result in
            guard let self = self else { return }
            print(result)
            switch result {
            case .success(let body):
                print("Success")
                self.authToken = body.accessToken
                completionInMainThread(.success(body.accessToken))
            case .failure(let error):
                print("Failure")
                completionInMainThread(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeRequest(code: String) -> URLRequest {
        guard let url = URL(string: "...\(code)") else { fatalError("Failed to create URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}

// MARK: - Extensions: private methods
extension OAuth2Service {
    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "https://unsplash.com")!
        )
    }
}

extension OAuth2Service {
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
            }
            completion(response)
        }
    }
}
