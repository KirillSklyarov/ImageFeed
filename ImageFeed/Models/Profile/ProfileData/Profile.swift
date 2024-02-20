import Foundation

public struct Profile {
    let userName: String
    public let name: String
    public let loginName: String
    let bio: String?
    
    init(from result: ProfileResult) {
        self.userName = result.username
        self.name = result.firstName + " " + result.lastName
        self.loginName = "@" + result.username
        self.bio = result.bio
    }
    
    init(userName: String, name: String, 
         loginName: String, bio: String?) {
        self.userName = userName
        self.name = name
        self.loginName = loginName
        self.bio = bio
    }
}
