//
//  ImageListViewPresenter.swift
//  ImageFeed
//
//  Created by Kirill Sklyarov on 18.02.2024.
//

import Foundation
import UIKit

public protocol ImageListViewPresenterProtocol {
    
    var viewController: ImageListViewControllerProtocol? { get set }
    var photos: [Photo] { get set }
    
    func addObserver()
    func loadingPhotos()
    func letsCountHeight(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    func loadingNextPage(indexPath: IndexPath)
    func avatarUrl(indexPath: IndexPath) -> URL?
    func dateLabel(indexPath: IndexPath) -> String?
    func likeImage(indexPath: IndexPath) -> UIImage? 
    func didTapLike(cell: ImagesListCell)
}


final class ImageListViewPresenter: ImageListViewPresenterProtocol {
    
    weak var viewController: ImageListViewControllerProtocol?
    
    var photos: [Photo] = []
    private let imageListService = ImageListService.shared
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    func loadingPhotos() {
        if photos.isEmpty {
            UIBlockingProgressHUD.show()
            guard OAuth2TokenStorage().token != nil else {
                print("Токен не получен. Будут проблемы")
                return
            }
            imageListService.fetchPhotosNextPage()

//            imageListService.fetchPhotosNextPage(token: token)
            UIBlockingProgressHUD.dismiss()
        }
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(
            forName: ImageListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            })
    }
    
    func didTapLike(cell: ImagesListCell) {
        guard let indexPath = viewController?.tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        photo.isLiked ? UIBlockingProgressHUD.dislike() : UIBlockingProgressHUD.like()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                self.photos = self.imageListService.photos
                let likeImage = self.likeImage(indexPath: indexPath)
                cell.likeButton.setImage(likeImage, for: .normal)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
    
    
    func updateTableViewAnimated() {
        viewController?.tableView.performBatchUpdates {
            let oldCount = photos.count
            let newCount = imageListService.photos.count
            photos = imageListService.photos
            if oldCount != newCount {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                viewController?.tableView.insertRows(at: indexPaths, with: .automatic)
            }
        } completion: { _ in }
    }
    
    
    func letsCountHeight(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = photos[indexPath.row]
        let cellIns = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let cellWigth = tableView.bounds.width - cellIns.left - cellIns.right
        let imageWidth = image.size.width
        let sizeRatio = cellWigth / imageWidth
        let cellHeight = image.size.height * sizeRatio + cellIns.top + cellIns.bottom
        
        return cellHeight
    }
    
    
    func avatarUrl(indexPath: IndexPath) -> URL? {
        let imageURL = photos[indexPath.row].thumbImageURL
        if let image = URL(string: imageURL) {
            return image
        } else {
            print("Пришлa пустая ссылка на аватарку")
            return nil
        }
    }
    
    func dateLabel(indexPath: IndexPath) -> String? {
        if let createdDate = photos[indexPath.row].createdAt {
            return dateFormatter.string(from: createdDate)
        } else {
           return ""
        }
    }
    
    func likeImage(indexPath: IndexPath) -> UIImage? {
        if photos[indexPath.row].isLiked {
            return UIImage(named: "Active")
        } else {
            return UIImage(named: "No Active")
        }
    }
    
    func loadingNextPage(indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imageListService.fetchPhotosNextPage()
//            imageListService.fetchPhotosNextPage(token: OAuth2TokenStorage().token!)
        }
    }
}
