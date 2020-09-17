//
//  AdsRefreshCountdownTimer.swift
//  DocereeAdsSdk
//
//  Created by dushyant pawar on 15/09/20.
//  Copyright © 2020 Doceree. All rights reserved.
//

import UIKit

class AdsRefreshCountdownTimer {
    
    var timer: Timer?
    var countDown = 30
    
    static let shared = AdsRefreshCountdownTimer()
    
    private init(){
    }
    
    // MARK: Create timer here
    private func createTimer(completion : @escaping() -> Void){
        if timer == nil {
            self.countDown = 30
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ timer in
                timer.tolerance = 0.1
                if self.countDown > 0 {
                    self.countDown -= 1
                } else if self.countDown == 0 {
                    self.resetCountDown()
                    completion()
                }
//                print(self.countDown)
            }
        }
    }
    
    // MARK: Start refresh
    func startRefresh(completion : @escaping() -> Void){
        // create timer here
        createTimer(completion: completion)
    }
    
    // MARK: Stop refresh
    func stopRefresh(){
        // stop timer
        cancelTimer()
    }
    
    // MARK: Cancel the timer
    private func cancelTimer(){
        timer?.invalidate()
        countDown = 0
        timer = nil
    }
    
    @objc func startCountDown(){
        // start countdown
        if countDown > 0{
            countDown -= 1
        } else if countDown == 0{
            resetCountDown()
        }
        print(self.countDown)
    }
    
    func resetCountDown(){
        countDown = 30
    }
}
