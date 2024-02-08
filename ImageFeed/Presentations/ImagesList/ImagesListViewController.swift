import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Private properties
    private let photosName: [String] = Array(0..<11).map{"\($0)"}
    private let singleViewImageSegueIdentifier = "ShowSingleImage"
    private let imageListService = ImageListService.shared
    
    var photos: [Photo] = []
    
    private var photoServiceObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        if photos.isEmpty {
            UIBlockingProgressHUD.show()
            imageListService.fetchPhotosNextPage()
            UIBlockingProgressHUD.dismiss()
        }
        
        photoServiceObserver = NotificationCenter.default.addObserver(
            forName: ImageListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            }
        )
    }
}

// MARK: - Private Methods
extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        cell.delegate = self
        
        let imageURL = photos[indexPath.row].thumbImageURL
        guard let image = URL(string: imageURL) else { fatalError("Пришлa пустая ссылка на аватарку")}
        cell.cellImage.kf.setImage(with: image, placeholder: UIImage(named: "imagePlaceholder"))
        cell.cellDateLabel.text = dateFormatter.string(from: Date())
        let isLiked = indexPath.row % 2 == 0
        //        let likeImage = isLiked ? UIImage(named: "No Active") : UIImage(named: "Active")
        //        cell.cellButton.setImage(likeImage, for: .normal)
        cell.setGradient()
        
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: singleViewImageSegueIdentifier, sender: indexPath)
    }
}

extension ImagesListViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let image = photos[indexPath.row]
        let cellIns = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let cellWigth = tableView.bounds.width - cellIns.left - cellIns.right
        let imageWidth = image.size.width
        let sizeRatio = cellWigth / imageWidth
        let cellHeight = image.size.height * sizeRatio + cellIns.top + cellIns.bottom
        
        return cellHeight
    }
}

extension ImagesListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == singleViewImageSegueIdentifier {
            let vc = segue.destination as! SingleViewImageController
            let indexpath = sender as! IndexPath
            let imageURL = photos[indexpath.row].largeImageURL
            vc.fullImageURL = URL(string: imageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imageListService.fetchPhotosNextPage()
        }
    }
    
    func updateTableViewAnimated() {
        tableView.performBatchUpdates {
            let oldCount = photos.count
            let newCount = imageListService.photos.count
            photos = imageListService.photos
            if oldCount != newCount {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        } completion: { _ in }
    }
}

extension ImagesListViewController: ImageListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                let likeImage = photo.isLiked ? UIImage(named: "No Active") : UIImage(named: "Active")
                cell.cellButton.setImage(likeImage, for: .normal)
            case .failure (let error):
                print(error)
            }
            
        }
    }
}



//extension ImagesListViewController: ImagesListCellDelegate {
//
//    func imageListCellDidTapLike(_ cell: ImagesListCell) {
//
//      guard let indexPath = tableView.indexPath(for: cell) else { return }
//      let photo = photos[indexPath.row]
//      // Покажем лоадер
//     UIBlockingProgressHUD.show()
//     imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
//        switch result {
//        case .success:
//           // Синхронизируем массив картинок с сервисом
//           self.photos = self.imagesListService.photos
//           // Изменим индикацию лайка картинки
//           сell.setIsLiked(self.photos[indexPath.row].isLiked)
//           // Уберём лоадер
//           UIBlockingProgressHUD.dismiss()
//        case .failure:
//           // Уберём лоадер
//           UIBlockingProgressHUD.dismiss()
//           // Покажем, что что-то пошло не так
//           // TODO: Показать ошибку с использованием UIAlertController
//           }
//        }
//    }
//
//}
