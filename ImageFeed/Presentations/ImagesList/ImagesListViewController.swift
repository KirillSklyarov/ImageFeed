import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImageListViewPresenterProtocol? { get set }
    var tableView: UITableView! { get set }
    
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    
    // MARK: - IB Outlets
    @IBOutlet internal weak var tableView: UITableView!
    
    var presenter: ImageListViewPresenterProtocol?
    
    // MARK: - Private properties
    private let singleViewImageSegueIdentifier = "ShowSingleImage"
    private let imageListService = ImageListService.shared
    
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
        
        let image = presenter?.avatarUrl(indexPath: indexPath)
        cell.cellImage.kf.setImage(with: image, placeholder: UIImage(named: "imagePlaceholder"))
        
        cell.cellDateLabel.text = presenter?.dateLabel(indexPath: indexPath)
        
        let likeImage = presenter?.likeImage(indexPath: indexPath)
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
}

extension ImagesListViewController: ImageListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        presenter?.didTapLike(cell: cell)
    }
}

extension ImagesListViewController {
    
    func configure(presenter: ImageListViewPresenterProtocol?) {
        self.presenter = presenter
        self.presenter?.viewController = self
    }
}
