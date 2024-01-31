import UIKit

public extension UIScreen {
    static func scale() -> CGFloat {
        if let activeScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {

            return activeScene.screen.scale
            
        } else {
            return 1
        }
    }
}
