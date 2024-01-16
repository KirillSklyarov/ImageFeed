import Foundation

final class ProfileService {
    
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
    }
}


struct ProfileResult: Codable {
    let userName: String
    let firstName: String
    let lastName: String
    let bio: String
}

struct Profile {
    let userName: String
    let name: String
    let loginName: String
    let bio: String
    
    init(from result: ProfileResult) {
        self.userName = result.userName
        self.name = result.firstName + result.lastName
        self.loginName = "@" + result.userName
        self.bio = result.bio
    }
}

private func makeProfileRequest(token: String) -> URLRequest {
    var request = URLRequest.makeHTTPRequest(path: "/me", httpMethod: "GET")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    return request
}


