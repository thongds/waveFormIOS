//
//  CustomButtom.swift
//  HalfTunes
//
//  Created by SSd on 10/30/16.
//  Copyright © 2016 Ken Toh. All rights reserved.
//

import UIKit

class CustomButtom: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    let parentView : UIView?
    let waveFormView :WaveFormView
    var type : Bool = false
    init(frame: CGRect,parentViewParam : UIView,isLeft : Bool) {
        parentView = parentViewParam
        waveFormView = parentView as! WaveFormView
        type = isLeft
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touche = touches.first {
            let touchStart = touche.location(in: parentView).x
            self.frame.origin.x = touchStart
            if type {
                waveFormView.updateStart(x: Float(touchStart))
            }else {
                waveFormView.updateEnd(x: Float(touchStart))
            }
            print("btn touch \(touchStart)")
        }
    }

}
