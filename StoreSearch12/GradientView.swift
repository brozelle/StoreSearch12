//
//  GradientView.swift
//  StoreSearch12
//
//  Created by Buck Rozelle on 12/26/20.
//

import UIKit

class GradientView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        //Determine color used based on appearance.
        let traits = UITraitCollection.current
        let color: CGFloat = traits.userInterfaceStyle == .light ? 0.314 : 1
        
        //Create two arrays that define how gradient is drawn.
        let components: [CGFloat] = [color, color, color, 0.2,
                                     color, color, color, 0.4,
                                     color, color, color, 0.6,
                                     color, color, color, 1]
        
        let locations: [CGFloat] = [ 0, 0.5, 0.75, 1]
        
        //Creates the gradient object.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace,
                                  colorComponents: components,
                                  locations: locations,
                                  count: 4)
        //Figure out how big to draw the gradient object
        let x = bounds.midX
        let y = bounds.midY
        let centerpoint = CGPoint(x: x, y: y)
        let radius = max(x, y)
        
        //Draw the object
        let context = UIGraphicsGetCurrentContext()
        context?.drawRadialGradient(gradient!,
                                    startCenter: centerpoint,
                                    startRadius: 0,
                                    endCenter: centerpoint,
                                    endRadius: radius,
                                    options: .drawsAfterEndLocation)
    }
}
