import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private init() {}
    
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    private let token = OAuth2TokenStorage().token
    private let urlSession = URLSession.shared
    
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    func fetchProfileImageURL(username: String, token: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        print("""
    ---------------------------------------------------------
               Раздел Аватарки - делаем запрос
    ---------------------------------------------------------
    """)
           
        guard task == nil else { fatalError("Тут у нас не завершился предыдущий процесс") }
//        guard let token = token else { fatalError("При попытке запросить аватарку token = nil")}
        
        let request = makeProfileImageRequest(userName: username, token: token)
        print("✅ Запрос на данные аватарки успешно создан")
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) -> Void in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let profileImageData):
                    print("✅ Ответ на запрос по Аватарке пришел успешный и мы ее сохранили")
                    self.avatarURL = profileImageData.profileImage.small
                    completion(.success(profileImageData.profileImage.small))
                    NotificationCenter.default.post(name: ProfileImageService.DidChangeNotification,
                                                    object: self,
                                                    userInfo: ["URL": self.avatarURL as Any])
                case .failure(let error):
                    print("🔴 Ответ на запрос Аватарки пришел c ошибкой и мы ее не сохранили")
                    completion(.failure(error))
                }
                self.task = nil
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
}
