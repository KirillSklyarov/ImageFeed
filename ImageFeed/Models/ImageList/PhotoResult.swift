
import Foundation

struct PhotoResult: Decodable {
    let id: String
    let likedByUser: Bool
    let createdAt: String
    let width, height: Int
    let description: String?
    let urls: PhotoURL
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, description, urls
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
    }
}

struct PhotoURL: Decodable {
    let full: String
    let thumb: String
}

struct PhotoForLike: Decodable {
    let photo: PhotoResult?
}
