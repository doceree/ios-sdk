//
//  DocereeMobileAds.swift
//  iosadslibrarydemo
//
//  Created by dushyant pawar on 29/04/20.
//  Copyright © 2020 dushyant pawar. All rights reserved.
//

import Foundation
import AppTrackingTransparency
import AdSupport
import OSLog

public final class DocereeMobileAds{
    
    var baseUrl: URL?
    internal static var trackingStatus: String?
    
    private static var sharedNetworkManager: DocereeMobileAds = {
        var docereeMobileAds = DocereeMobileAds(baseUrl: Api.baseURL)
        return docereeMobileAds
    }()
    
    private init(baseUrl: URL?){
        self.baseUrl = baseUrl
    }
    
    public static func login(with hcp: Hcp){
        NSKeyedArchiver.archiveRootObject(hcp, toFile: Hcp.ArchivingUrl.path)
//        DataController.shared.save(hcp: hcp)
    }
    
    public class func shared() -> DocereeMobileAds{
        return sharedNetworkManager
    }
    
    public typealias CompletionHandler = ((_ completionStatus:Any?) -> Void)?
    
    public func start(completionHandler: CompletionHandler){

        let obj: Any? = CompletionStatus.Loading
        (obj)
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization{ (status) in
                switch status{
                case .authorized:
                    DocereeMobileAds.trackingStatus = "authorized"
                    os_log("authorized", log: .default, type: .error)
                case .denied:
                    DocereeMobileAds.trackingStatus = "denied"
                    os_log("denied", log: .default, type: .error)
                    return
                case .notDetermined:
                    DocereeMobileAds.trackingStatus = "not determined"
                    os_log("not determined", log: .default, type: .error)
                    return
                case .restricted:
                    DocereeMobileAds.trackingStatus = "restricted"
                    os_log("restricted", log: .default, type: .error)
                    return
                @unknown default:
                    DocereeMobileAds.trackingStatus = "Unknown error"
                    os_log("Unknown error", log: .default, type: .error)
                    return
                }
            }
        }
    }
    
    public static func clearUserData(){
        do {
            try FileManager.default.removeItem(at: Hcp.ArchivingUrl)
            try FileManager.default.removeItem(at: AdResponseForPlatform.ArchivingUrl)
        } catch {}
    }
    
    internal enum CompletionStatus: Any{
        case Success
        case Failure
        case Loading
    }
}
