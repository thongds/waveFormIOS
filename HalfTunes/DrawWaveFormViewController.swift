//
//  DrawWaveFormViewController.swift
//  HalfTunes
//
//  Created by SSd on 10/20/16.
//  Copyright © 2016 Ken Toh. All rights reserved.
//

import UIKit

class DrawWaveFormViewController: UIViewController {
    var urlLocal = URL(fileURLWithPath: "")
   
    var waveFormView : WaveFormView?
    
    var viewParent : UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        let rectFrame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
       
        waveFormView = WaveFormView(frame: rectFrame)
        waveFormView?.setFileUrl(url: urlLocal)
        waveFormView?.zoomIn()
        //image?.addSubview(waveFormView!)
        view.addSubview(waveFormView!)
        
//        viewParent = UIView(frame: rectFrame)
//        waveFormView = WaveFormView(frame: rectFrame)
//        viewParent?.addSubview(waveFormView!)
//        view.addSubview(viewParent!)
        

        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear screen height\(view.frame.height)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
