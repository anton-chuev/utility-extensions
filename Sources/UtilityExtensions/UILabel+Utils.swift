import UIKit

public extension UILabel {
    convenience init(font: UIFont? = nil,
                     title: String? = nil,
                     color: UIColor = .black,
                     alignment: NSTextAlignment = .natural,
                     lines: Int = 1) {
        self.init()
        self.font = font
        self.text = title
        self.textColor = color
        self.textAlignment = alignment
        self.numberOfLines = lines
    }
}


