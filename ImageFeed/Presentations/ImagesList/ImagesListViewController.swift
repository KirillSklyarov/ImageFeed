import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    
    var presenter: ImageListViewPresenterProtocol? { get set }
    
    func updateTableViewAnimated()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var tableView: UITableView!
    
    var presenter: ImageListViewPresenterProtocol?
    
    // MARK: - Private properties
    private let singleViewImageSegueIdentifier = "ShowSingleImage"
    private let imageListService = ImageListService.shared
    
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
        
        configure(presenter: ImageListViewPresenter())
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        presenter?.loadingPhotos()
        presenter?.addObserver()
    }
}

// MARK: - Private Methods
extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        cell.delegate = self
        
        guard  let imageURL = presenter?.photos[indexPath.row].thumbImageURL,
               let image = URL(string: imageURL) else {
            print("Пришлa пустая ссылка на аватарку")
            return
        }
        cell.cellImage.kf.setImage(with: image, placeholder: UIImage(named: "imagePlaceholder"))
        
        if let createdDate = presenter?.photos[indexPath.row].createdAt {
            cell.cellDateLabel.text = dateFormatter.string(from: createdDate)
        } else {
            cell.cellDateLabel.text = ""
        }
        
        let likeImage = presenter?.photos[indexPath.row].isLiked == true ? UIImage(named: "Active") : UIImage(named: "No Active")
        cell.likeButton.setImage(likeImage, for: .normal)
        
        cell.setGradient()
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.photos.count ?? 0
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
        guard let result = presenter?.letsCountHeight(tableView, heightForRowAt: indexPath) else {
            return 0.0 }
            return result
    }
}

extension ImagesListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == singleViewImageSegueIdentifier {
            let vc = segue.destination as! SingleViewImageController
            let indexpath = sender as! IndexPath
            let imageURL = presenter?.photos[indexpath.row].largeImageURL
            vc.fullImageURL = URL(string: imageURL!)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.loadingNextPage(indexPath: indexPath)
    }
    
    func updateTableViewAnimated() {
        tableView.performBatchUpdates {
            guard let oldCount = presenter?.photos.count else { return }
            let newCount = imageListService.photos.count
            presenter?.photos = imageListService.photos
            if oldCount != newCount {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        } completion: { _ in }
    }
}

extension ImagesListViewController: ImageListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let photo = presenter?.photos[indexPath.row] else { return }
        photo.isLiked ? UIBlockingProgressHUD.dislike() : UIBlockingProgressHUD.like()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            switch result {
            case .success:
                self.presenter?.photos = self.imageListService.photos
                let likeImage = ((self.presenter?.photos[indexPath.row].isLiked) != nil) ? UIImage(named: "Active") : UIImage(named: "No Active")
                cell.likeButton.setImage(likeImage, for: .normal)
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
}

extension ImagesListViewController {
    
    func configure(presenter: ImageListViewPresenterProtocol?) {
        self.presenter = presenter
        self.presenter?.viewController = self
    }
}
