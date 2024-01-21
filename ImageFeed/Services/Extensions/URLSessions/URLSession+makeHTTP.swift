import Foundation

extension URLRequest {
    static func makeHTTPRequest(
        path: String,
        httpMethod: String,
        baseURL: URL? = Constants.defaultBaseURL
    ) -> URLRequest {
        if let url = URL(string: path, relativeTo: baseURL) {
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod
            print("Request успешно создан")
            return request
        } else {
            print("Ошибка: baseURL or requestURL равен nil")
            return URLRequest(url: URL(string: "about:blank")!)
        }
    }
}
