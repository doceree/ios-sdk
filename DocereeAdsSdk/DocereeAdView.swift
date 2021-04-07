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
    var countDown = 30
    private var docereeAdRequest: DocereeAdRequest?
    
    var consentUV: AdConsentUIView?
    
    var crossImageView: UIImageView?
    var infoImageView: UIImageView?
    let iconWidth = 13
    let iconHeight = 13
    
    var banner: DocereeAdViewRichMediaBanner?
    
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
        self.docereeAdRequest = docereeAdRequest
        let queue = OperationQueue()
        let operation1 = BlockOperation(block: {
            let width: Int = Int((self.adSize?.getAdSize().width)!)
            let height: Int = Int((self.adSize?.getAdSize().height)!)
            let size = "\(width)x\(height)"
            // MARK : size restriction for iPhones & iPads
            if UIDevice.current.userInterfaceIdiom == .phone && (self.adSize?.getAdSizeName() == "LEADERBOARD" || self.adSize?.getAdSizeName() == "FULLBANNER"){
                os_log("Invalid Request. Ad size will not fit on screen", log: .default, type: .error)
                return
            }
            docereeAdRequest.requestAd(self.docereeAdUnitId, size){ (results, isRichMediaAd) in
                if let data = results.data {
                    let decoder = JSONDecoder()
                    do {
                        let adResponseData: AdResponseForPlatform = try decoder.decode(AdResponseForPlatform.self, from: data)
                        if (adResponseData.sourceURL ?? "").isEmpty{
                            self.removeAllViews()
                            return
                        }
                        let imageUrl = adResponseData.sourceURL
                        self.cbId = adResponseData.CBID?.components(separatedBy: "_")[0]
                        self.docereeAdUnitId = adResponseData.DIVID!
                        self.ctaLink = adResponseData.ctaLink
                        let isImpressionLinkNullOrEmpty: Bool = (adResponseData.impressionLink ?? "").isEmpty
                        if (!isImpressionLinkNullOrEmpty) {
                            docereeAdRequest.sendImpression(impressionUrl: adResponseData.impressionLink!)
                        }
                        if !isRichMediaAd{
                            if (imageUrl == nil || imageUrl?.count == 0) {
                                return
                            }
                            DispatchQueue.main.async {
                                NotificationCenter.default.setObserver(observer: self, selector: #selector(self.appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
                                NotificationCenter.default.setObserver(observer: self, selector: #selector(self.willMoveToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
                                NotificationCenter.default.setObserver(observer: self, selector: #selector(self.didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
                                self.addSubview(self.adImageView)
                                let imageUrl = NSURL(string: (adResponseData.sourceURL)!)
                                self.handleImageRendering(of: imageUrl)
                                if self.delegate != nil{
                                    self.delegate?.docereeAdViewDidReceiveAd(self)
                                }
                            }
                        } else {
                            // Handle Rich media ads here
                            // Show mraid banner
                            // get source url and download html body
                            if let url = URL(string: adResponseData.sourceURL!){
                                do{
                                    let htmlContent = try String(contentsOf: url)
                                    var refinedHtmlContent = htmlContent.withReplacedCharacter("<head>", by: "<head><style>html,body{padding:0;margin:0;}</style><base href=" + (adResponseData.sourceURL?.components(separatedBy: "unzip")[0])! + "unzip/" + "target=\"_blank\">")
                                    if (self.ctaLink != nil && self.ctaLink!.count > 0){
                                        refinedHtmlContent = refinedHtmlContent.replacingOccurrences(of: "[TRACKING_LINK]", with: self.ctaLink!)
                                    }
                                    let body: String = refinedHtmlContent
                                    if (body.count == 0){
                                        return
                                    }
                                    DispatchQueue.main.async {
                                        self.banner = DocereeAdViewRichMediaBanner()
                                        //                                    banner.initialize(parentViewController:self.rootViewController!, position:"bottom-center", respectSafeArea:true, renderBodyOverride: true, size: self.adSize!, body: body)
                                        NotificationCenter.default.setObserver(observer: self, selector: #selector(self.appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
                                        NotificationCenter.default.setObserver(observer: self, selector: #selector(self.willMoveToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
                                        NotificationCenter.default.setObserver(observer: self, selector: #selector(self.didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
                                        self.banner!.initialize(parentViewController: self.rootViewController!, frame: self.frame, renderBodyOverride: false, size: self.adSize!, body: body, docereeAdView: self, delegate: self.delegate)
                                        if self.delegate != nil{
                                            self.delegate?.docereeAdViewDidReceiveAd(self)
                                        }
                                    }
                                    
                                } catch{
                                    self.delegate?.docereeAdView(self, didFailToReceiveAdWithError: DocereeAdRequestError.failedToCreateRequest)
                                    self.removeAllViews()
                                }
                            } else {
                                self.delegate?.docereeAdView(self, didFailToReceiveAdWithError: DocereeAdRequestError.failedToCreateRequest)
                                self.removeAllViews()
                            }
                        }
                    } catch{
                        self.delegate?.docereeAdView(self, didFailToReceiveAdWithError: DocereeAdRequestError.failedToCreateRequest)
                        self.removeAllViews()
                    }
                } else {
                    self.delegate?.docereeAdView(self, didFailToReceiveAdWithError: DocereeAdRequestError.failedToCreateRequest)
                    self.removeAllViews()
                }
            }
        })
        queue.addOperation(operation1)
        AdsRefreshCountdownTimer.shared.startRefresh(){
            self.refresh()
        }
    }
    
//    public override func layoutSubviews() {
//        super.layoutSubviews()
//        self.frame.size = CGSize(width: self.adSize!.width, height: self.adSize!.height)
//    }
    
    //MARK: Private methods
    
    private func handleImageRendering(of imageUrl: NSURL?){
        if imageUrl == nil || imageUrl?.absoluteString?.count == 0 {
            return
        }
        if NSData(contentsOf: imageUrl! as URL)?.imageFormat == ImageFormat.GIF {
            let url = imageUrl
            let image = UIImage.gifImageWithURL((url?.absoluteString)!)
            self.adImageView.image = image
            setupConsentIcons()
        } else {
            let imageSource = CGImageSourceCreateWithURL(imageUrl!, nil)
            let image = UIImage(cgImage: CGImageSourceCreateImageAtIndex(imageSource!, 0, nil)!)
            self.adImageView.image = image
            setupConsentIcons()
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
    
    private func setupConsentIcons() {
        let lightConfiguration = UIImage.SymbolConfiguration(weight: .light)
        
        self.crossImageView = UIImageView(image: UIImage(systemName: "xmark.square", withConfiguration: lightConfiguration))
        crossImageView!.frame = CGRect(x: Int(adSize!.width) - iconWidth, y: iconHeight/10, width: iconWidth, height: iconHeight)
        crossImageView!.tintColor =  UIColor.init(hexString: "#6C40F7")
        self.adImageView.addSubview(crossImageView!)
        crossImageView!.isUserInteractionEnabled = true
        let tapOnCrossButton = UITapGestureRecognizer(target: self, action: #selector(openAdConsentView))
        crossImageView!.addGestureRecognizer(tapOnCrossButton)
        
        self.infoImageView = UIImageView(image: UIImage(systemName: "info.circle", withConfiguration: lightConfiguration))
        infoImageView!.frame = CGRect(x: Int(adSize!.width) - 2*iconWidth, y: iconHeight/10, width: iconWidth, height: iconHeight)
        infoImageView!.tintColor =  UIColor.init(hexString: "#6C40F7")
        self.adImageView.addSubview(infoImageView!)
        infoImageView!.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(startLabelAnimation))
        infoImageView!.addGestureRecognizer(tap)
    }
    
    @objc func startLabelAnimation(_ sender: UITapGestureRecognizer){
        
        let xCoords = CGFloat(0)
        let yCoords = CGFloat(self.infoImageView!.frame.origin.y)
        
        self.infoImageView!.layoutIfNeeded()
        let placeHolderView = UILabel()
        placeHolderView.text = "Ads by doceree"
        placeHolderView.font = placeHolderView.font.withSize(9)
        placeHolderView.textColor = UIColor(hexString: "#6C40F7")
        placeHolderView.frame = CGRect(x: xCoords, y: yCoords, width: 0, height: (self.infoImageView?.frame.height)!)
        self.infoImageView!.addSubview(placeHolderView)
        placeHolderView.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 1.0, animations: { [self] in
            placeHolderView.backgroundColor = UIColor(hexString: "#F2F2F2")
            placeHolderView.frame = CGRect(x: xCoords, y: yCoords, width: -placeHolderView.intrinsicContentSize.width, height: (self.infoImageView?.frame.height)!)
        }, completion: { (finished: Bool) in
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.openAdConsentView))
            self.infoImageView?.addGestureRecognizer(tap)
                        placeHolderView.removeFromSuperview()
                        self.openAdConsent()
        })
    }
    
    @objc func openAdConsentView(_ sender: UITapGestureRecognizer){
        //         let consentVC = AdConsentViewController()
        //        consentVC.initialize(parentViewController: self.rootViewController!, adsize: self.adSize!, frame: self.frame)
        openAdConsent()
    }
    
    private func openAdConsent(){
        consentUV = AdConsentUIView(with: self.adSize!, frame: self.frame, rootVC: self.rootViewController!, adView: self, isRichMedia: false)
        self.adImageView.removeFromSuperview()
        self.addSubview(consentUV!)
        //        self.adImageView.addSubview(consentUV!)
        //        self.addSubview(consentUV!)
    }
    
    public override class var requiresConstraintBasedLayout: Bool{
        return true
    }
    
    func removeAllViews(){
        DispatchQueue.main.async {
            for v in self.subviews{
                v.removeFromSuperview()
            }
            if(self.banner != nil){
                self.banner?.view.removeFromSuperview()
            }
        }
    }
    
    //Mark: Action method
    @objc func onImageTouched(_ sender: UITapGestureRecognizer){
        DocereeAdView.self.didLeaveAd = true
        let url = URL(string: ctaLink!)
        if url != nil && UIApplication.shared.canOpenURL(url!){
            AdsRefreshCountdownTimer.shared.stopRefresh()
            UIApplication.shared.openURL(url!)
            self.removeAllViews()
        }
    }
    
    @objc func appMovedToBackground(){
        AdsRefreshCountdownTimer.shared.stopRefresh()
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
        self.refresh()
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
        AdsRefreshCountdownTimer.shared.stopRefresh()
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        if window != nil {
            NotificationCenter.default.removeObserver(self)
            AdsRefreshCountdownTimer.shared.stopRefresh()
        }
    }
    
    func refresh(){
        self.removeAllViews()
        if docereeAdRequest != nil {
            load(self.docereeAdRequest!)
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

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
