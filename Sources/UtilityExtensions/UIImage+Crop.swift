import UIKit

public extension UIImage {
    func crop(toRect rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }

        let croppedCGImage = cgImage.cropping(to: rect)
        let croppedImage = UIImage(cgImage: croppedCGImage!, scale: 1.0, orientation: self.imageOrientation)

        return croppedImage
    }
}
