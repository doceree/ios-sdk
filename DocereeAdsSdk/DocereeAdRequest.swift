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
    
    internal func requestAd(_ adUnitId: String!, _ size: String!, completion: @escaping(_ results: RestManager.Results, _ isResponseForUS: Bool, _ isRichMediaAd: Bool) -> Void){
        self.adUnitId = adUnitId
        self.size = size
            setUpImage(){ (results, isResponseForUS, isRichMediaAd) in
                completion(results, isResponseForUS, isRichMediaAd)
            }
    }
    
    internal func sendAnalytics(_ slotId: String, _ cbId: String, _ typeOfEvent: TypeOfEvent){
        let restManager = RestManager()
        restManager.sendAnalyticsEvent(typeOfEvent.rawValue, slotId, cbId)
    }
    
    internal func sendImpressionsToAdButler(){
        let restManager = RestManager()
        restManager.sendClickImpressionOnAdButler()
    }
    
    // MARK: Private methods
    private func setUpImage(completion: @escaping(_ results: RestManager.Results, _ isResponseForUS: Bool, _ isRichMediaAd: Bool) -> Void){
        let restManager = RestManager()
        restManager.getImage(self.size!, self.adUnitId!){ (results, isResponseForUS, isRichMediaAd) in
            completion(results, isResponseForUS, isRichMediaAd)
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
    
    let adbSnippet1: String?
    
    let adbSnippet2: String?
    
    let adbSnippet3: String?
    
    let abkw: String?
    
    let height: String?
    
    let width: String?
    
    let setId: String?

    let accountId: String?
    
    let kw: String?
    
    let p1: String?
    
    let p2: String?
    
    let click: String?
    
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
        self.adbSnippet1 = try container.decodeIfPresent(String.self, forKey: .adbSnippet1)
        self.adbSnippet2 = try container.decodeIfPresent(String.self, forKey: .adbSnippet2)
        self.adbSnippet3 = try container.decodeIfPresent(String.self, forKey: .adbSnippet3)
        self.abkw = try container.decodeIfPresent(String.self, forKey: .abkw)
        self.height = try container.decodeIfPresent(String.self, forKey: .height)
        self.width = try container.decodeIfPresent(String.self, forKey: .width)
        self.accountId = try container.decodeIfPresent(String.self, forKey: .accountId)
        self.setId = try container.decodeIfPresent(String.self, forKey: .setId)
        self.kw = try container.decodeIfPresent(String.self, forKey: .kw)
        self.p1 = try container.decodeIfPresent(String.self, forKey: .p1)
        self.p2 = try container.decodeIfPresent(String.self, forKey: .p2)
        self.click = try container.decodeIfPresent(String.self, forKey: .click)
        self.errMessage = try container.decodeIfPresent(String.self, forKey: .errMessage)
    }
    
    internal func isAdbutlerResponse() -> Bool{
        return (adbSnippet1 != nil || adbSnippet2 != nil || adbSnippet3 != nil || abkw != nil || kw != nil || click != nil || accountId != nil || setId != nil)
    }
    
    // MARK: Archiving paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchivingUrl = DocumentsDirectory.appendingPathComponent("platformuid")
}

internal struct ResponseAdButler: Codable{
    let status: ResponseStatus?
    let placements: Placements?
    
    init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decodeIfPresent(ResponseStatus.self, forKey: .status)
        self.placements = try container.decodeIfPresent(Placements.self, forKey: .placements)
    }
    
    internal enum ResponseStatus: String, Codable{
        case SUCCESS = "SUCCESS"
        case NO_ADS = "NO_ADS"
    }
}

internal struct Placements: Codable{
    let placement_1: Placement_1?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.placement_1 = try container.decodeIfPresent(Placement_1.self, forKey: .placement_1)
    }
}

internal struct Placement_1: Codable{
    let banner_id: String?
    let width: String?
    let height: String?
    let alt_text: String?
    let accompanied_html: String?
    let target: String?
    let tracking_pixel: String?
    let body: String?
    let redirect_url: String?
    let refresh_url: String?
    let refresh_time: String?
    let viewable_url: String?
    let eligible_url: String?
    let image_url: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.banner_id = try container.decodeIfPresent(String.self, forKey: .banner_id)
        self.width = try container.decodeIfPresent(String.self, forKey: .width)
        self.height = try container.decodeIfPresent(String.self, forKey: .height)
        self.alt_text = try container.decodeIfPresent(String.self, forKey: .alt_text)
        self.accompanied_html = try container.decodeIfPresent(String.self, forKey: .accompanied_html)
        self.target = try container.decodeIfPresent(String.self, forKey: .target)
        self.tracking_pixel = try container.decodeIfPresent(String.self, forKey: .tracking_pixel)
        self.body = try container.decodeIfPresent(String.self, forKey: .body)
        self.redirect_url = try container.decodeIfPresent(String.self, forKey: .redirect_url)
        self.refresh_url = try container.decodeIfPresent(String.self, forKey: .refresh_url)
        self.refresh_time = try container.decodeIfPresent(String.self, forKey: .refresh_time)
        self.viewable_url = try container.decodeIfPresent(String.self, forKey: .viewable_url)
        self.eligible_url = try container.decodeIfPresent(String.self, forKey: .eligible_url)
        self.image_url = try container.decodeIfPresent(String.self, forKey: .image_url)
    }
}

internal func clearPlatformUid(){
    do {
        try FileManager.default.removeItem(at: AdResponseForPlatform.ArchivingUrl)
    } catch{}
}

internal struct AdResponse: Codable {
    
    let sourceURL: String

    let CBID: String

    let DIVID: String

    let ctaLink: String
}

internal enum TypeOfEvent: String{
       case CPC = "CPC"
       case CPM = "CPM"
}

internal enum Header: String{
    case header_user_agent = "User-Agent"
    case header_advertising_id = "doceree-device-id"
}

internal enum QueryParamsForGetImage: String {
    case id = "id"
    case size = "size"
    case loggedInUser = "loggedInUser"
    case platformType = "platformType"
    case appKey = "appKey"
}
