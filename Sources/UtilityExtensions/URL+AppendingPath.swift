import Foundation

public extension URL {
    func appending(_ pathComponent: String) -> URL {
        if #available(iOS 16.0, *) {
            return appending(component: pathComponent)
        } else {
            return appendingPathComponent(pathComponent)
        }
    }
}
