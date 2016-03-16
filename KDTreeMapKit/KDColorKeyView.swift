//
//  KDColorKeyView.swift
//  KDTreeMapKit
//
//  Created by brendan kerr on 3/13/16.
//  Copyright © 2016 b3k3r. All rights reserved.
//

import UIKit

class KDColorKeyView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let gradient = CAGradientLayer()
        
        let color1 = UIColor(red: 255.0, green: 0.0, blue: 0.0, alpha: 1.0).CGColor
        let color2 = UIColor(red: 0.0, green: 0.0, blue: 255.0, alpha: 1.0).CGColor
        gradient.colors = [color1, color2]
        
        self.layer.addSublayer(gradient)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        
        let color1 = UIColor(red: 0.0, green: 0.0, blue: 255.0, alpha: 1.0).CGColor as CGColorRef
        let color2 = UIColor(red: 0.0, green: 255.0, blue: 255.0, alpha: 1.0).CGColor as CGColorRef
        gradient.colors = [color1, color2]
        
        self.layer.addSublayer(gradient)
    }
    

}
