//
//  UIApplication+KeyWindow.swift
//
//
//  Created by Anton Chuev on 01.02.2024.
//

import UIKit

public extension UIApplication {
    func keyWindow() -> UIWindow? {
        if let activeScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {

            return activeScene.keyWindow
            
        } else {
            return nil
        }
    }
}
