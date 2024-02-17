import Foundation

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL? = AuthConfiguration.standart.defaultBaseURL
    ) -> URLRequest {
        if let url = URL(string: path, relativeTo: baseURL) {
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod
            return request
        } else {
            return URLRequest(url: URL(string: "about:blank")!)
        }
    }
}
