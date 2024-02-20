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
        viewController.presenter = presenter
        presenter.viewController = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.observerIsLoading)
        XCTAssertTrue(presenter.photosAreLoading)
    }
    
    
//    func testPhotoData() {
//        // given
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: "ImageListViewController") as! ImageListViewController
//        let presenter = ImageListPresenterSpy()
//        viewController.presenter = presenter
//        presenter.viewController = viewController
//        
//        let myPhoto = Photo(id: "firstPhoto",
//                            size: CGSize(width: 400, height: 400),
//                            createdAt: Date(),
//                            welcomeDescription: nil,
//                            thumbImageURL: "123",
//                            largeImageURL: "123",
//                            isLiked: false)
//        presenter.photos.append(myPhoto)
//        
//        _ = viewController.view
//        
//        viewController.tableView.reloadData()
//        sleep(1)
//        
//        let indexPath = IndexPath(row: 0, section: 0)
//        let cell = viewController.tableView.cellForRow(at: indexPath) as! ImagesListCell
//        
//        let dateFormatter = ISO8601DateFormatter()
//        let currentDate = Date()
//        let dateString = dateFormatter.string(from: currentDate)
//        
//        XCTAssertEqual(cell.cellDateLabel.text, dateString)
//    }
}
