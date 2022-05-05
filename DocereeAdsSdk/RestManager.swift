//
//  RestManager.swift
//  iosadslibrary
//
//  Created by dushyant pawar on 23/04/20.
//  Copyright © 2020 dushyant pawar. All rights reserved.
//
import Foundation
import UIKit
import os.log
#if canImport(AdSupport) && canImport(AppTrackingTransparency)
import AdSupport
import AppTrackingTransparency
#endif
import AdSupport
import Combine

public final class RestManager{
    // MARK: Properties
    var loggingEnabled: Bool = false
    var isPlatformUidPresent: Bool = false
    var isVendorId: Bool = false
    
    private let addsWebRepo: AdWebRepoProtocol = AdWebRepo()
    private var disposables = Set<AnyCancellable>()
                
    // MARK: Method for fetching data
    internal func getData(fromURL url: URL, completion: @escaping(_ data: Data?) -> Void){
        DispatchQueue.global(qos: .userInitiated).async {
            let sessionConfiguration = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfiguration)
            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
                guard let data = data else{ completion(nil); return }
                completion(data)
            })
            task.resume()
        }
    }
    
    internal func getImage(_ size: String!, _ slotId: String!, completion: @escaping(_ results: Results, _ isRichmedia: Bool) -> Void){
        
        guard let appKey = Bundle.main.object(forInfoDictionaryKey: "DocereeAdsIdentifier") as? String else {
            if #available(iOS 10.0, *) {
                os_log("Error: Missing DocereeIdentifier key!", log: .default, type: .error)
            } else {
                // Fallback on earlier versions
                print("Error: Missing DocereeIdentifier key!")
            }
            return
        }
        
        var advertisementId: String?
        advertisementId = getIdentifierForAdvertising()
        if (advertisementId == nil) {
            if #available(iOS 10.0, *) {
                os_log("Error: Ad Tracking is disabled . Please re-enable it to view ads", log: .default, type: .error)
            } else {
                // Fallback on earlier versions
                print("Error: Ad Tracking is disabled . Please re-enable it to view ads")
            }
            return
        }

        if advertisementId != nil {
            let loggedInUser = NSKeyedUnarchiver.unarchiveObject(withFile: Hcp.ArchivingUrl.path) as? Hcp

            //        var loggedInUser = DataController.shared.getLoggedInUser()
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let jsonData = try? jsonEncoder.encode(loggedInUser)
            let json = String(data: jsonData!, encoding: .utf8)!
            let data: Data = json.data(using: .utf8)!
            let json_string = String(data: data, encoding: .utf8)!.replacingOccurrences(of: "\n", with: "")

            if let platformuid = NSKeyedUnarchiver.unarchiveObject(withFile: ArchivingUrl.path) as? String {
                self.isPlatformUidPresent = true
            } else{
                self.isPlatformUidPresent = false
            }
            
            let request = AdRequest(id: slotId, size: size, platformType: "mobileApp", appKey: appKey, loggedInUser: json_string.toBase64()!)
            addsWebRepo.getAdImage(request: request)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print(error.localizedDescription)
//                        fatalError(error.localizedDescription)
//                        completion(Results(withData: nil, response: nil, error: DocereeAdRequestError.failedToCreateRequest), false)
                    }
                } receiveValue: { (data, response) in
                    do{
                        let adResponseData: AdResponseForPlatform = try JSONDecoder().decode(AdResponseForPlatform.self, from: data)
                                            print("getImage response \(adResponseData)")
                        if adResponseData.errMessage != nil && adResponseData.errMessage!.count > 0 {
                            completion(Results(withData: nil, response: response as? HTTPURLResponse, error: DocereeAdRequestError.failedToCreateRequest), adResponseData.isAdRichMedia())
                            return
                        }
                        if !self.isPlatformUidPresent && adResponseData.newPlatformUid != nil {
                            // MARK check zone tag here later on for US based users' response
                            self.savePlatformuid(adResponseData.newPlatformUid!)
                        }
                        completion(Results(withData: data, response: response as? HTTPURLResponse, error: nil), adResponseData.isAdRichMedia())
                    } catch{
                        completion(Results(withData: nil, response: response as? HTTPURLResponse, error: DocereeAdRequestError.failedToCreateRequest), false)
                    }
                }
                .store(in: &disposables)
        } else {
            if #available(iOS 10.0, *){
                os_log("Unknown error", log: .default, type: .error)
            } else {
                print("Unknown error")
            }
        }
    }

    internal func savePlatformuid(_ newPlatormuid: String){
        NSKeyedArchiver.archiveRootObject(newPlatormuid, toFile: ArchivingUrl.path)
    }
    
    private func getIdentifierForAdvertising() -> String?{
        if #available(iOS 14, *){
            if (DocereeMobileAds.trackingStatus == "authorized") {
                self.isVendorId = false
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            } else {
                self.isVendorId = true
                return UIDevice.current.identifierForVendor?.uuidString
            }
        } else {
            // Fallback to previous versions
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                self.isVendorId = false
                return ASIdentifierManager.shared().advertisingIdentifier.uuidString
            } else {
                self.isVendorId = true
                return UIDevice.current.identifierForVendor?.uuidString
            }
        }
    }
}

public extension RestManager{
    
    internal enum HttpMethod: String {
        case get
        case post
    }
    
    struct RestEntity {
        private var values: [String: String] = [:]
        
        mutating func add(value: String, forKey key: String){
            values[key] = value
        }
        
        func value(forKey key: String) -> String? {
            return values[key]
        }
        
        func allValues() -> [String: String]{
            return values
        }
        
        func totalItems() -> Int{
            return values.count
        }
    }
    
    struct Response{
        var response: URLResponse?
        var httpStatusCode: Int = 0
        var headers = RestEntity()
        
        init(fromUrlResponse response: HTTPURLResponse?) {
            guard let response = response else{ return }
            self.response = response
            httpStatusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            
            if let headerFields = (response as? HTTPURLResponse)?.allHeaderFields{
                for(key, value) in headerFields{
                    headers.add(value: "\(value)", forKey: "\(key)")
                }
            }
        }
    }
    
    struct Results {
        var data: Data?
        var response: HTTPURLResponse?
        var error: Error?
        
        init(withData data: Data?, response: HTTPURLResponse?, error: Error?) {
            self.data = data
            self.response = response
            self.error = error
        }
    }
}

//MARK: Private methods
private func getHost(type: EnvironmentType) -> String?{
    switch type{
    case .Dev:
        return "dev-bidder.doceree.com"
    case .Local:
        return "10.0.3.2"
    case .Qa:
        return "qa-bidder.doceree.com"
    case .Prod:
        return "bidder.doceree.com"
    }
}

private func getDocTrackerHost(type: EnvironmentType) -> String?{
    switch type{
    case .Dev:
        return "dev-tracking.doceree.com"
    case .Local:
        return "10.0.3.2"
    case .Qa:
        return "qa-tracking.doceree.com"
    case .Prod:
        return "tracking.doceree.com"
    }
}

private func getPath(methodName: Methods) -> String{
    switch methodName{
    case .GetImage:
        return "/v1/adrequest"
    case .AdBlock:
        return "/saveadblockinfo"
    }
}

enum EnvironmentType{
    case Dev
    case Prod
    case Local
    case Qa
}

enum Methods{
    case GetImage
    case AdBlock
}
