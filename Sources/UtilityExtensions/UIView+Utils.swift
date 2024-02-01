import UIKit

public extension UIView {
    private struct AssociatedKeys {
        static var longPressAction = "longPressAction"
        static var tapGestureAction = "tapGestureAction"
        static var longPressHandler = "longPressHandler"
        static var tapGestureHandler = "tapGestureHandler"
    }
    
    private var longPressAction: (() -> Void)? {
        get { getAssociatedObject(key: &AssociatedKeys.longPressAction) }
        set { setAssociatedObject(key: &AssociatedKeys.longPressAction, value: newValue) }
    }
    private var tapGestureAction: (() -> Void)? {
        get { getAssociatedObject(key: &AssociatedKeys.tapGestureAction) }
        set { setAssociatedObject(key: &AssociatedKeys.tapGestureAction, value: newValue) }
    }
    private var longPressHandler: ((UIView) -> Void)? {
        get { getAssociatedObject(key: &AssociatedKeys.longPressHandler) }
        set { setAssociatedObject(key: &AssociatedKeys.longPressHandler, value: newValue) }
    }
    private var tapGestureHandler: ((UIView) -> Void)? {
        get { getAssociatedObject(key: &AssociatedKeys.tapGestureHandler) }
        set { setAssociatedObject(key: &AssociatedKeys.tapGestureHandler, value: newValue) }
    }
}

public extension UIView {
    class func fromNib<T: UIView>() -> T {
        Bundle(for: T.self).loadNibNamed(String(describing: T.self),
                                         owner: nil,
                                         options: nil)![0] as! T
    }
    
    func hidden(_ isHidden: Bool, duration: TimeInterval = 0) {
        if duration == .zero {
            self.isHidden = isHidden
        } else {
            if self.isHidden != isHidden {
                if isHidden {
                    UIView.animate(withDuration: duration) {
                        self.alpha = 0
                    } completion: { _ in
                        self.isHidden = true
                        self.alpha = 1
                    }
                } else {
                    self.alpha = 0
                    self.isHidden = false
                    UIView.animate(withDuration: duration) {
                        self.alpha = 1
                    }
                }
            }
        }
    }
    
    func border(_ color: UIColor, cornerRadius: CGFloat? = nil, width: CGFloat = 1) {
        if let cornerRadius {
            layer.cornerRadius = cornerRadius
        }
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    func blur(_ style: UIBlurEffect.Style = .systemMaterial, intensity: CGFloat = 1.0) {
        let blurredView = VisualEffectView(style: style, intensity: intensity)
        blurredView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(blurredView, at: 0)
        blurredView.fillSuperview()
    }
    
    func shadow(color: UIColor = .black, radius: CGFloat = 5, x: CGFloat = 0, y: CGFloat = 6, opacity: Float = 0.5) {
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOffset = .init(width: x, height: y)
        layer.shadowOpacity = opacity
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )

        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath

        layer.mask = maskLayer
    }
    
    func fillSuperview() {
        guard let superview else { return }
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            topAnchor.constraint(equalTo: superview.topAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }
    
    func hideKeyboardOnTap(force: Bool = false) {
        let tap: UITapGestureRecognizer = .init(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = !force
        self.addGestureRecognizer(tap)
    }
    
    @objc internal func dismissKeyboard() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

// MARK: - Actions
public extension UIView {
    func onTapGesture(_ perform: @escaping () -> Void) {
        isUserInteractionEnabled = true
        tapGestureAction = perform
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecieved)))
    }
    
    func onLongPress(_ perform: @escaping () -> Void) {
        isUserInteractionEnabled = true
        longPressAction = perform
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(lognPressRecieved)))
    }
    
    func onTapGesture(_ perform: @escaping (_ view: UIView) -> Void) {
        isUserInteractionEnabled = true
        tapGestureHandler = perform
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecieved)))
    }
    
    func onLongPress(_ perform: @escaping (_ view: UIView) -> Void) {
        isUserInteractionEnabled = true
        longPressHandler = perform
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(lognPressRecieved)))
    }
    
    @objc func tapGestureRecieved() {
        tapGestureAction?()
        tapGestureHandler?(self)
    }
    
    @objc func lognPressRecieved(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        longPressAction?()
        longPressHandler?(self)
    }
}

// MARK: - Gradient Border
public extension UIView {
    private static let kLayerNameGradientBorder = "GradientBorderLayer"
    
    func setGradientBorder(
        width: CGFloat,
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0, y: 0),
        endPoint: CGPoint = CGPoint(x: 1, y: 0),
        radius: CGFloat
    ) {
        
        guard gradientBorderLayer() == nil else {
            return
        }
        let border = CAGradientLayer()
        border.frame = bounds
        border.colors = colors.map { return $0.cgColor }
        border.startPoint = startPoint
        border.endPoint = endPoint
        border.cornerRadius = radius
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = width
        
        border.mask = mask
        border.name = UIView.kLayerNameGradientBorder
        
        layer.addSublayer(border)
    }
    
    func removeGradientBorder() {
        self.gradientBorderLayer()?.removeFromSuperlayer()
    }
    
    func gradientBorderLayer() -> CAGradientLayer? {
        let borderLayers = layer.sublayers?.filter { return $0.name == UIView.kLayerNameGradientBorder }
        if borderLayers?.count ?? 0 > 1 {
            fatalError()
        }
        return borderLayers?.first as? CAGradientLayer
    }
}

// MARK: - Gradient background
public extension UIView {
    @discardableResult
    func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    @discardableResult
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.cornerRadius = self.bounds.width/2
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.startPoint = .init(x: 0, y: 0.5)
        gradient.endPoint = .init(x: 1, y: 0.5)
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
}

public extension UIView {
    static func safeAreaTopInset() -> CGFloat {
        UIApplication.shared.keyWindow()?.safeAreaInsets.top ?? 0
    }
    
    static func safeAreaBottomInset() -> CGFloat {
        return UIApplication.shared.keyWindow()?.safeAreaInsets.bottom ?? 0
    }
}

public final class VisualEffectView: UIVisualEffectView {
    
    private let theEffect: UIVisualEffect
    private let customIntensity: CGFloat
    private var animator: UIViewPropertyAnimator?
    
    /// Create visual effect view with given effect and its intensity
    ///
    /// - Parameters:
    ///   - effect: visual effect, eg UIBlurEffect(style: .dark)
    ///   - intensity: custom intensity from 0.0 (no effect) to 1.0 (full effect) using linear scale
    public init(style: UIBlurEffect.Style, intensity: CGFloat) {
        theEffect = UIBlurEffect(style: style)
        customIntensity = intensity
        super.init(effect: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { nil }
    
    deinit {
        animator?.stopAnimation(true)
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        effect = nil
        animator?.stopAnimation(true)
        animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear) { [weak self] in
            self?.effect = self?.theEffect
        }
        animator?.fractionComplete = customIntensity
    }
}

