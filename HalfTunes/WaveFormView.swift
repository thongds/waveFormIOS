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
    var mSampleRate: Int?
    var mSamplesPerFrame: Int?
    var minGain : Float = 0
    var range: Float = 0
    var  mNumZoomLevels : Int = 0
    var  mLenByZoomLevel : [Int]
    var  mZoomFactorByZoomLevel: [Float]
    var scaleFactor : Float = 1
    var mFrame : CGRect?
    var mZoomLevel : Int = 0
    var mInitialized : Bool = false
    override init(frame: CGRect) {
        caShap = CAShapeLayer()
        mLenByZoomLevel = Array(repeatElement(0, count: 4))
        mZoomFactorByZoomLevel = Array(repeating: 0, count: 4)
        super.init(frame: frame)
        mFrame = frame
        caShap.bounds = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        caShap.position = CGPoint(x: frame.width/2, y: frame.height/2)
        caShap.backgroundColor = UIColor.red.cgColor
        caShap.strokeColor = UIColor.white.cgColor
        caShap.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(caShap)
        //self.setNeedsDisplay()
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
        let start : Int = 0
        let ctr = Int(rectShap.height/2)
        if mInitialized{
            for i in 0 ..< Int(rectShap.width){
                let floatData : Float = mZoomFactorByZoomLevel[mZoomLevel]
                let h : Int  = (Int) (getScaledHeight(zoomLevel: floatData , i: start + i) * Float(getMeasuredHeight() / 2));
               
                let y0 = ctr - h
                let y1 = ctr + 1 + h
                point = CGPoint(x: i, y: y0)
                rectPath.move(to: point)
                point.y = CGFloat(y1)
                rectPath.addLine(to: point)
            }
            caShap.path = rectPath.cgPath
        }
    }

    func setFileUrl(url:URL)  {
        urlLocal = url
        do{
            print("drawWaveController \(urlLocal)")
            try mSoundFile.ReadFile(url: urlLocal)
            mSampleRate = mSoundFile.getSampleRate();
            mSamplesPerFrame = mSoundFile.getSamplesPerFrame();
            print("sampleRate \(mSampleRate), samplePerFrame \(mSamplesPerFrame)")
            
            computeDoublesForAllZoomLevels();
        }catch let error as NSError{
           print(error)
        }
    }
    func computeDoublesForAllZoomLevels(){
        let numFrames = mSoundFile.getNumFrames();
        
        // Make sure the range is no more than 0 - 255
        var maxGain : Float = 1.0
        for i in 0 ..< numFrames {
            let gain = getGain( i: i, numFrames: numFrames, frameGains: mSoundFile.getFrameGains())
            if (gain > maxGain) {
                maxGain = gain
            }
        }
        
        scaleFactor = 1
        if (maxGain > 255.0) {
            scaleFactor = 255 / maxGain
        }
        
        // Build histogram of 256 bins and figure out the new scaled max
        maxGain = 0;
        //int gainHist[] = new int[256]
        var gainHist : [Int]
        gainHist = Array(repeating: 0, count: 256)
        
        for i in 0 ..< numFrames {
            
            var smoothedGain : Int = Int(getGain(i: i, numFrames: numFrames, frameGains: mSoundFile.getFrameGains()) * scaleFactor)
            if (smoothedGain < 0){
                smoothedGain = 0
            }
            if (smoothedGain > 255){
                smoothedGain = 255
            }
            if (Float(smoothedGain) > maxGain){
                maxGain = Float(smoothedGain)
            }
            
            gainHist[smoothedGain] += 1;
            
        }
        
        
        // Re-calibrate the min to be 5%
        minGain = 0
        var sum : Int = 0
        while (minGain < Float(255) && sum < numFrames / 20) {
            sum += gainHist[Int(minGain)];
            minGain+=1;
        }
        
        // Re-calibrate the max to be 99%
        sum = 0;
        while (maxGain > 2 && sum < numFrames / 100) {
            sum += gainHist[Int(maxGain)]
            maxGain-=1;
        }
        
        range = maxGain - minGain;
        
        mNumZoomLevels = 4;
        mLenByZoomLevel = Array(repeatElement(0, count: 4))
        mZoomFactorByZoomLevel = Array(repeating: 0, count: 4)
        
        let ratio : Float = Float(getMeasuredWidth()) / Float(numFrames)
        
        if (ratio < 1) {
            mLenByZoomLevel[0]  = Int(round(Float(numFrames) * ratio))
            
            mZoomFactorByZoomLevel[0] = ratio
            
            mLenByZoomLevel[1] = numFrames
            mZoomFactorByZoomLevel[1] = 1
            
            mLenByZoomLevel[2] = numFrames * 2
            mZoomFactorByZoomLevel[2] = 2
            
            mLenByZoomLevel[3] = numFrames * 3
            mZoomFactorByZoomLevel[3] = 3.0
            
            mZoomLevel = 0;
        } else {
            mLenByZoomLevel[0] = numFrames
            mZoomFactorByZoomLevel[0] = 1
            
            mLenByZoomLevel[1] = numFrames * 2
            mZoomFactorByZoomLevel[1] = 2
            
            mLenByZoomLevel[2] = numFrames * 3
            mZoomFactorByZoomLevel[2] = 3
            
            mLenByZoomLevel[3] = numFrames * 4
            mZoomFactorByZoomLevel[3] = 4
            
            mZoomLevel = 0;
            for i in 0 ..< 4 {
                if (mLenByZoomLevel[mZoomLevel] - getMeasuredWidth() > 0) {
                    break;
                } else {
                    mZoomLevel = i;
                }
            }
        }
        
        mInitialized = true;
    }
    
    func getGain(i : Int, numFrames : Int, frameGains : [Int]) -> Float {
        let x : Int = min(i, numFrames - 1);
        if (numFrames < 2) {
            return Float(frameGains[x]);
        } else {
            if (x == 0) {
                return (Float(frameGains[0]) / 2) + (Float(frameGains[1]) / 2)
            } else if (x == numFrames - 1) {
                return (Float(frameGains[numFrames - 2]) / 2) + ( Float(frameGains[numFrames - 1]) / 2)
            } else {
                return (Float(frameGains[x - 1]) / 3) + (Float(frameGains[x]) / 3) + (Float(frameGains[x + 1]) / 3)
            }
        }
    }
    
    func getMeasuredWidth()-> Int {
        if let frame = mFrame{
            return Int(frame.width)
        }else{
            return 0
        }
    }
    
    func getMeasuredHeight() -> Int {
        if let frame = mFrame{
            return Int(frame.height)
        }else{
            return 0
        }

    }
    
    func getScaledHeight(zoomLevel : Float, i : Int) -> Float {
        
        if (zoomLevel == 1.0) {
            return getNormalHeight(i: i)
        } else if (zoomLevel < 1.0) {
            return getZoomedOutHeight(zoomLevel: zoomLevel, i: i);
        }
        return getZoomedInHeight(zoomLevel: zoomLevel, i: i);
    }
    
    func getNormalHeight(i : Int) -> Float {
         return getHeight(i: i, numFrames: mSoundFile.getNumFrames(), frameGains: mSoundFile.getFrameGains(), scaleFactor: scaleFactor, minGain: minGain, range: range);
    }
    
    func getHeight(i : Int,numFrames : Int, frameGains : [Int],scaleFactor : Float,minGain : Float,range : Float) -> Float {
        var value : Float = (getGain(i: i, numFrames: numFrames, frameGains: frameGains) * scaleFactor - minGain) / range;
        print("value: \(value)")
        if (value < 0.0){
            value = 0
        }
        if (value > 1.0){
            value = 1
        }
        return value;
    }
    
    func getZoomedOutHeight(zoomLevel : Float,i: Int) -> Float {
        let f = Int(Float(i) / zoomLevel)
        let x1 = getHeight(i: f, numFrames: mSoundFile.getNumFrames(), frameGains: mSoundFile.getFrameGains(), scaleFactor: scaleFactor, minGain: minGain, range: range);
        let x2 = getHeight(i: f + 1, numFrames: mSoundFile.getNumFrames(), frameGains: mSoundFile.getFrameGains(), scaleFactor: scaleFactor, minGain: minGain, range: range);
        return 0.5 * (x1 + x2);
    }
    func getZoomedInHeight(zoomLevel : Float, i: Int) -> Float {
        let f =  Int(zoomLevel)
        if (i == 0) {
            return 0.5 * getHeight(i: 0, numFrames: mSoundFile.getNumFrames(), frameGains: mSoundFile.getFrameGains(), scaleFactor: scaleFactor, minGain: minGain, range: range);
        }
        if (i == 1) {
            return getHeight(i: 0, numFrames: mSoundFile.getNumFrames(), frameGains: mSoundFile.getFrameGains(), scaleFactor: scaleFactor, minGain: minGain, range: range);
        }
        if (i % f == 0) {
            let x1 = getHeight(i: i / f - 1, numFrames: mSoundFile.getNumFrames(), frameGains: mSoundFile.getFrameGains(), scaleFactor: scaleFactor, minGain: minGain, range: range);
            let x2 = getHeight(i: i / f, numFrames: mSoundFile.getNumFrames(), frameGains: mSoundFile.getFrameGains(), scaleFactor: scaleFactor, minGain: minGain, range: range);
            return 0.5 * (x1 + x2);
        } else if ((i - 1) % f == 0) {
            return getHeight(i: (i - 1) / f, numFrames: mSoundFile.getNumFrames(), frameGains: mSoundFile.getFrameGains(), scaleFactor: scaleFactor, minGain: minGain, range: range);
        }
        return 0;

    }
    
}
