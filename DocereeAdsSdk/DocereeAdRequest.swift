
import Foundation
import UIKit
import Combine
import os.log

public final class DocereeAdRequest {
    
    private var size: String?
    private var adUnitId: String?
    private let addsWebRepo: AdWebRepoProtocol = AdWebRepo()
    private var disposables = Set<AnyCancellable>()
    
    // todo: create a queue of requests and inititate request
    public init() {
    }
    
    // MARK: Properties
    private var isPlatformUidPresent: Bool = false
    
    // MARK: Public methods
    internal func requestAd(_ adUnitId: String!, _ size: String!, completion: @escaping(_ results: Results,
                                                                                        _ isRichMediaAd: Bool) -> Void){
        self.adUnitId = adUnitId
        self.size = size
        setUpImage(){ (results, isRichMediaAd) in
            completion(results, isRichMediaAd)
        }
    }
    
    internal func sendImpression(impressionUrl: String){
        addsWebRepo.sendAdImpression(request: impressionUrl)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    break
                }
            } receiveValue: { (data, response) in
                print("impressionUrl: ", response, data)
            }
            .store(in: &disposables)
    }

    internal func setUpImage(completion: @escaping(_ results: Results, _ isRichmedia: Bool) -> Void){
        
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

            var platformuid = ""
            if let pid = NSKeyedUnarchiver.unarchiveObject(withFile: ArchivingUrl.path) as? String {
                platformuid = pid
                self.isPlatformUidPresent = true
            } else{
                self.isPlatformUidPresent = false
            }
            
            let request = AdRequest(id: adUnitId ?? "", size: size ?? "", platformType: "mobileApp", appKey: appKey, loggedInUser: json_string.toBase64()!, platformUid: platformuid)
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
                            savePlatformuid(adResponseData.newPlatformUid!)
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
}
