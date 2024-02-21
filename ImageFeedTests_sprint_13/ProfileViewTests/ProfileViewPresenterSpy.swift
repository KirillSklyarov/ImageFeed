//
//  ProfileViewPresenterSpy.swift
//  ImageFeedTests_sprint_13
//
//  Created by Kirill Sklyarov on 19.02.2024.
//

import Foundation
import ImageFeed
import UIKit

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
    
    var updateProfileImageCalled: Bool = false
    var buttonDidTapped: Bool = false
    var observer: Bool = false
    var viewController: ProfileViewControllerProtocol?
    
    func showAlert() -> UIAlertController {
       profileLogOut()
        return UIAlertController()
    }
    
    func profileLogOut() {
        buttonDidTapped = true
    }
    
    func updateProfileImage() -> URL? {
         updateProfileImageCalled = true
        return nil
    }
    
    func addObserver() {
        observer = true
    }
}
