import UIKit

public extension UITableViewCell {
    static var identifier: String {
        String(describing: self)
    }

    static var nib: String {
        String(describing: self)
    }
}

