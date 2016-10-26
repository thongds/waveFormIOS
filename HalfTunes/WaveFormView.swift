//
//  WaveFormView.swift
//  HalfTunes
//
//  Created by SSd on 10/26/16.
//  Copyright © 2016 Ken Toh. All rights reserved.
//

import UIKit

class WaveFormView: UIView {

    
    private var caShap : CAShapeLayer
    private var urlLocal = URL(fileURLWithPath: "")
    private  var mSoundFile = CheapMp3()
    override init(frame: CGRect) {
        caShap = CAShapeLayer()
        super.init(frame: frame)
        print("shap size \(frame.size)")
        caShap.bounds = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        caShap.position = CGPoint(x: frame.width/2, y: frame.height/2)
        caShap.backgroundColor = UIColor.red.cgColor
        caShap.strokeColor = UIColor.white.cgColor
        caShap.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(caShap)
        //self.setNeedsDisplay()
    }
    
    func setFileUrl(url:URL)  {
        urlLocal = url
        do{
            print("drawWaveController \(urlLocal)")
            try mSoundFile.ReadFile(url: urlLocal)
            
        }catch let error as NSError{
           print(error)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        var point : CGPoint
        let rectShap = CGRect(x: 0, y: 0, width: caShap.bounds.width, height: caShap.bounds.height)
        let rectPath = UIBezierPath(rect: rectShap)
        
        for i in 0 ..< Int(rectShap.width){
            point = CGPoint(x: i*2, y: 0)
            rectPath.move(to: point)
            point.y = rectShap.height
            rectPath.addLine(to: point)
        }
        caShap.path = rectPath.cgPath
    }
    

}
