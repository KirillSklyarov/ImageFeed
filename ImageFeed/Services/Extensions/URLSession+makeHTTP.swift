import Foundation

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL?
    ) -> URLRequest {
        if let baseURL = Constants.defaultBaseURL,
           let requestURL = URL(string: path, relativeTo: baseURL) {
            var request = URLRequest(url: requestURL)
            request.httpMethod = httpMethod
            return request
        } else {
            print("Ошибка: baseURL or requestURL равен nil")
            return URLRequest(url: URL(string: "about:blank")!)
        }
    }
}
