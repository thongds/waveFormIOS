//
//  ControllerWaveForm.swift
//  HalfTunes
//
//  Created by SSd on 10/30/16.
//  Copyright © 2016 Ken Toh. All rights reserved.
//

import UIKit

class ControllerWaveForm: UIView {

    var urlLocal = URL(fileURLWithPath: "")
    
    var waveFormView : WaveFormView?

    init(frame: CGRect,mp3Url : URL) {
        urlLocal = mp3Url
        super.init(frame: frame)
        let rectFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        waveFormView = WaveFormView(frame: rectFrame)
        waveFormView?.setFileUrl(url: urlLocal)
        for _ in 0 ..< 1 {
            waveFormView?.zoomIn()
        }
       
        addSubview(waveFormView!)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
