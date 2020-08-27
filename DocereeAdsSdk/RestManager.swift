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

public final class RestManager{
    // MARK: Properties
    var requestHttpHeaders = RestEntity()
    var urlQueryParameters = RestEntity()
    var httpBodyParameters = RestEntity()
    var httpBody: Data?
    var loggingEnabled: Bool = false
    var isPlatformUidPresent: Bool = false
    
    static var temp1: String?, temp2: String?, tempClick: String?
    static var tempPlacement1: Placement_1?
    
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
    
    
    internal func getImage(_ size: String!, _ slotId: String!, completion: @escaping(_ results: Results, _ isUSResponse: Bool, _ isRichmedia: Bool) -> Void){
        guard let appKey = Bundle.main.object(forInfoDictionaryKey: "DocereeAdsIdentifier") as? String else {
//            os_log("Error: Missing DocereeIdentifier key!", log: .default, type: .error)
            return
        }
        
        guard let advertisementId = getIdentifierForAdvertising() else {
//            os_log("Error: Ad Tracking is disabled. Please re-enable it to view ads", log: .default, type: .error)
            return
        }
        
        var image: UIImage?
        var cbId: String?
        var ctaLink: String?
        var sourceImageUrl: String?
        var loggedInUser = NSKeyedUnarchiver.unarchiveObject(withFile: Hcp.ArchivingUrl.path) as? Hcp
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
        self.requestHttpHeaders.add(value: ua, forKey: Header.header_user_agent.rawValue)
        self.requestHttpHeaders.add(value: advertisementId, forKey: Header.header_advertising_id.rawValue)
        self.urlQueryParameters.add(value: appKey, forKey: QueryParamsForGetImage.appKey.rawValue) // DocereeAdsIdentifier
        self.urlQueryParameters.add(value: slotId, forKey: QueryParamsForGetImage.id.rawValue)
        self.urlQueryParameters.add(value: size, forKey: QueryParamsForGetImage.size.rawValue)
        self.urlQueryParameters.add(value: "mobileApp", forKey: QueryParamsForGetImage.platformType.rawValue)
        if let platformuid = NSKeyedUnarchiver.unarchiveObject(withFile: AdResponseForPlatform.ArchivingUrl.path) as? String {
            //        if platformuid != nil {
            //        let platformuid = DataController.shared.getPlatformuid()
            //        if platformuid != nil {
            let data = ["platformUid": platformuid]
            let jsonData = try? JSONSerialization.data(withJSONObject: data, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            self.urlQueryParameters.add(value: jsonString!, forKey: QueryParamsForGetImage.loggedInUser.rawValue)
            self.isPlatformUidPresent = true
        } else{
            self.urlQueryParameters.add(value: json_string, forKey: QueryParamsForGetImage.loggedInUser.rawValue)
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
        urlRequest.httpMethod = HttpMethod.get.rawValue
        let task = session.dataTask(with: urlRequest) {(data, response, error) in
            guard let data = data else { return }
            let urlResponse = response as! HTTPURLResponse
            if urlResponse.statusCode == 200 {
                do{
                    let adResponseData: AdResponseForPlatform = try JSONDecoder().decode(AdResponseForPlatform.self, from: data)
//                    print("getImage response \(adResponseData)")
                    if adResponseData.errMessage != nil && adResponseData.errMessage!.count > 0  && adResponseData.newPlatformUid == nil {
                        completion(Results(withData: nil, response: response as! HTTPURLResponse, error: DocereeAdRequestError.failedToCreateRequest), false, false)
                        return
                    }
                    if !self.isPlatformUidPresent && adResponseData.newPlatformUid != nil {
                        // MARK check zone tag here later on for US based users' response
                        self.savePlatformuid(let: adResponseData.newPlatformUid!)
                    } else if (adResponseData.isAdbutlerResponse()) {
                        // get first id from adresponse
                        let firstID = adResponseData.accountId
                        // get second id from adresponse
                        let secondID = adResponseData.setId  //"442790" //"442781"
                        // also get height and width from there
                        let height = adResponseData.height //"300" //"200"
                        let width = adResponseData.width //"250" //"200"
                        let size = width!+"x"+height!
                        // get subcampaign id from adresponse
                        let subcampaignID =  adResponseData.kw //"5f227c9f47e6de0013081a8b" //"5f1ed92823d7c00014be6acc" //"5f1ff7ad47e6de00130819b5"
                        // hit adbutler service with the above params
                        let p1 = adResponseData.p1
                        let p2 = adResponseData.p2
                        let click = adResponseData.click
                        self.hitAdButlerService(fID: firstID!, sID: secondID!, size: size, subcampaignId: subcampaignID!, p1: p1!, p2: p2!, click: click!){(results, isRichMedia) in
                            completion(results, true, isRichMedia)
                        }
                        // get the result and render the image
                        return
                    }
                    sourceImageUrl = adResponseData.sourceURL
                    cbId = adResponseData.CBID
                    ctaLink = adResponseData.ctaLink
                } catch{
                }
                completion(Results(withData: data as Data?, response: response as! HTTPURLResponse, error: nil), false, false)
            } else {
                completion(Results(withData: nil, response: response as! HTTPURLResponse, error: DocereeAdRequestError.failedToCreateRequest), false, false)
            }
        }
        task.resume()
    }
    
    internal func hitAdButlerService(fID: String, sID: String, size: String, subcampaignId: String, p1: String, p2: String,
                                     click: String, completion: @escaping(_ results: Results, _ isRichMedia: Bool) -> Void){
        var isRichMedia: Bool = false
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        var components = URLComponents()
        components.scheme = "https"
        components.host = getHost(type: EnvironmentType.AdButler)
        components.path = getPath(methodName: Methods.ServedByAdButler)
        components.path = components.path
            .stringAppendingPathComponent(path: ";ID=\(fID);size=\(size);setID=\(sID);type=json;kw=\(subcampaignId);customParam1=\(p1);customParam2=\(p2)")
        components.percentEncodedPath = components.percentEncodedPath.removingPercentEncoding!
//        print("Adbutler request \(components.url)")
        var urlRequest = URLRequest(url: (components.url)!)
        urlRequest.httpMethod = HttpMethod.get.rawValue
        let task = session.dataTask(with: urlRequest) {(data, response, error) in
            guard let data = data else { return }
            let response = response as! HTTPURLResponse
            if response.statusCode == 200{
                do {
                    let adbutlerResponse: ResponseAdButler = try JSONDecoder().decode(ResponseAdButler.self, from: data)
                    if adbutlerResponse.status != ResponseAdButler.ResponseStatus(rawValue: ResponseAdButler.ResponseStatus.SUCCESS.rawValue){
                        return
                    }
                    if adbutlerResponse.placements?.placement_1?.body != nil && !((adbutlerResponse.placements?.placement_1?.body!.isEmpty)!) {
                        isRichMedia = true
                    }
                    RestManager.self.temp1 = p1
                    RestManager.self.temp2 = p2
                    RestManager.self.tempClick = click
                    RestManager.self.tempPlacement1 = adbutlerResponse.placements?.placement_1
                    self.trackPixelApi(p1: p1, p2: p2, click: click, placement1: (adbutlerResponse.placements?.placement_1)!, isClickTracking: false)
                    completion(Results(withData: data as Data?, response: response , error: nil), isRichMedia)
                } catch{
                }
            } else {
                completion(Results(withData: nil, response: response as! HTTPURLResponse, error: DocereeAdRequestError.failedToCreateRequest), false)
            }
        }
        task.resume()
    }
    
    func sendClickImpressionOnAdButler(){
        self.trackPixelApi(p1: RestManager.self.temp1!, p2: RestManager.self.temp2!, click: RestManager.self.tempClick!, placement1: RestManager.self.tempPlacement1!, isClickTracking: true)
    }
    
    func trackPixelApi(p1: String, p2: String, click: String, placement1: Placement_1, isClickTracking: Bool){
        var updatedUrl: String? = nil
        if !isClickTracking{
            updatedUrl = (placement1.tracking_pixel?.contains("p1=\(p1)"))! ? placement1.tracking_pixel : placement1.tracking_pixel?.withReplacedCharacter("p1=", by: "p1=\(p1)")
            updatedUrl = (updatedUrl?.contains("p2=\(p2)"))! ? updatedUrl : updatedUrl!.withReplacedCharacter("p2=", by: "p2=\(p2)")
            // MARK: remove later for testing purpose only
//            updatedUrl = updatedUrl!.withReplacedCharacter("https://localhost:2000", by: "http://568c519bc30d.ngrok.io")
            // MARK: remove later for testing purpose only
        } else {
            updatedUrl = click
            let redirectUrl: String = placement1.redirect_url!
            updatedUrl = click.withReplacedCharacter("docredirecturl=", by: "docredirecturl=\(redirectUrl)")
//            updatedUrl = updatedUrl!.withReplacedCharacter("http://localhost:2000", by: "http://568c519bc30d.ngrok.io")
        }
        let url: URL = URL(string: updatedUrl!)!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HttpMethod.get.rawValue
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: urlRequest) {(data, response, error) in
            guard let data = data else { return }
            let response = response as! HTTPURLResponse
            if response.statusCode == 200{
                do {
//                    print(data)
                } catch{
//                    print("Exception thrown in adbutler response \(error)")
                }
            }
        }
        task.resume()
    }
    
    internal func savePlatformuid(let newPlatormuid: String){
        let isSaved: Bool = NSKeyedArchiver.archiveRootObject(newPlatormuid, toFile: AdResponseForPlatform.ArchivingUrl.path)
        //        DataController.shared.save(newplatformuid: newPlatormuid)
    }
    
    internal func sendAnalyticsEvent(_ type: String, _ slotId: String, _ cbId: String){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        dateFormatter.timeZone = NSTimeZone(name: "GMT") as TimeZone?
        let timeStamp = dateFormatter.string(from: Date())
        let ua: String = UAString.init().UAString()
        self.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
        self.requestHttpHeaders.add(value: UAString.init().UAString(), forKey: Header.header_user_agent.rawValue)
        self.httpBodyParameters.add(value: type, forKey: AdAnalytics.typeOfEvent.rawValue)
        self.httpBodyParameters.add(value: slotId, forKey: AdAnalytics.publisherACSID.rawValue)
        self.httpBodyParameters.add(value: cbId, forKey: AdAnalytics.advertiserCampID.rawValue)
        self.httpBodyParameters.add(value: timeStamp, forKey: AdAnalytics.dateInUTC.rawValue)
        let body = httpBodyParameters.allValues()
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        var components = URLComponents()
        components.scheme = "https"
        components.host = getHost(type: EnvironmentType.Qa)
        components.path = getPath(methodName: Methods.Analytics)
        let analyticsEndpoint: URL = components.url!
        var request: URLRequest = URLRequest(url: analyticsEndpoint)
        request.setValue(ua, forHTTPHeaderField: Header.header_user_agent.rawValue)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = HttpMethod.post.rawValue
        let jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch{
            return
        }
        let task = session.dataTask(with: request)
        task.resume()
    }
}

private func getIdentifierForAdvertising() -> String?{
    if ASIdentifierManager.shared().isAdvertisingTrackingEnabled{
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    } else {
        return nil
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
        return "dev-programmatic.doceree.com"
    case .Local:
        return "568c519bc30d.ngrok.io"
    case .Qa:
        return "qa-programmatic.doceree.com"
    case .Prod:
        return "programmatic.doceree.com"
    case .AdButler:
        return "servedbyadbutler.com"
    }
}

private func getPath(methodName: Methods) -> String{
    switch methodName{
    case .GetImage:
        return "/render/getImage"
    case .Analytics:
        return "/render/saveDetail"
    case .ServedByAdButler:
        return "/adserve"
    }
}

enum EnvironmentType{
    case Dev
    case Prod
    case Local
    case Qa
    case AdButler
}

enum Methods{
    case GetImage
    case Analytics
    case ServedByAdButler
}

enum Analytics{
    case CPC
    case CPM
}

extension DocereeAdRequestError: LocalizedError{
    public var localizedDescription: String{
        switch self{
        case .failedToCreateRequest: return NSLocalizedString("Failed to load ad. Please contact support@doceree.com", comment: "")
        }
    }
}

enum AdAnalytics: String{
    case typeOfEvent = "typeOfEvent"
    case advertiserCampID = "advertiserCampID"
    case publisherACSID = "publisherACSID"
    case dateInUTC = "dateInUTC"
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
}
