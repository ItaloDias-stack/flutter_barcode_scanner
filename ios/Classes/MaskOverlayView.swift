import UIKit

class MaskOverlayView: UIView {

  static var nib: UINib { return UINib(nibName: nibName, bundle: Bundle(for: MaskOverlayView.self)) }
    static var nibName: String { return String(describing: self) }

    var shapeLayer: CAShapeLayer {
        // Avoiding SwiftLint force_cast warning
        guard let shapeLayer = layer as? CAShapeLayer else {
            return CAShapeLayer()
        }
        return shapeLayer
    }

    @IBOutlet weak var pathShapeView: UIView!

    // Override UIView property
    override static var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        if self.pathShapeView != nil {
            let path = CGMutablePath()
            path.addRect(pathShapeView.frame)
            path.addRect(bounds)
            shapeLayer.backgroundColor = UIColor.clear.cgColor
            shapeLayer.fillColor = UIColor.init(red: 41.0/255.0,
                                                green: 41.0/255.0,
                                                blue: 41.0/255.0,
                                                alpha: 0.6).cgColor
            shapeLayer.path = path
            shapeLayer.fillRule = .evenOdd
        }
    }

    func addConstraintEmbed(into view: UIView, with padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        let constraints: [NSLayoutConstraint] = [
            .equalConstraint(item: view, toItem: self, attribute: .bottom, padding: padding.bottom),
            .equalConstraint(item: self, toItem: view, attribute: .top, padding: padding.top),
            .equalConstraint(item: self, toItem: view, attribute: .leading, padding: padding.left),
            .equalConstraint(item: view, toItem: self, attribute: .trailing, padding: padding.right)]
        view.addConstraints(constraints)
    }

    class func newOverlay() -> MaskOverlayView {
        let overlay: MaskOverlayView = self.loadFromNib()
        overlay.pathShapeView.clipsToBounds = true
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return overlay
    }

    static func loadFromNib() -> Self {
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("Unexpected view found in \(nib). Expected \(self)")
        }
        return view
    }
}
extension NSLayoutConstraint {
    static func equalConstraint(item: Any,
                                toItem: Any?,
                                attribute: NSLayoutConstraint.Attribute,
                                multiplier: CGFloat = 1,
                                padding: CGFloat = 0) -> NSLayoutConstraint {
        NSLayoutConstraint(item: item,
                                  attribute: attribute,
                                  relatedBy: .equal,
                                  toItem: toItem,
                                  attribute: attribute,
                                  multiplier: multiplier,
                                  constant: padding)
    }
}
