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
        viewController.configure(presenter: presenter)
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.observer)
    }
    
    func testProfileViewPresenterUpdateProfileImage() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.configure(presenter: presenter)
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.updateProfileImageCalled)
    }
}
