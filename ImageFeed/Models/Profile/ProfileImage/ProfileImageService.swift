import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private init() {}
    
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    private let token = OAuth2TokenStorage().token
    private let urlSession = URLSession.shared
    
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        print("Раздел Аватарки - делаем запрос")
//        print(token)
        if task != nil { return }
        task?.cancel()
        //        lastCode = token
        guard let token = token else { fatalError("При попытке запросить аватарку token = nil")}
        let request = makeProfileImageRequest(userName: username, token: token)
        print("Запрос на данные аватарки успешно создан")
        let task = object(for: request) { [weak self] (result: Result<UserResult, Error>) -> Void in
            guard self != nil else { return }
            NotificationCenter.default.post(name: ProfileImageService.DidChangeNotification,
                                            object: self), userInfo: ["URL": profileImageURL])
            
            
            
//            NotificationCenter.default                                     // 1
//                .post(                                                     // 2
//                    name: ProfileImageService.DidChangeNotification,       // 3
//                    object: self,                                          // 4
//                    userInfo: ["URL": profileImageURL])                    // 5
            
//            print(result)
            switch result {
            case .success(let profileImageData):
                print("Ответ на запрос по Аватарке пришел успешный и мы ее сохранили")
                self?.avatarURL = profileImageData.profileImageSmall.small
                completion(.success(profileImageData.profileImageSmall.small))
            case .failure(let error):
                print("Ответ на запрос Аватарки пришел c ошибкой и мы ее не сохранили")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeProfileImageRequest(userName: String, token: String) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(path: "/users/\(userName)", httpMethod: "GET")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // В этом методе мы обрабатываем результат полученного ответа
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<UserResult, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<UserResult, Error> in
                Result { try decoder.decode(UserResult.self, from: data) }
            }
            completion(response)
        }
    }
}
