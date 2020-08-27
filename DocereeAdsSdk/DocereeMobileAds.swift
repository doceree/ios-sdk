//
//  DocereeMobileAds.swift
//  iosadslibrarydemo
//
//  Created by dushyant pawar on 29/04/20.
//  Copyright © 2020 dushyant pawar. All rights reserved.
//

import Foundation

public final class DocereeMobileAds{
    
    var baseUrl: URL?
    
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
