//
//  ControllerWaveForm.swift
//  HalfTunes
//
//  Created by SSd on 10/30/16.
//  Copyright © 2016 Ken Toh. All rights reserved.
//

import UIKit

class ControllerWaveForm: UIView,WaveFormMoveProtocol,ButtonMoveProtocol{

    var urlLocal = URL(fileURLWithPath: "")
    
    var mWaveformView : WaveFormView?
    var mTouchDragging : Bool = false
    var mTouchStart : Int = 0
    var mTouchInitialOffset : Int = 0
    var mOffset : Int = 0
    var mMaxPos : Int = 0
    var mStartPos : Int = 0
    var mEndPos : Int = 0
    let buttonWidth : Int = 100
    var mTouchInitialStartPos : Int = 0
    var mTouchInitialEndPos : Int = 0
    var mWidth : Int = 0
    var mOffsetGoal : Int = 0
    var mFlingVelocity : Int = 0
    init(frame: CGRect,mp3Url : URL) {
        urlLocal = mp3Url
        super.init(frame: frame)
        let rectFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        mWidth = Int(frame.size.width)
        mWaveformView = WaveFormView(frame: rectFrame)
        do {
            try mWaveformView?.setFileUrl(url: urlLocal)
        } catch let error as NSError{
            print(error)
        }
//        for _ in 0 ..< 1 {
//            mWaveformView?.zoomIn()
//        }
        mWaveformView?.setProtocol(waveFormProtocolParams: self)
        finishOpeningSoundFile()
        let button = CustomButtom(frame: CGRect(x: 0, y: 100, width: buttonWidth, height: 50),parentViewParam : self,isLeft : true,delegate: self)
        button.backgroundColor = UIColor.green
        button.setTitle("Test Button", for: .normal)
        //button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        let buttonRight = CustomButtom(frame: CGRect(x: Int(frame.size.width-100), y: Int(frame.size.height-100), width: buttonWidth, height: 50),parentViewParam : self,isLeft : false,delegate: self)
        buttonRight.backgroundColor = UIColor.green
        buttonRight.setTitle("Test Button", for: .normal)
        addSubview(mWaveformView!)
        addSubview(buttonRight)
        addSubview(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func finishOpeningSoundFile() {
       
        if let waveFormUnWrap = mWaveformView {
            mMaxPos = waveFormUnWrap.maxPos()
            mTouchDragging = false;
            mOffset = 0;
            mOffsetGoal = 0;
            mFlingVelocity = 0;
            resetPositions();
            updateDisplay();
        }
    }
    // waveForm touch
    func touchesBegan(position : Int){
        mTouchDragging = true
        mTouchStart = position
        mTouchInitialOffset = mOffset
       
    }
    func touchesMoved(position : Int){
        mOffset = trap(pos: Int(mTouchInitialOffset + (mTouchStart - position)));
        updateDisplay()
    }
    func touchesEnded(position : Int){
          print("touchesEnded touch begin")
    }
    // Button touch 
    
    func buttonTouchesBegan(position : Int,isLeft : Bool){
        mTouchDragging = true;
        mTouchStart = position;
        mTouchInitialStartPos = mStartPos;
        mTouchInitialEndPos = mEndPos;
    }
    func buttonTouchesMoved(position : Int,isLeft : Bool){
        let delta = position - mTouchStart;
        if isLeft {
                mStartPos = trap(pos: Int (mTouchInitialStartPos + delta));
               // mEndPos = trap(pos: Int (mTouchInitialEndPos + delta));
                //waveFormView.updateStart(x: Float(position))
        }else {
                mEndPos = trap(pos: Int(mTouchInitialEndPos + delta));
                if mEndPos < mStartPos {
                    mEndPos = mStartPos
                }
                //waveFormView.updateEnd(x: Float(position))
        }
        updateDisplay()

     }
    func buttonTouchesEnded(position : Int,isLeft : Bool){
        //print("buttonTouchesEnded")
        mTouchDragging = false
        if isLeft {
            setOffsetGoalStart()
        }else {
            setOffsetGoalEnd()
        }
        
    }
    
    func trap(pos : Int) -> Int {
        if (pos < 0){
            return 0
        }
        if (pos > mMaxPos ){
            return mMaxPos
        }
        return pos;
    }
    func updateDisplay() {
        var offsetDelta : Int = 0
        if (!mTouchDragging) {
            if (mFlingVelocity != 0) {
                
                
                offsetDelta = mFlingVelocity / 30;
                if (mFlingVelocity > 80) {
                    mFlingVelocity -= 80;
                } else if (mFlingVelocity < -80) {
                    mFlingVelocity += 80;
                } else {
                    mFlingVelocity = 0;
                }
                
                mOffset += offsetDelta;
                
                if (mOffset + mWidth / 2 > mMaxPos) {
                    mOffset = mMaxPos - mWidth / 2;
                    mFlingVelocity = 0;
                }
                if (mOffset < 0) {
                    mOffset = 0;
                    mFlingVelocity = 0;
                }
                mOffsetGoal = mOffset;
            } else {
                offsetDelta = mOffsetGoal - mOffset;
                
                if (offsetDelta > 10){
                    offsetDelta = offsetDelta / 10
                }
                else if (offsetDelta > 0){
                    offsetDelta = 1
                }
                else if (offsetDelta < -10){
                    offsetDelta = offsetDelta / 10
                }
                else if (offsetDelta < 0){
                    offsetDelta = -1
                }
                else{
                    offsetDelta = 0;
                }
                mOffset += offsetDelta;
            }
        }
        
        mOffset += offsetDelta
        if let waveFormUW = mWaveformView {
            waveFormUW.setParameters(start: mStartPos, end: mEndPos, offset: mOffset);
            waveFormUW.setNeedsDisplay()
        }
    }
    
    func setOffsetGoalStart() {
        setOffsetGoal(offset: mStartPos - mWidth / 2)
    }
    
    func setOffsetGoalEnd() {
        setOffsetGoal(offset: mEndPos - mWidth / 2)
    }
    
    func setOffsetGoal(offset : Int) {
        setOffsetGoalNoUpdate(offset: offset);
        updateDisplay()
    }
    func setOffsetGoalNoUpdate(offset : Int) {
        if (mTouchDragging) {
            return;
        }
        
        mOffsetGoal = offset;
        if (mOffsetGoal + mWidth / 2 > mMaxPos){
            mOffsetGoal = mMaxPos - mWidth / 2
        }
        if (mOffsetGoal < 0){
            mOffsetGoal = 0
        }
    }
    func resetPositions() {
        mStartPos = 0;
        mEndPos = mMaxPos;
    }
}







