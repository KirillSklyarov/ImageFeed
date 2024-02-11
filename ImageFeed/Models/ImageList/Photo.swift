import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
    
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.full
        self.isLiked = result.likedByUser
    
        self.createdAt = {
            let dateFormatter = ISO8601DateFormatter()
            guard let date = dateFormatter.date(from: result.createdAt) else  { fatalError("Can't convert the date") }
            return date
        }()
    }
    
    init(id: String, size: CGSize, createdAt: Date, welcomeDescription: String?, thumbImageURL: String, largeImageURL: String, isLiked: Bool) {
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.welcomeDescription = welcomeDescription
        self.isLiked = isLiked
        self.largeImageURL = largeImageURL
        self.thumbImageURL = thumbImageURL
    }
}
