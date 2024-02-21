//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests_sprint_13
//
//  Created by Kirill Sklyarov on 19.02.2024.
//

import Foundation
import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    
    var nameLabel: String?
    var nicknameLabel: String?
    
    func updateProfileDetails(profile: ImageFeed.Profile?) {
        if let profile = profile {
            self.nameLabel = profile.name
            self.nicknameLabel = profile.loginName
        }
    }
    
    
    func updateAvatar() {
        
    }
    
    var presenter: ImageFeed.ProfileViewPresenterProtocol?
    
    
    
}

