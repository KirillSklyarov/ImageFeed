import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    
   private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.progress("Pictures are loading", 1.0)
        ProgressHUD.colorProgress = .ypRed
//        ProgressHUD.progress(<#T##text: String?##String?#>, <#T##value: CGFloat##CGFloat#>, interaction: <#T##Bool#>)
    }
    
    
//    let progress = Float(receivedSize) / Float(totalSize)
//                    ProgressHUD.showProgress(progress)
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
