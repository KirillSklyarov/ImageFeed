import Foundation

final class ImageListService {
    
    static let shared = ImageListService()
    private init() {}
    
    private (set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private (set) var photoURL: String?
    
    static let didChangeNotification = Notification.Name(rawValue: "ImageListServiceDidChange")
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard task == nil else { fatalError("Тут у нас не завершился предыдущий процесс") }
        let request = makePhotosRequest()
        let task = URLSession.shared.arrayObjectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) -> Void in
            guard let self = self else { return }
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let photoResult):
                    // Обработка успешного результата
                    // print("Успешный результат: \(photoResult)")
                    let array = photoResult.map {Photo(from: $0) }
                    self.photos += array
//                    print(self.photos)
                    NotificationCenter.default.post(
                        name: ImageListService.didChangeNotification,
                        object: self,
                        userInfo: ["Photos": self.photos as Any])
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
    
    private func makePhotosRequest() -> URLRequest {
        let pageNumber = photos.count / 10 + 1
        let request = URLRequest.makeHTTPRequest(
            path: "/photos/"
            + "?client_id=\(Constants.accessKey)"
            + "&page=\(pageNumber)",
            httpMethod: "GET")
        return request
    }
}

