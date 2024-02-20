//
//  ImageListPresenterSpy.swift
//  ImageFeedTests_sprint_13
//
//  Created by Kirill Sklyarov on 20.02.2024.
//

import Foundation
import ImageFeed
import UIKit

final class ImageListPresenterSpy: ImageListViewPresenterProtocol {
    var viewController: ImageFeed.ImageListViewControllerProtocol?
    var photos: [ImageFeed.Photo] = []
    var photosAreLoading: Bool = false
    var observerIsLoading: Bool = false
    var avatarIsLoading: Bool = false
    var dateIsLoading: Bool = false
    var likeIsLoading: Bool = false
    var didTapLikeButton: Bool = false
    var nextPageIsLoading: Bool = false
    var heightIsCounting: Bool = false
    
    func addObserver() {
        observerIsLoading = true
    }
    
    func loadingPhotos() {
        photosAreLoading = true
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    
    func avatarUrl(indexPath: IndexPath) -> URL? {
        avatarIsLoading = true
        let imageURL = photos[indexPath.row].thumbImageURL
        if let image = URL(string: imageURL) {
            return image
        } else {
            print("Пришлa пустая ссылка на аватарку")
            return nil
        }
    }
    
    
    func dateLabel(indexPath: IndexPath) -> String? {
        dateIsLoading = true
        if let createdDate = photos[indexPath.row].createdAt {
            return dateFormatter.string(from: createdDate)
        } else {
           return ""
        }
    }
    
    func likeImage(indexPath: IndexPath) -> UIImage? {
        likeIsLoading = true
        if photos[indexPath.row].isLiked {
            return UIImage(named: "Active")
        } else {
            return UIImage(named: "No Active")
        }
    }
    
    
    func didTapLike(cell: ImageFeed.ImagesListCell) {
        didTapLikeButton = true
    }
    
//    let imageListService = ImageListService.shared
    
    func loadingNextPage(indexPath: IndexPath) {
        nextPageIsLoading = true
//        ImageListService.shared.fetchPhotosNextPage()
    }
    
    func letsCountHeight(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        heightIsCounting = true
        return 0.0
    }
}
