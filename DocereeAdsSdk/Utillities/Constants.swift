//
//  Constants.swift
//  DocereeAdsSdk
//
//  Created by Muqeem.Ahmad on 26/04/22.
//  Copyright © 2022 Doceree. All rights reserved.
//

import Foundation

enum AdType {
    case BANNER
    case FULLSIZE
    case MEDIUMRECTANGLE
    case LEADERBOARD
    case LARGEBANNER
    case INVALID
}

enum BlockLevel {
    case AdCoveringContent
    case AdWasInappropriate
    case NotInterestedInCampaign
    case NotInterestedInBrand
    case NotInterestedInBrandType
    case NotInterestedInClientType
    
    var info: (blockLevelCode: String, blockLevelDesc: String){
        switch self{
        case .AdCoveringContent:
            return ("overlappingAd", "Ad is covering the content of the website.")
        case .AdWasInappropriate:
            return ("inappropriateAd", "Ad was inappropriate.")
        case .NotInterestedInCampaign:
            return ("notInterestedInCampaign", "I'm not interested in seeing ads for this product")
        case .NotInterestedInBrand:
            return ("notInterestedInBrand", "I'm not interested in seeing ads for this brand.")
        case .NotInterestedInBrandType:
            return ("notInterestedInBrandType", "I'm not interested in seeing ads for this category.")
        case .NotInterestedInClientType:
            return ("notInterestedInClientType", "I'm not interested in seeing ads from pharmaceutical brands.")
        }
    }
}

enum ConsentType {
    case consentType2
    case consentType3
}
