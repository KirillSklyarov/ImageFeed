//
//  ProfileTest.swift
//  ImageFeedTests_sprint_13
//
//  Created by Kirill Sklyarov on 19.02.2024.
//

@testable import ImageFeed

import XCTest
import Foundation

final class ProfileViewTests: XCTestCase {
    
    func testProfileViewPresenterAddObserver() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.viewController = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.observer)
    }
    
    func testProfileViewPresenterUpdateProfileImage() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.viewController = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.updateProfileImageCalled)
    }
    
    func testProfileData() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        viewController.presenter = presenter
        presenter.viewController = viewController
        
        let myProfile = Profile(userName: "K_sklyarov",
                                name: "Kirill Sklyarov" ,
                                loginName: "@K_Sklyarov",
                                bio: nil)
        
        //when
        viewController.updateProfileDetails(profile: myProfile)
        
        //then
        XCTAssertEqual(myProfile.name, viewController.nameLabel)
        XCTAssertEqual(myProfile.loginName, viewController.nicknameLabel)
    }
    
    func testLogoutButtonTapped() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.viewController = viewController
        
        // when
        viewController.buttonTapped()
        
        //then
        XCTAssertTrue(presenter.buttonDidTapped)
    }
}
