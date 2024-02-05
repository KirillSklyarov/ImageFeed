import Foundation

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<T, Error> in
                Result { try decoder.decode(T.self, from: data) }
            }
            completion(response)
        }
    }
    
    func arrayObjectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<[T], Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<[T], Error> in
                Result { try decoder.decode([T].self, from: data) }
            }
            completion(response)
        }
    }
}
