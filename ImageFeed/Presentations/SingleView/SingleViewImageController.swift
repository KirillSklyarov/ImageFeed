import UIKit
import ProgressHUD
import Kingfisher

final class SingleViewImageController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shareButton: UIButton!
    
    // MARK: - Public Properties
    var image: UIImage! = UIImage(named: "imagePlaceholder") {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    var fullImageURL: URL?
    
    // MARK: - IB Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func sharingAction(_ sender: Any) {
        let items: [UIImage] = [image]
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(activityController, animated: true)
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        
        if fullImageURL != nil {
            downloadImageAndDisplayOnFullScreen()
        }
    }
}

// MARK: - UIScrollViewDelegate
extension SingleViewImageController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

// MARK: - Private methods
extension SingleViewImageController {
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: true)
        scrollView.layoutIfNeeded()
        let newContentSize = self.scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleViewImageController {
    private func downloadImageAndDisplayOnFullScreen() {
        if let fullImageURL = fullImageURL {
            Kingfisher.ImageDownloader.default.downloadImage(
                with: fullImageURL,
                progressBlock: { receivedSize, totalSize in
                    let progress = Float(receivedSize) / Float(totalSize)
                    ProgressHUD.progress("The picture is loading", CGFloat(progress))
                })  { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let value):
                        UIBlockingProgressHUD.dismiss()
                        let image = value.image
                        self.image = image
                    case .failure(let error):
                        print(error)
                        self.showAlert()
                    }
                }
        }
    }
}


extension SingleViewImageController {
    private func showAlert() {
        let alertController = UIAlertController(
            title: nil,
            message: "Что-то пошло не так. Попробовать еще раз?",
            preferredStyle: .alert)
        let tryAgain = UIAlertAction(title: "Повторить", style: .default, handler: { _ in
            self.downloadImageAndDisplayOnFullScreen()
        })
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel, handler: { _ in self.dismiss(animated: false)
        })
        
        alertController.addAction(tryAgain)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}
