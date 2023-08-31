import UIKit

extension CAGradientLayer {
    static func gradientLayer(in frame: CGRect) -> Self {
        let layer = Self()
        layer.colors = colors()
        layer.frame = frame
        return layer
    }
    
    private static func colors() -> [CGColor] {
        let beginColor: CGColor = UIColor(named: "gradientBeginColor")!.cgColor
        let endColor: CGColor = UIColor(named: "gradientEndColor")!.cgColor
        
        return [beginColor, endColor]
    }
}
