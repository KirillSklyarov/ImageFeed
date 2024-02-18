//
//  ImageListViewPresenter.swift
//  ImageFeed
//
//  Created by Kirill Sklyarov on 18.02.2024.
//

import Foundation
import UIKit

protocol ImageListViewPresenterProtocol {
    
    var viewController: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get set }
    
    func addObserver()
    func loadingPhotos()
    func letsCountHeight(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    func loadingNextPage(indexPath: IndexPath)
}


final class ImageListViewPresenter: ImageListViewPresenterProtocol {
    
    weak var viewController: ImagesListViewControllerProtocol?
    
    internal var photos: [Photo] = []
    private let imageListService = ImageListService.shared

    func loadingPhotos() {
        if photos.isEmpty {
            UIBlockingProgressHUD.show()
            guard let token = OAuth2TokenStorage().token else {
                print("Токен не получен. Будут проблемы")
                return
            }
            imageListService.fetchPhotosNextPage(token: token)
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
                self.viewController?.updateTableViewAnimated()
            })
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
    
    
    func loadingNextPage(indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imageListService.fetchPhotosNextPage(token: OAuth2TokenStorage().token!)
        }
    }
}
