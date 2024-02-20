import Foundation

final class ImageListService {
    
    // MARK: - Public Properties
    static let shared = ImageListService()
    private init() {}
    static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    
    // MARK: - Private properties
    private (set) var photos: [Photo] = []
    private (set) var photoURL: String?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private let token = OAuth2TokenStorage().token
    
    // MARK: - Public Methods
//    func fetchPhotosNextPage(token: String) {
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard task == nil else { return }
        let request = makePhotosRequest(token: OAuth2TokenStorage().token!)
        let task = URLSession.shared.arrayObjectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) -> Void in
            guard let self = self else { return }
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let photoResult):
                    // Обработка успешного результата
                    //                    print("Вот токен: \(OAuth2TokenStorage().token ?? "ooops") Результат загрузки фоток успешный")
                    let array = photoResult.map {Photo(from: $0) }
                    self.photos += array
                    NotificationCenter.default.post(
                        name: ImageListService.didChangeNotification,
                        object: self,
                        userInfo: ["Photos": self.photos])
                case .failure(let error):
                    print("Ошибка: \(error)")
                    // Обработка ошибки
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard task == nil else { return }
        let request = makeLikeRequest(photoId: photoId, isLike: isLike)
        let task = URLSession.shared.photoForLikeObjectTask(for: request) { [weak self] (result: Result<PhotoForLike, Error>) -> Void in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let photoResult):
                    // Обработка успешного результата
                    print("Лайк поставлен - результат: \(photoResult)")
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt ?? Date(),
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                        self.photos[index] = newPhoto
                        print(self.photos)
                        completion(.success(()))
                    }
                case .failure(let error):
                    // Обработка ошибки
                    print("Лайк НЕ поставлен. Ошибка: \(error)")
                    completion(.failure(error))
                    self.task = nil
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
    private func makePhotosRequest(token: String) -> URLRequest {
        let pageNumber = photos.count / 10 + 1
        var request = URLRequest.makeHTTPRequest(
            path: "/photos/"
            + "?client_id=\(AuthConfiguration.standart.accessKey)"
            + "&page=\(pageNumber)",
            httpMethod: "GET")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest {
        let method = isLike ? "POST" : "DELETE"
        var request = URLRequest.makeHTTPRequest(
            path: "/photos/"
            + "\(photoId)"
            + "/like",
            httpMethod: "\(method)")
        if let token = token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else { print("Token not found for makeLikeRequest") }
        //       request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
        return request
    }
}
