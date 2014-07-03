//
//  GameTimer.swift
//  SampleWhiteTileGame
//
//  Created by Thahir Maheen on 6/26/14.
//  Copyright (c) 2014 Thahir Maheen. All rights reserved.
//

import UIKit

protocol GameTimerDelegate {
    func observeTimerCompletion(timer : GameTimer, elapsedTime : Double, completion : Double)
}

class GameTimer: NSObject {
    
    // start time for the timer
    var startTime : NSDate

    // total time (seconds) for the timer
    var time : Double?
    
    // game timer delegate
    var gameTimerDelegate : GameTimerDelegate?
    
    // elapsed time
    var elapsedTime : Double {
    get {
        return NSDate.date().timeIntervalSinceDate(startTime)
    }
    }
    
    // completion percentage
    var complete : Double {
    get {
        
        // return 0 if the timer dont have a fixed time
        if !time { return 0.0 }
        
        let completionPercentage = elapsedTime / time!
        
        return completionPercentage > 1 ? 1 : completionPercentage
    }
    }
    
    struct Static {
        static var token : dispatch_once_t = 0
        static var instance : GameTimer?
    }
    
    class var instance: GameTimer {
    dispatch_once(&Static.token) {  Static.instance = GameTimer() }
        return Static.instance!
    }
    
    init() {
        
        // set the start time
        startTime = NSDate.date()
        
        super.init()
    }
    
    convenience init(totalTime : Double, timerDelegate : GameTimerDelegate) {
        self.init()
        
        // set the total time for the timer
        time = totalTime

        // set the delegate
        gameTimerDelegate = timerDelegate
    }
    
    func performClosureAfterDelay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func obsererForCompletion() {
        
        // notify the delegate about the progress
        gameTimerDelegate?.observeTimerCompletion(self, elapsedTime: elapsedTime, completion: complete)

        // if complete we stop observing
        if complete == 1 {
            return
        }
        else {
            
            // we continue observing
            performClosureAfterDelay(1) {
                self.obsererForCompletion()
            }
        }
    }
    
    func startTimer() {
        
        // set the start time
        startTime = NSDate.date()
        
        // observe for completion
        obsererForCompletion()
    }
    
    func stopTimer() {
        time = 0
    }
    
}
