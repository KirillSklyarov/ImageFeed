import Foundation

final class ProfileService {
    
    static let shared = ProfileService()
    private init() {}
    
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private(set) var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        print("Раздел Профиля - мы проверяем есть ли действующий запрос")
        if task != nil { return }
        task?.cancel()
        //        lastCode = token
        
        let request = makeProfileRequest(token: token)
        print("Запрос на данные профиля успешно создан")
        let task = object(for: request) { [weak self] (result: Result<ProfileResult, Error>) -> Void in
            guard let self = self else { return }
            switch result {
            case .success(let profileData):
                print("Ответ на запрос по Профайлу пришел успешный и мы сохранили данные Профайла")
                let profileData = Profile(from: profileData)
                self.profile = profileData
                completion(.success(profileData))
            case .failure(let error):
                print("Ответ на запрос пришел c ошибкой и мы не сохранили Профайл")
                completion(.failure(error))
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


extension ProfileService {
    // В этом методе мы обрабатываем результат полученного ответа
    
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<ProfileResult, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<ProfileResult, Error> in
                Result { try decoder.decode(ProfileResult.self, from: data) }
            }
//            print("Тут мы получаем ответ от сервера")
            completion(response)
        }
    }
}
