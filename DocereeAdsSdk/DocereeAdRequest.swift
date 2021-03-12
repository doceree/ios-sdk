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

extension String{
    func trim() -> String{
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

internal struct AdResponseForPlatform: Codable {
    let sourceURL: String?
    
    let CBID: String?
    
    let DIVID: String?
    
    let ctaLink: String?
    
    let newPlatformUid: String?
    
    let height: String?
    
    let width: String?
    
    let platformUID: String?

    let debugMessage: String?
    
    let version: String?
    
    let maxAge: Int?
    
    let passbackTag: String?
    
    let impressionLink: String?
    
    let IntegrationType: String?
    
    let creativeType: String?
    
    let errMessage: String?
    
    enum Platformuid: String{
        case platformuid = "platformuid"
    }
    
    init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sourceURL = try container.decodeIfPresent(String.self, forKey: .sourceURL)
        self.CBID = try container.decodeIfPresent(String.self, forKey: .CBID)
        self.DIVID = try container.decodeIfPresent(String.self, forKey: .DIVID)
        self.ctaLink = try container.decodeIfPresent(String.self, forKey: .ctaLink)
        self.newPlatformUid = try container.decodeIfPresent(String.self, forKey: .newPlatformUid)
        self.height = try container.decodeIfPresent(String.self, forKey: .height)
        self.width = try container.decodeIfPresent(String.self, forKey: .width)
        self.platformUID = try container.decodeIfPresent(String.self, forKey: .platformUID)
        self.debugMessage = try container.decodeIfPresent(String.self, forKey: .debugMessage)
        self.version = try container.decodeIfPresent(String.self, forKey: .version)
        self.maxAge = try container.decodeIfPresent(Int.self, forKey: .maxAge)
        self.passbackTag = try container.decodeIfPresent(String.self, forKey: .passbackTag)
        self.impressionLink = try container.decodeIfPresent(String.self, forKey: .impressionLink)
        self.IntegrationType = try container.decodeIfPresent(String.self, forKey: .IntegrationType)
        self.creativeType = try container.decodeIfPresent(String.self, forKey: .creativeType)
        self.errMessage = try container.decodeIfPresent(String.self, forKey: .errMessage)
    }
    
    internal func isAdRichMedia() -> Bool{
        let givenType = self.creativeType
        let html = "html"
        let custom_html = "custom_html"
        let text_ad = "text_ad"
        return compareIfSame(presentValue: givenType!, expectedValue: html) || compareIfSame(presentValue: givenType!, expectedValue: custom_html) || compareIfSame(presentValue: givenType!, expectedValue: text_ad)
    }

    internal func compareIfSame(presentValue: String, expectedValue: String) -> Bool{
        return presentValue.caseInsensitiveCompare(expectedValue) == ComparisonResult.orderedSame
    }
    
    // MARK: Archiving paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchivingUrl = DocumentsDirectory.appendingPathComponent("platformuid")
}

internal func clearPlatformUid(){
    do {
        try FileManager.default.removeItem(at: AdResponseForPlatform.ArchivingUrl)
    } catch{}
}

internal enum TypeOfEvent: String{
       case CPC = "CPC"
       case CPM = "CPM"
}

internal enum Header: String{
    case header_user_agent = "User-Agent"
    case header_advertising_id = "doceree-device-id"
    case is_vendor_id = "is_doceree_iOS_sdk_vendor_id"
    case header_is_ad_tracking_enabled = "is-ad-tracking-enabled"
    case header_app_name = "app-name"
    case header_app_version = "app-version"
    case header_lib_version = "lib-version"
    case header_app_bundle = "app-bundle"
}

internal enum QueryParamsForGetImage: String {
    case id = "id"
    case size = "size"
    case loggedInUser = "loggedInUser"
    case platformType = "platformType"
    case appKey = "appKey"
}

internal enum AdBlockService: String{
    case advertiserCampID = "advertiserCampID"
    case publisherACSID = "publisherACSID"
    case blockLevel = "blockLevel"
    case platformUid = "platformUid"
}
