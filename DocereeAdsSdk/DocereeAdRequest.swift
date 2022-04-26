//
//  DocereeAdRequest.swift
//  iosadslibrarydemo
//
//  Created by dushyant pawar on 29/04/20.
//  Copyright © 2020 dushyant pawar. All rights reserved.
//

import Foundation
import UIKit

public final class DocereeAdRequest{
    
    private var size: String?
    private var adUnitId: String?
    private var cbId: String?
    
    // todo: create a queue of requests and inititate request
    public init() {
        queue = OperationQueue()
    }
    
    // MARK: Properties
    private var queue: OperationQueue
    private var isPlatformUidPresent: Bool = false
    
    // MARK: Public methods
    //    public func requestAd() -> UIImage?{
    //        let image = setUpImage() as UIImage?
    //        return image
    //    }
    
    internal func requestAd(_ adUnitId: String!, _ size: String!, completion: @escaping(_ results: RestManager.Results,
        _ isRichMediaAd: Bool) -> Void){
        self.adUnitId = adUnitId
        self.size = size
            setUpImage(){ (results, isRichMediaAd) in
                completion(results, isRichMediaAd)
            }
    }
    
    internal func sendImpression(impressionUrl: String){
        let restManager = RestManager()
        restManager.sendAdImpression(impressionUrl: impressionUrl)
    }
    
    // MARK: Private methods
    private func setUpImage(completion: @escaping(_ results: RestManager.Results, _ isRichMediaAd: Bool) -> Void){
        let restManager = RestManager()
        restManager.getImage(self.size!, self.adUnitId!){ (results, isRichMediaAd) in
            completion(results, isRichMediaAd)
        }
    }
}
