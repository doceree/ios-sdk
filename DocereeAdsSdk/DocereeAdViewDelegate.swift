//
//  AdEvents.swift
//  iosadslibrarydemo
//
//  Created by dushyant pawar on 01/05/20.
//  Copyright © 2020 dushyant pawar. All rights reserved.
//

import Foundation
import UIKit

public protocol DocereeAdViewDelegate{
    func docereeAdViewDidReceiveAd(_ docereeAdView: DocereeAdView)
    func docereeAdView(_ docereeAdView: DocereeAdView,
                       didFailToReceiveAdWithError error: DocereeAdRequestError)
    func docereeAdViewWillPresentScreen(_ docereeAdView: DocereeAdView)
    func docereeAdViewWillDismissScreen(_ docereeAdView: DocereeAdView)
    func docereeAdViewDidDismissScreen(_ docereeAdView: DocereeAdView)
    func docereeAdViewWillLeaveApplication(_ docereeAdView: DocereeAdView)
}

public extension DocereeAdViewDelegate{
    func docereeAdViewDidReceiveAd(_ docereeAdView: DocereeAdView) {}
    func docereeAdView(_ docereeAdView: DocereeAdView,
                       didFailToReceiveAdWithError error: DocereeAdRequestError) {}
    func docereeAdViewWillPresentScreen(_ docereeAdView: DocereeAdView) {}
    func docereeAdViewWillDismissScreen(_ docereeAdView: DocereeAdView) {}
    func docereeAdViewDidDismissScreen(_ docereeAdView: DocereeAdView) {}
    func docereeAdViewWillLeaveApplication(_ docereeAdView: DocereeAdView) {}
}
