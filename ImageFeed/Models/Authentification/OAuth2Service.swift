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
//        print("Мы проверяем есть ли действующий запрос")
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        
        let request = authTokenRequest(code: code)
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) -> Void in
            guard let self = self else { return }
            print(result)
            DispatchQueue.main.async {
                switch result {
                case .success(let body):
                    print("Ответ на запрос пришел успешный и мы сохранили authToken")
                    self.authToken = body.accessToken
                    completion(.success(body.accessToken))
                case .failure(let error):
                    print("Ответ на запрос пришел c ошибкой и мы не сохранили authToken")
                    SplashViewController().showAlert()
                    completion(.failure(error))
                    self.lastCode = nil
                }
                self.task = nil
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
