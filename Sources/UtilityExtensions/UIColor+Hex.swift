import UIKit

public extension UIColor {
    convenience init(hex: Int) {
        let r = CGFloat((hex & 0xFF0000) >> 16) / 0xFF
        let g = CGFloat((hex & 0x00FF00) >>  8) / 0xFF
        let b = CGFloat((hex & 0x0000FF) >>  0) / 0xFF
        
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
    
    convenience init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if hex.hasPrefix("#") { hex.removeFirst() }
        
        if hex.count == 8 {
            let int = Int(hex, radix: 16)!
            let r = CGFloat((int & 0xFF000000) >> 24) / 0xFF
            let g = CGFloat((int & 0x00FF0000) >> 16) / 0xFF
            let b = CGFloat((int & 0x0000FF00) >>  8) / 0xFF
            let a = CGFloat((int & 0x000000FF) >>  0) / 0xFF
            self.init(red: r, green: g, blue: b, alpha: a.rounded(to: 2))
        }
        else if hex.count == 6 {
            self.init(hex: Int(hex, radix: 16)!)
        }
        else {
            // return red color for wrong hex input
            self.init(red: 1, green: 0, blue: 0, alpha: 1)
        }
    }
    
    var rgb: (red: CGFloat, green: CGFloat, blue: CGFloat) {(
        cgColor.components![0],
        cgColor.components![1],
        cgColor.components![2]
    )}
    
    var alpha: CGFloat { cgColor.components![3] }
    
    var hex: String {
        cgColor.components![0..<(alpha < 1 ? 4 : 3)]
            .map { String(format: "%02lX", Int($0 * 255)) }
            .reduce("#", +)
    }
        
    var adaptiveTextColor: UIColor {
        isLightColor ? .black : .white
    }
    
    var isLightColor: Bool {
        let lightRed   = rgb.red   > 0.65
        let lightGreen = rgb.green > 0.65
        let lightBlue  = rgb.blue  > 0.65
        
        let lightness = [lightRed, lightGreen, lightBlue].reduce(0) { $1 ? $0 + 1 : $0 }
        return lightness >= 2
    }
}

extension CGFloat {
    func rounded(to places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}
