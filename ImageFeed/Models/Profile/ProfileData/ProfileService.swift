import Foundation

final class ProfileService {
    
    static let shared = ProfileService()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        print("""
---------------------------------------------------------
Раздел Профиля - мы проверяем есть ли действующий запрос
---------------------------------------------------------
""")
        guard task == nil else { return } //fatalError("Ну хер знает что") }
//        task?.cancel()
        
        let request = makeProfileRequest(token: token)
        print("✅ Запрос на данные профиля успешно создан")
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) -> Void in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let profileData):
                    print("✅ Ответ на запрос по Профайлу пришел успешный и мы сохранили данные Профайла")
                    let profileData = Profile(from: profileData)
                    self.profile = profileData
                    completion(.success(profileData))
                case .failure(let error):
                    print("🔴 Ответ на запрос пришел c ошибкой и мы не сохранили Профайл")
                    completion(.failure(error))
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeProfileRequest(token: String) -> URLRequest {
        var request = URLRequest.makeHTTPRequest(path: "/me", httpMethod: "GET")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
