import UIKit

public extension UIDevice {
    static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
