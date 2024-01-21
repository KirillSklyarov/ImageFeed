import Foundation

struct UserResult: Codable {
    let profileImageSmall: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImageSmall = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}
