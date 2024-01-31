import UIKit

public extension UINavigationController {
    func topController<T: UIViewController>(isOf type: T.Type) -> Bool {
        
        guard let topController = topViewController else {
            return false
        }
        
        return topController.isKind(of: type)
    }
}
