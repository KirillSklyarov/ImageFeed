//
//  ImageListTests.swift
//  ImageFeedTests_sprint_13
//
//  Created by Kirill Sklyarov on 20.02.2024.
//


@testable import ImageFeed

import XCTest
import Foundation

final class ImageListTests: XCTestCase {
    
    func testImageListPresenterAddObserver() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImageListViewController") as! ImageListViewController
        let presenter = ImageListPresenterSpy()
        
        viewController.configure(presenter: presenter)
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.observerIsLoading)
        XCTAssertTrue(presenter.photosAreLoading)
    }
}
