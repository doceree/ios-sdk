//
//  DocereeAdView.swift
//  iosadslibrarydemo
//
//  Created by dushyant pawar on 16/04/20.
//  Copyright © 2020 dushyant pawar. All rights reserved.
//

import UIKit
import ImageIO
import SafariServices
import os.log

public final class DocereeAdView: UIView, UIApplicationDelegate {
    
    //MARK: Properties
    var loadingResponses: [(_: URL) -> Void] = []
    public var docereeAdUnitId: String = String.init()
    public var delegate: DocereeAdViewDelegate?
    var ctaLink: String?
    var cbId: String?
    static var didLeaveAd: Bool = false
    var isResponseFromAdbutler: Bool = false
    var p1: String?, p2: String?, click: String?
    var placement1: Placement_1?
    
    @IBOutlet public weak var rootViewController: UIViewController?
    
    var adSize: AdSize?
    
    var image: UIImage?
    
    lazy var adImageView: UIImageView = {
        let adImageView = UIImageView()
        //        adImageView.image = setUpImage(with: adSize!)
        adImageView.translatesAutoresizingMaskIntoConstraints = false
        return adImageView
    }()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(adImageView)
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(adImageView)
        setUpLayout()
    }
    
    public convenience init?(with size: String?){
        self.init()
        if size == nil || size?.count == 0{
            os_log("Error: Please provide a valid size!", log: .default, type: .error)
            return
        }
        adSize = getAdSize(for: size)
        if adSize is Invalid {
            os_log("Error: Invalid size!", log: .default, type: .error)
            return
        }
        adSize = getAdSize(for: size)
        if adSize!.width > UIScreen.main.bounds.width {
            self.adSize?.width = UIScreen.main.bounds.width
        }
        self.init(with: adSize)
    }
    
    public convenience init?(with size: String?, and origin: CGPoint){
        self.init(with: size)
        adSize = getAdSize(for: size)
        if adSize!.width > UIScreen.main.bounds.width {
            self.adSize?.width = UIScreen.main.bounds.width
        }
        self.init(with: adSize, and: origin)
    }
    
    private convenience init(with adSize: AdSize?){
        self.init(frame: CGRect(x: .zero, y: .zero, width: (adSize?.width)!, height: (adSize?.height)!))
        if adSize == nil {
            os_log("Error: AdSize must be provided", log: .default, type: .error)
        } else{
            if adSize is Banner{
                self.adSize = Banner()
            } else if adSize is LargeBanner{
                self.adSize = LargeBanner()
            } else{
                self.adSize = Banner()
            }
        }
        addSubview(adImageView)
        setUpLayout()
    }
    
    private convenience init(with adSize: AdSize?, and origin: CGPoint){
        self.init(frame: CGRect(x: origin.x, y: origin.y, width: (adSize?.width)!, height: (adSize?.height)!))
        if adSize == nil {
            os_log("Error: AdSize must be provided", log: .default, type: .error)
        } else{
            self.adSize = adSize
        }
        addSubview(adImageView)
        setUpLayout()
    }
    
    public override var intrinsicContentSize: CGSize{
        return CGSize(width: (adSize?.width)!, height: (adSize?.height)!)
    }
    
    //MARK: Public methods
    public func load(_ docereeAdRequest: DocereeAdRequest){
        //        todo set image here
        let queue = OperationQueue()
        let operation1 = BlockOperation(block: {
            let width: Int = Int((self.adSize?.getAdSize().width)!)
            let height: Int = Int((self.adSize?.getAdSize().height)!)
            let size = "\(width)x\(height)"
            if UIDevice.current.userInterfaceIdiom == .phone && (self.adSize?.getAdSizeName() == "LEADERBOARD" || self.adSize?.getAdSizeName() == "FULLBANNER"){
                os_log("Invalid Request. Ad size will not fit on screen", log: .default, type: .error)
                return
            }
            docereeAdRequest.requestAd(self.docereeAdUnitId, size){ (results, isResponseForUS, isRichMediaAd) in
                if let data = results.data {
                    let decoder = JSONDecoder()
                    do {
                        if !isResponseForUS {
                            self.isResponseFromAdbutler = false
                            let adResponseData: AdResponse = try decoder.decode(AdResponse.self, from: data)
                            self.ctaLink = adResponseData.ctaLink
                            self.cbId = adResponseData.CBID
                            if (adResponseData.sourceURL.count == 0){
                                return
                            }
                            DispatchQueue.main.async {
                                NotificationCenter.default.setObserver(observer: self, selector: #selector(self.appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
                                NotificationCenter.default.setObserver(observer: self, selector: #selector(self.willMoveToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
                                NotificationCenter.default.setObserver(observer: self, selector: #selector(self.didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
                                let imageUrl = NSURL(string: adResponseData.sourceURL)
                                self.handleImageRendering(of: imageUrl)
                                docereeAdRequest.sendAnalytics(self.docereeAdUnitId, self.cbId!, TypeOfEvent.CPM)
                                if self.delegate != nil{
                                    self.delegate?.docereeAdViewDidReceiveAd(self)
                                }
                            }
                        } else {
                            self.isResponseFromAdbutler = true
                            let adResponseData: ResponseAdButler = try decoder.decode(ResponseAdButler.self, from: data)
                            let imageUrl = adResponseData.placements?.placement_1?.image_url
                            self.ctaLink = adResponseData.placements?.placement_1?.redirect_url
                            if !isRichMediaAd{
                                if (imageUrl == nil || imageUrl?.count == 0) {
                                    return
                                }
                                DispatchQueue.main.async {
                                    NotificationCenter.default.setObserver(observer: self, selector: #selector(self.appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
                                    NotificationCenter.default.setObserver(observer: self, selector: #selector(self.willMoveToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
                                    NotificationCenter.default.setObserver(observer: self, selector: #selector(self.didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
                                    let imageUrl = NSURL(string: (adResponseData.placements?.placement_1?.image_url)!)
//                                    let imageSource = CGImageSourceCreateWithURL(imageUrl!, nil)
//                                    let image = UIImage(cgImage: CGImageSourceCreateImageAtIndex(imageSource!, 0, nil)!)
//                                    self.adImageView.image = image
                                    self.handleImageRendering(of: imageUrl)
                                    if self.delegate != nil{
                                        self.delegate?.docereeAdViewDidReceiveAd(self)
                                    }
                                }
                            } else {
                                // Handle Rich media ads here
                                // Show mraid banner
                                let body: String = (adResponseData.placements?.placement_1?.body)!
                                if (body.count == 0){
                                    return
                                }
                                DispatchQueue.main.async {
                                    let banner = DocereeAdViewRichMediaBanner()
                                    //                                    banner.initialize(parentViewController:self.rootViewController!, position:"bottom-center", respectSafeArea:true, renderBodyOverride: true, size: self.adSize!, body: body)
                                    NotificationCenter.default.setObserver(observer: self, selector: #selector(self.appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
                                    NotificationCenter.default.setObserver(observer: self, selector: #selector(self.willMoveToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
                                    NotificationCenter.default.setObserver(observer: self, selector: #selector(self.didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
                                    banner.initialize(parentViewController: self.rootViewController!, frame: self.frame, renderBodyOverride: false, size: self.adSize!, body: body, docereeAdView: self, delegate: self.delegate)
                                    if self.delegate != nil{
                                        self.delegate?.docereeAdViewDidReceiveAd(self)
                                    }
                                }
                            }
                        }
                    } catch{
                        self.isResponseFromAdbutler = false
                        self.delegate?.docereeAdView(self, didFailToReceiveAdWithError: DocereeAdRequestError.failedToCreateRequest)
                    }
                } else {
                    self.delegate?.docereeAdView(self, didFailToReceiveAdWithError: DocereeAdRequestError.failedToCreateRequest)
                }
            }
        })
        queue.addOperation(operation1)
    }
    
    //MARK: Private methods
    
    private func handleImageRendering(of imageUrl: NSURL?){
        if imageUrl == nil || imageUrl?.absoluteString?.count == 0 {
            return
        }
        if NSData(contentsOf: imageUrl! as URL)?.imageFormat == ImageFormat.GIF {
            let url = imageUrl
            let image = UIImage.gifImageWithURL((url?.absoluteString)!)
            self.adImageView.image = image
        } else {
            let imageSource = CGImageSourceCreateWithURL(imageUrl!, nil)
            let image = UIImage(cgImage: CGImageSourceCreateImageAtIndex(imageSource!, 0, nil)!)
            self.adImageView.image = image
        }
    }
    
    private func setUpLayout(){
        //        NSLayoutConstraint.activate([
        //                   self.adImageView.topAnchor.constraint(equalTo: topAnchor),
        //                   self.adImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        //                   self.adImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
        //                   self.adImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        //               ])
        //        self.translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        // add actions here
        let tap = UITapGestureRecognizer(target: self, action: #selector(DocereeAdView.onImageTouched(_:)))
        self.adImageView.addGestureRecognizer(tap)
        self.adImageView.isUserInteractionEnabled = true
    }
    
    public override class var requiresConstraintBasedLayout: Bool{
        return true
    }
    
    
    
    //Mark: Action method
    @objc func onImageTouched(_ sender: UITapGestureRecognizer){
        DocereeAdView.self.didLeaveAd = true
        if !self.isResponseFromAdbutler {
            let url = URL(string: ctaLink!)
//            let vc = SFSafariViewController(url: url!)
//            vc.delegate = self
//            self.rootViewController?.present(vc, animated: true, completion: {
            if UIApplication.shared.canOpenURL(url!){
                DocereeAdRequest().sendAnalytics(self.docereeAdUnitId, self.cbId!, TypeOfEvent.CPC)
                UIApplication.shared.openURL(url!)
            }
//                self.delegate?.docereeAdViewWillPresentScreen(self)
//            })
        } else {
            let url = URL(string: ctaLink!)
//            let vc = SFSafariViewController(url: url!)
//            vc.delegate = self
//            self.rootViewController?.present(vc, animated: true, completion: {
//                DocereeAdRequest().sendImpressionsToAdButler()
//                self.delegate?.docereeAdViewWillPresentScreen(self)
//            })
            if UIApplication.shared.canOpenURL(url!){
                DocereeAdRequest().sendImpressionsToAdButler()
                UIApplication.shared.openURL(url!)
            }
        }
    }
    
    @objc func appMovedToBackground(){
        if  DocereeAdView.didLeaveAd && delegate != nil {
            delegate?.docereeAdViewWillLeaveApplication(self)
        }
    }
    
    @objc func willMoveToForeground(){
        if DocereeAdView.didLeaveAd && delegate != nil {
            delegate?.docereeAdViewWillDismissScreen(self)
        }
    }
    
    @objc func didBecomeActive(){
        if DocereeAdView.didLeaveAd && delegate != nil {
            delegate?.docereeAdViewDidDismissScreen(self)
            DocereeAdView.didLeaveAd = false
        }
    }
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if delegate != nil{
            delegate?.docereeAdViewWillDismissScreen(self)
        }
    }
    
    // MARK: Private methods
    private func getAdSize(for size: String?) -> AdSize {
        switch size {
        case "320 x 50":
            return Banner()
        case "320 x 100":
            return LargeBanner()
        case "468 x 60":
            return FullBanner()
        case "300 x 250":
            return MediumRectangle()
        case "728 x 90":
            return LeaderBoard()
        default:
            return Invalid()
        }
    }
    
    //    private func nibSetUp(){
    //        let nib = UINib(nibName: "DocereeAdView", bundle: nil)
    //        nib.instantiate(withOwner: self, options: nil)
    //        adImageView.frame = bounds
    //        addSubview(adImageView)
    //        setUpLayout()
    //    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        if window != nil {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
}

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

extension UIImage {
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
    public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL? = URL(string: gifUrl)
            else {
                //                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL!) else {
            //            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                //                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            //            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                                 Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                                                             Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                                                            source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
                                              duration: Double(duration) / 1000.0)
        
        return animation
    }
}

struct ImageHeaderData{
    static var PNG: [UInt8] = [0x89]
    static var JPEG: [UInt8] = [0xFF]
    static var GIF: [UInt8] = [0x47]
    static var TIFF_01: [UInt8] = [0x49]
    static var TIFF_02: [UInt8] = [0x4D]
}

enum ImageFormat{
    case Unknown, PNG, JPEG, GIF, TIFF
}

extension NSData{
    var imageFormat: ImageFormat{
        var buffer = [UInt8](repeating: 0, count: 1)
        self.getBytes(&buffer, range: NSRange(location: 0, length: 1))
        if buffer == ImageHeaderData.GIF{
            return .GIF
        } else if buffer == ImageHeaderData.JPEG{
            return .JPEG
        } else if buffer == ImageHeaderData.PNG{
            return .PNG
        } else if buffer == ImageHeaderData.TIFF_01 || buffer == ImageHeaderData.TIFF_02{
            return .TIFF
        } else {
            return .Unknown
        }
    }
}

extension NotificationCenter{
    func setObserver(observer: Any, selector: Selector, name: NSNotification.Name, object: AnyObject?){
        NotificationCenter.default.removeObserver(observer, name: name, object: object)
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: object)
    }
}
