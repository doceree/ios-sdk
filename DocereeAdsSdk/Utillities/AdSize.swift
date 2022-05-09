//
//  AdSize.swift
//  iosadslibrarydemo
//
//  Created by dushyant pawar on 20/04/20.
//  Copyright © 2020 dushyant pawar. All rights reserved.
//

import Foundation
import UIKit

public protocol AdSize {
    var height: CGFloat { set get }
    var width: CGFloat {set get}
    func getAdSize() -> CGSize
    func getAdSizeName() -> String
}

// 320 x 50
struct Banner: AdSize {
    var width: CGFloat = 320.0
    
    var height: CGFloat = 50.0
    
    func getAdSize() -> CGSize {
        return CGSize(width: width, height: height)
    }
    
    func getAdSizeName() -> String {
        return "BANNER"
    }
}

// 468 x 60
struct FullBanner: AdSize {

    var height: CGFloat = 60.0
    
    var width: CGFloat = 468.0
    
    func getAdSize() -> CGSize {
        return CGSize(width: width, height: height)
    }
    
    func getAdSizeName() -> String {
        return "FULLBANNER"
    }
}

// 300 x 250
struct MediumRectangle : AdSize {
    
    var height: CGFloat = 250.0
    
    var width: CGFloat = 300.0
    
    func getAdSize() -> CGSize {
        return CGSize(width: width, height: height)
    }
    
    func getAdSizeName() -> String {
        return "MEDIUMRECTANGLE"
    }
}

// 320 x 100
struct LargeBanner: AdSize {
    
    var height: CGFloat = 100.0
    
    var width: CGFloat = 320.0
    
    func getAdSize() -> CGSize {
        return CGSize(width: width, height: height)
    }
    
    func getAdSizeName() -> String {
        return "LARGEBANNER"
    }
}

// 728 x 90
struct LeaderBoard: AdSize {
    
    var height: CGFloat = 90.0
    
    var width: CGFloat = 728.0
    
    func getAdSize() -> CGSize {
        return CGSize(width: width, height: height)
    }
    
    func getAdSizeName() -> String {
        return "LEADERBOARD"
    }
}

// 300 x 50
struct SmallBanner: AdSize {
    
    var height: CGFloat = 50.0
    
    var width: CGFloat = 300.0
    
    func getAdSize() -> CGSize {
        return CGSize(width: width, height: height)
    }
    
    func getAdSizeName() -> String {
        return "SMALLBANNER"
    }
}

// Invalid Size
struct Invalid: AdSize {
    var height: CGFloat = 0.0
    
    var width: CGFloat = 0.0
    
    func getAdSize() -> CGSize {
        return .zero
    }
    
    func getAdSizeName() -> String {
        return "INVALID"
    }
}
