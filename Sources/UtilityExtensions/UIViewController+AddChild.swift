import UIKit

public extension UIViewController {

    /// Utility method to add a `UIViewController` instance to a `UIView`.
    ///
    /// Calls all necessary methods for adding a child view controller and set the constraints
    /// between the views.
    ///
    /// - Parameters:
    ///   - viewController: `UIViewController` instance that will be added to `contentView`.
    ///   - contentView: `UIView` that will add the `childViewController` as its subview.
    func add(childViewController viewController: UIViewController, to contentView: UIView) {
        
        let matchParentConstraints = [
            viewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            viewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]

        addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(viewController.view)
        NSLayoutConstraint.activate(matchParentConstraints)
        viewController.didMove(toParent: self)
    }
}
