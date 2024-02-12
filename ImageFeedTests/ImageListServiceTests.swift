//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Kirill Sklyarov on 06.02.2024.
//

@testable import ImageFeed
import XCTest

final class ImageListServiceTests: XCTestCase {
    
    func testExample() {
        let service = ImageListService.shared
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImageListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { _ in
                expectation.fulfill()
            }
        )
        service.fetchPhotosNextPage()
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
        
        service.fetchPhotosNextPage()
        
    }
}









//func testPerformanceExample() throws {
//    // This is an example of a performance test case.
//    measure {
//        // Put the code you want to measure the time of here.
//    }
//}
