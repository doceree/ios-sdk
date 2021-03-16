//
//  RestManager.swift
//  iosadslibrarydemo
//
//  Created by dushyant pawar on 23/04/20.
//  Copyright © 2020 dushyant pawar. All rights reserved.
//
import Foundation
import UIKit
import os.log
import AdSupport
import AppTrackingTransparency
import AdSupport
import CommonCrypto

public final class RestManager{
    // MARK: Properties
    var requestHttpHeaders = RestEntity()
    var urlQueryParameters = RestEntity()
    var httpBodyParameters = RestEntity()
    var httpBody: Data?
    var loggingEnabled: Bool = false
    var isPlatformUidPresent: Bool = false
    var isVendorId: Bool = false
        
    // MARK: Private functions
    private func addUrlQueryParameters(url: URL, urlQueryParameters: RestEntity) -> URL{
        if urlQueryParameters.totalItems() > 0 {
            guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }
            urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery!.replacingOccurrences(of: ";", with:"%3B")
            var queryItems = [URLQueryItem]()
            for (key, value) in urlQueryParameters.allValues(){
                //                let item = URLQueryItem(name: key, value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
                let item = URLQueryItem(name: key, value: value.trimmingCharacters(in: .whitespacesAndNewlines))
                queryItems.append(item)
            }
            urlComponents.queryItems = queryItems
            
            guard let updatedUrl = urlComponents.url else { return url }
            
            return updatedUrl
        }
        return url
    }
    
    private func getHttpBody() -> Data?{
        guard let contentType = requestHttpHeaders.value(forKey: "Content-Type") else { return nil }
        if contentType.contains("application/json"){
            return try? JSONSerialization.data(withJSONObject: httpBodyParameters.allValues(), options: [.prettyPrinted, .sortedKeys])
        } else if contentType.contains("application/x-www-form-urlencoded"){
            let bodyString = httpBodyParameters.allValues().map{"\($0)=\(String(describing: $1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)))"}.joined(separator: "&")
            return bodyString.data(using: .utf8)
        } else{
            return httpBody
        }
    }
    
    private func prepareRequest(withUrl url : URL?, httpBody: Data?, httpMethod: HttpMethod) -> URLRequest?{
        guard let url = url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        
        for (header, value) in requestHttpHeaders.allValues(){
            request.setValue(value, forHTTPHeaderField: header)
        }
        
        request.httpBody = httpBody
        return request
    }
    
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
            os_log("Error: Missing DocereeIdentifier key!", log: .default, type: .error)
            return
        }
        
        var advertisementId: String?
        advertisementId = getIdentifierForAdvertising()
        if (advertisementId == nil) {
            os_log("Error: Ad Tracking is disabled . Please re-enable it to view ads", log: .default, type: .error)
            return
        }
        if advertisementId != nil {
            var cbId: String?
            var ctaLink: String?
            var impressionUrl: String?
            var sourceUrl: String?
            var loggedInUser = NSKeyedUnarchiver.unarchiveObject(withFile: Hcp.ArchivingUrl.path) as? Hcp
            var isAdRichMedia: Bool
            
            let bundle = Bundle(identifier: "com.doceree.DocereeAdsSdk")!
            let frameWorkVersion = bundle.infoDictionary![kCFBundleVersionKey as String] as! String
            
            //        var loggedInUser = DataController.shared.getLoggedInUser()
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let jsonData = try? jsonEncoder.encode(loggedInUser)
            let json = String(data: jsonData!, encoding: .utf8)!
            var data: Data = json.data(using: .utf8)!
            let json_dict = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: String]
            let json_data = try? jsonEncoder.encode(json_dict)
            let json_string = String(data: data, encoding: .utf8)!.replacingOccurrences(of: "\n", with: "")
            var ua = UAString.init().UAString()
            
            //header
//            self.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
            self.requestHttpHeaders.add(value: ua, forKey: Header.header_user_agent.rawValue)
            self.requestHttpHeaders.add(value: advertisementId!, forKey: Header.header_advertising_id.rawValue)
            self.requestHttpHeaders.add(value: self.isVendorId ? "1" : "0", forKey: Header.is_vendor_id.rawValue)
            self.requestHttpHeaders.add(value: DocereeMobileAds.trackingStatus!, forKey: Header.header_is_ad_tracking_enabled.rawValue)
            self.requestHttpHeaders.add(value: Bundle.main.displayName!, forKey: Header.header_app_name.rawValue)
            self.requestHttpHeaders.add(value: Bundle.main.bundleIdentifier!, forKey: Header.header_app_bundle.rawValue)
            self.requestHttpHeaders.add(value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String, forKey: Header.header_app_version.rawValue)
            self.requestHttpHeaders.add(value: frameWorkVersion, forKey: Header.header_lib_version.rawValue)
            
            // query params
            self.urlQueryParameters.add(value: appKey, forKey: QueryParamsForGetImage.appKey.rawValue) // DocereeAdsIdentifier
            self.urlQueryParameters.add(value: slotId, forKey: QueryParamsForGetImage.id.rawValue)
            self.urlQueryParameters.add(value: size, forKey: QueryParamsForGetImage.size.rawValue)
            self.urlQueryParameters.add(value: "mobileApp", forKey: QueryParamsForGetImage.platformType.rawValue)

            if let platformuid = NSKeyedUnarchiver.unarchiveObject(withFile: AdResponseForPlatform.ArchivingUrl.path) as? String {
                //        if platformuid != nil {
                //        let platformuid = DataController.shared.getPlatformuid()
                //        if platformuid != nil {
                var data: Dictionary<String, String?>
                if loggedInUser?.npi != nil {
                    data = Dictionary()
                    data = ["platformUid": platformuid]
                } else {
                    data = Dictionary()
                    data = ["platformUid": platformuid,
                            "city": loggedInUser?.city,
                            "specialization": loggedInUser?.specialization,]
//                    data.setValue(platformuid, forKey: "platformUid")
//                    data.setValue(loggedInUser?.city, forKey: "city")
//                    data.setValue(loggedInUser?.specialization, forKey: "specialization")
                }
                let jsonData = try? JSONSerialization.data(withJSONObject: data, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)?.toBase64() // encode to base64
                self.urlQueryParameters.add(value: jsonString!, forKey: QueryParamsForGetImage.loggedInUser.rawValue)
                self.isPlatformUidPresent = true
            } else{
                self.urlQueryParameters.add(value: json_string.toBase64()!, forKey: QueryParamsForGetImage.loggedInUser.rawValue)
                self.isPlatformUidPresent = false
            }
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            var components = URLComponents()
            components.scheme = "https"
            components.host = getHost(type: EnvironmentType.Qa)
            components.path = getPath(methodName: Methods.GetImage)
            var queryItems: [URLQueryItem] = []
            for (key, value) in self.urlQueryParameters.allValues(){
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            components.queryItems = queryItems
            var urlRequest = URLRequest(url: (components.url)!)
            //        urlRequest.setValue(ua, forHTTPHeaderField: Header.header_user_agent.rawValue)
            //        urlRequest.setValue(advertisementId, forHTTPHeaderField: Header.header_advertising_id.rawValue)
            
            // set headers
            for header in requestHttpHeaders.allValues() {
                urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
            }
            
            urlRequest.httpMethod = HttpMethod.get.rawValue
            let task = session.dataTask(with: urlRequest) {(data, response, error) in
                guard let data = data else { return }
                let urlResponse = response as! HTTPURLResponse
                if urlResponse.statusCode == 200 {
                    do{
                        let adResponseData: AdResponseForPlatform = try JSONDecoder().decode(AdResponseForPlatform.self, from: data)
                        //                    print("getImage response \(adResponseData)")
                        if adResponseData.errMessage != nil && adResponseData.errMessage!.count > 0 {
                            completion(Results(withData: nil, response: response as! HTTPURLResponse, error: DocereeAdRequestError.failedToCreateRequest), adResponseData.isAdRichMedia())
                            return
                        }
                        if !self.isPlatformUidPresent && adResponseData.newPlatformUid != nil {
                            // MARK check zone tag here later on for US based users' response
                            self.savePlatformuid(let: adResponseData.newPlatformUid!)
                        }
                        sourceUrl = adResponseData.sourceURL
                        cbId = adResponseData.CBID
                        ctaLink = adResponseData.ctaLink
                        impressionUrl = adResponseData.impressionLink
                        completion(Results(withData: data, response: response as! HTTPURLResponse, error: nil), adResponseData.isAdRichMedia())
                    } catch{
                        completion(Results(withData: nil, response: response as! HTTPURLResponse, error: DocereeAdRequestError.failedToCreateRequest), false)
                    }
                } else {
                    completion(Results(withData: nil, response: response as! HTTPURLResponse, error: DocereeAdRequestError.failedToCreateRequest), false)
                }
            }
            task.resume()
        } else {
            os_log("Unknown error", log: .default, type: .error)
        }
    }
    
//    internal func hitAdButlerService(fID: String, sID: String, size: String, subcampaignId: String, p1: String, p2: String,
//                                     click: String, completion: @escaping(_ results: Results, _ isRichMedia: Bool) -> Void){
//        var isRichMedia: Bool = false
//        let config = URLSessionConfiguration.default
//        let session = URLSession(configuration: config)
//        var components = URLComponents()
//        components.scheme = "https"
//        components.host = getHost(type: EnvironmentType.AdButler)
//        components.path = getPath(methodName: Methods.ServedByAdButler)
//        components.path = components.path
//            .stringAppendingPathComponent(path: ";ID=\(fID);size=\(size);setID=\(sID);type=json;kw=\(subcampaignId);customParam1=\(p1);customParam2=\(p2)")
//        components.percentEncodedPath = components.percentEncodedPath.removingPercentEncoding!
////        print("Adbutler request \(components.url)")
//        var urlRequest = URLRequest(url: (components.url)!)
//        urlRequest.httpMethod = HttpMethod.get.rawValue
//        let task = session.dataTask(with: urlRequest) {(data, response, error) in
//            guard let data = data else { return }
//            let response = response as! HTTPURLResponse
//            if response.statusCode == 200{
//                do {
//                    let adbutlerResponse: ResponseAdButler = try JSONDecoder().decode(ResponseAdButler.self, from: data)
//                    if adbutlerResponse.status != ResponseAdButler.ResponseStatus(rawValue: ResponseAdButler.ResponseStatus.SUCCESS.rawValue){
//                        return
//                    }
//                    if adbutlerResponse.placements?.placement_1?.body != nil && !((adbutlerResponse.placements?.placement_1?.body!.isEmpty)!) {
//                        isRichMedia = true
//                    }
//                    RestManager.self.temp1 = p1
//                    RestManager.self.temp2 = p2
//                    RestManager.self.tempClick = click
//                    RestManager.self.tempPlacement1 = adbutlerResponse.placements?.placement_1
//                    self.trackPixelApi(p1: p1, p2: p2, click: click, placement1: (adbutlerResponse.placements?.placement_1)!, isClickTracking: false)
//                    completion(Results(withData: data as Data?, response: response , error: nil), isRichMedia)
//                } catch{
//                }
//            } else {
//                completion(Results(withData: nil, response: response as! HTTPURLResponse, error: DocereeAdRequestError.failedToCreateRequest), false)
//            }
//        }
//        task.resume()
//    }
        
    func sendAdImpression(impressionUrl: String){
        let updatedUrl: String? = impressionUrl
        let url: URL = URL(string: updatedUrl!)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HttpMethod.get.rawValue
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        if (self.requestHttpHeaders != nil) {
            // set headers
            for header in requestHttpHeaders.allValues() {
                urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        let task = session.dataTask(with: urlRequest){ (data, response, error) in
            guard let data = data else { return }
            let urlResponse = response as! HTTPURLResponse
            print("impression sent. Http Status code is \(urlResponse.statusCode)")
        }
        task.resume()
    }
    
    internal func savePlatformuid(let newPlatormuid: String){
        let isSaved: Bool = NSKeyedArchiver.archiveRootObject(newPlatormuid, toFile: AdResponseForPlatform.ArchivingUrl.path)
        //        DataController.shared.save(newplatformuid: newPlatormuid)
    }
    
    internal func sendAdBlockRequest(_ advertiserCampID: String?, _ blockLevel: String?, _ platformUid: String?, _ publisherACSID: String?){
        if ((advertiserCampID ?? "").isEmpty || (blockLevel ?? "").isEmpty || (platformUid ?? "").isEmpty || (publisherACSID ?? "").isEmpty) {
            return
        }
        let ua: String = UAString.init().UAString()
        // headers
        self.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
        self.requestHttpHeaders.add(value: UAString.init().UAString(), forKey: Header.header_user_agent.rawValue)
        
        // query params
        self.httpBodyParameters.add(value: advertiserCampID!, forKey: AdBlockService.advertiserCampID.rawValue)
        self.httpBodyParameters.add(value: blockLevel!, forKey: AdBlockService.blockLevel.rawValue)
        self.httpBodyParameters.add(value: platformUid!, forKey: AdBlockService.platformUid.rawValue)
        self.httpBodyParameters.add(value: publisherACSID!, forKey: AdBlockService.publisherACSID.rawValue)
        
        let body = httpBodyParameters.allValues()
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        var components = URLComponents()
        components.scheme = "https"
        components.host = getHost(type: EnvironmentType.Qa)
        components.path = getPath(methodName: Methods.AdBlock)
        let analyticsEndpoint: URL = components.url!
        var request: URLRequest = URLRequest(url: analyticsEndpoint)
        request.setValue(ua, forHTTPHeaderField: Header.header_user_agent.rawValue)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // set headers
        for header in requestHttpHeaders.allValues() {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        request.httpMethod = HttpMethod.post.rawValue
        let jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch{
            return
        }
        let task = session.dataTask(with: request){(data, response, error) in
            guard let data = data else { return }
            let urlResponse = response as! HTTPURLResponse
            print(urlResponse.statusCode)
        }
        task.resume()
    }
    
    private func getIdentifierForAdvertising() -> String?{
        var isIDFAAvailable = false
        if (DocereeMobileAds.trackingStatus != nil){
            if DocereeMobileAds.trackingStatus == "authorized" {
                isIDFAAvailable = true
            }
        } else {
            isIDFAAvailable = false
        }
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled && isIDFAAvailable{
            self.isVendorId = false
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        } else {
            self.isVendorId = true
            return UIDevice.current.identifierForVendor?.uuidString
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
        
        func value(forKey key: String) -> String?{
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
        var response: HTTPURLResponse
        var error: Error?
        
        init(withData data: Data?, response: HTTPURLResponse, error: Error?) {
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
        return "10.0.3.2:8085"
    case .Qa:
        return "qa-bidder.doceree.com"
    case .Prod:
        return "bidder.doceree.com"
    }
}

private func getPath(methodName: Methods) -> String{
    switch methodName{
    case .GetImage:
        return "/v1/adrequest"
    case .AdBlock:
        return "/v1/saveadblockinfo"
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

extension DocereeAdRequestError: LocalizedError{
    public var localizedDescription: String{
        switch self{
        case .failedToCreateRequest: return NSLocalizedString("Failed to load ad. Please contact support@doceree.com", comment: "")
        }
    }
}

extension String{
    func stringAppendingPathComponent(path: String) -> String{
        let aString = self as NSString
        return aString.appendingPathComponent(path)
    }
    
    func withReplacedCharacter(_ oldChar: String, by newChar: String) -> String{
        let newStr = self.replacingOccurrences(of: oldChar, with: newChar, options: .literal, range: nil)
        return newStr
    }
    
    func findIfStringConatains(_ char: String) -> Bool{
        return self.contains(char)
    }
    
    func sha256() -> String?{
        guard let data = self.data(using: String.Encoding.utf8) else { return nil }
        let hash = data.withUnsafeBytes{(bytes: UnsafePointer<Data>) -> [UInt8] in
            var hash: [UInt8] = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256(bytes, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map{ String(format: "%02x", $0) }.joined()
    }
    
    func toBase64() -> String?{
        return Data(self.utf8).base64EncodedString()
    }
}

extension Bundle {
    // Name of the app - title under the icon.
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
            object(forInfoDictionaryKey: "CFBundleName") as? String
    }
    
    var releaseVersionNumber: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String? {
        return self.infoDictionary?["CFBundleVersion"] as? String
    }
}
