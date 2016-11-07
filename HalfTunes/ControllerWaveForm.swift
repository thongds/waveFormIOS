//
//  ControllerWaveForm.swift
//  HalfTunes
//
//  Created by SSd on 10/30/16.
//  Copyright © 2016 Ken Toh. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
class ControllerWaveForm: UIView{

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
    var playButton : UIButton
    var zoomInButton : UIButton
    var zoomOutButton : UIButton
    var audioPlayer : AVAudioPlayer!
    var mPlayStartOffset : Int = 0
    var audioStatus : AudioStatus = AudioStatus.stopped
    var mPlayStartMsec : Int = 0
    var mTimer : Timer?
    var mediaPlayer:MPMusicPlayerController = MPMusicPlayerController.applicationMusicPlayer()
    
    init(frame: CGRect,mp3Url : URL) {
        
        urlLocal = mp3Url
        let playButtonRect = CGRect(x: frame.size.width/2-50, y: frame.size.height-100, width: 100, height: 100)
        playButton = UIButton(frame: playButtonRect)
        playButton.backgroundColor = UIColor.gray
        playButton.setTitle("play", for: .normal)
        
        let zoomInRect = CGRect(x: 0, y: frame.size.height-100, width: 100, height: 100)
        let zoomOutRect = CGRect(x: frame.size.width-100, y: frame.size.height-100, width: 100, height: 100)
        
        zoomInButton = UIButton(frame: zoomInRect)
        zoomInButton.backgroundColor = UIColor.gray
        zoomInButton.setTitle("+", for: .normal)
        
        zoomOutButton = UIButton(frame: zoomOutRect)
        zoomOutButton.backgroundColor = UIColor.gray
        zoomOutButton.setTitle("-", for: .normal)
        super.init(frame: frame)
        let rectFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height-100)
        mWidth = Int(frame.size.width)
        mWaveformView = WaveFormView(frame: rectFrame,deletgate: self)
        do {
            try mWaveformView?.setFileUrl(url: urlLocal)
        } catch let error as NSError{
            print(error)
        }
        playButton.addTarget(self, action: #selector(self.clickPlay), for: .touchUpInside)
        zoomOutButton.addTarget(self, action: #selector(self.waveformZoomOut), for: .touchUpInside)
        zoomInButton.addTarget(self, action: #selector(self.waveformZoomIn), for: .touchUpInside)
        finishOpeningSoundFile()
        let buttonStart = CustomButtom(frame: CGRect(x: 0, y: 100, width: buttonWidth, height: 50),parentViewParam : self,isLeft : true,delegate: self)
        buttonStart.backgroundColor = UIColor.green
        buttonStart.setTitle("Test Button", for: .normal)
       
        let buttonEnd = CustomButtom(frame: CGRect(x: Int(frame.size.width-100), y: Int(frame.size.height-150), width: buttonWidth, height: 50),parentViewParam : self,isLeft : false,delegate: self)
        buttonEnd.backgroundColor = UIColor.green
        buttonEnd.setTitle("Test Button", for: .normal)
        addSubview(mWaveformView!)
        addSubview(buttonEnd)
        addSubview(buttonStart)
        addSubview(playButton)
        addSubview(zoomInButton)
        addSubview(zoomOutButton)
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
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: urlLocal)
            audioPlayer.delegate = self
            
        } catch let error as NSError {
            print(error)
        }
    }
    func waveformZoomIn(){
        mWaveformView?.zoomIn();
        mStartPos = (mWaveformView?.getStart())!;
        mEndPos = (mWaveformView?.getEnd())!;
        mMaxPos = (mWaveformView?.maxPos())!;
        mOffset = (mWaveformView?.getOffset())!;
        mOffsetGoal = mOffset;
        updateDisplay();
        
    }
    func  waveformZoomOut() {
        mWaveformView?.zoomOut();
        mStartPos = (mWaveformView?.getStart())!;
        mEndPos = (mWaveformView?.getEnd())!;
        mMaxPos = (mWaveformView?.maxPos())!;
        mOffset = (mWaveformView?.getOffset())!;
        mOffsetGoal = mOffset;
        updateDisplay();
    }
    func clickPlay(){
        onPlay(startPosition: mStartPos)
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
    func onPlay(startPosition : Int){
        print("OnPlay startPos \(startPosition)")
        
        if isPlaying() {
            if let audioPlayerUW = audioPlayer {
                audioPlayerUW.pause()
                mTimer?.invalidate()
                mTimer = nil
                updateButton()
            }
            return
        }
        mPlayStartMsec = mWaveformView!.pixelsToMillisecs(pixels: startPosition)
        print("mPlayStartMsec \(mPlayStartMsec)")
        if let audioPlayerUW = audioPlayer {
            audioPlayerUW.currentTime = TimeInterval(exactly: Float(mPlayStartMsec)/1000)!
            audioPlayerUW.play()
           // audioPlayerUW.play(atTime: TimeInterval(1))
        }
        updateButton()
        mTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateDisplay), userInfo: nil, repeats: true)
        mTimer?.fire()
    }
    func updateButton(){
        if isPlaying() {
            playButton.setTitle("pause", for: .normal)
        }else {
            playButton.setTitle("play", for: .normal)
        }
    }
    func updateDisplay() {
        if isPlaying() {
            let now : Int = Int(round(Double(audioPlayer.currentTime)*1000) + Double(mPlayStartOffset))
            let frames : Int = mWaveformView!.millisecsToPixels(msecs: now)
            mWaveformView?.setPlayback(pos: frames)
            setOffsetGoalNoUpdate(offset: frames - mWidth / 2)
        }
        
        var offsetDelta : Int = 0
        
        if (!mTouchDragging) {
            if (mFlingVelocity != 0) {
                offsetDelta = mFlingVelocity / 30
                if (mFlingVelocity > 80) {
                    mFlingVelocity -= 80
                } else if (mFlingVelocity < -80) {
                    mFlingVelocity += 80
                } else {
                    mFlingVelocity = 0
                }
                
                mOffset += offsetDelta;
                
                if (mOffset + mWidth / 2 > mMaxPos) {
                    mOffset = mMaxPos - mWidth / 2
                    mFlingVelocity = 0
                }
                if (mOffset < 0) {
                    mOffset = 0;
                    mFlingVelocity = 0
                }
                mOffsetGoal = mOffset
            } else {
                offsetDelta = mOffsetGoal - mOffset
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
                    offsetDelta = 0
                }
                mOffset += offsetDelta
              
            }
        }
        
        if let waveFormUW = mWaveformView {
            waveFormUW.setParameters(start: mStartPos, end: mEndPos, offset: mOffset)
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
    // Play state
    func pause(){
        if let audioPlayerUW = audioPlayer {
            audioPlayerUW.pause()
        }
    }
    func isPlaying() -> Bool {
        if let audioPlayerUW = audioPlayer {
            if audioPlayerUW.isPlaying {
                return true
            }
            return false
        }
        return false
    }
    
}
extension ControllerWaveForm : AVAudioPlayerDelegate {
   
}
extension ControllerWaveForm : WaveFormMoveProtocol {
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
   
}

extension ControllerWaveForm : ButtonMoveProtocol{
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
            print("startPos result \(mStartPos)")
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

}




