//
//  AdConsentUIView.swift
//  DocereeAdsSdk
//
//  Created by dushyant pawar on 09/03/21.
//  Copyright © 2021 Doceree. All rights reserved.
//

import UIKit
import WebKit

class AdConsentUIView: UIView {
    
    // MARK: private vars
    private var verticalStackView: UIStackView?
    private var consentView: UIView?
    
    var docereeAdView: DocereeAdView?
    var docereeWebView: WKWebView?
    
    var isRichMedia: Bool = false
    
    private lazy var purpleColor: UIColor = {
        let purpleColor = UIColor(hexString: "#6C40F7")
        return purpleColor
    }()
    
    private lazy var blackColor: UIColor = {
        let blackColor = UIColor(hexString: "#000000")
        return blackColor
    }()
    
    private lazy var whiteColor: UIColor = {
        let whiteColor = UIColor(hexString: "#FFFFFF")
        return whiteColor
    }()
    
    private lazy var greyBackgroundColor: UIColor = {
        let backgroundColor = UIColor(hexString: "#F2F2F2")
        return backgroundColor
    }()
    
//    private var adConsentBlockLevel1 = [String: String]()
//    private var adConsentBlockLevel2 = [String: String]()
    
    var isMediumRectangle: Bool = false
    var isBanner: Bool = false
    var isLeaderboard: Bool = false
    
    private var textFontSize12: CGFloat = 12.0
    private var textFontSize9: CGFloat = 9.0
    private var textFontSize10: CGFloat = 10.0
    private var textFontSize8: CGFloat = 8.0
    
    var adViewSize: AdSize?
    
    var adViewFrame: CGRect?
    var rootViewController: UIViewController?
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        addSubview(adImageView)
//        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        addSubview(adImageView)
//        setUpLayout()
    }
    
    convenience init?(with adSize: AdSize, frame: CGRect, rootVC: UIViewController, adView: DocereeAdView?, isRichMedia: Bool){
        self.init()
        adViewSize = adSize
        adViewFrame = frame
        rootViewController = rootVC
        docereeAdView = adView
        self.isRichMedia = isRichMedia
        isMediumRectangle = self.getAdTypeBySize(adSize: self.adViewSize!) == AdType.MEDIUMRECTANGLE
        isBanner = self.getAdTypeBySize(adSize: self.adViewSize!) == AdType.BANNER
        isLeaderboard = self.getAdTypeBySize(adSize: self.adViewSize!) == AdType.LEADERBOARD
        loadConsentForm1()
    }
    
//    private convenience init(with adViewSize: AdSize, frame: CGRect){
//        self.init(frame: CGRect(x: .zero, y: .zero, width: (adViewSize.width), height: (adViewSize.height)))
//        loadConsentForm1()
//    }
        
    // MARK: Initialize AdConsentUIView
    
    // MARK: Horizontal Containers
    
    // MARK: Vertical Containers
    
    // MARK: Load Consent form1
    private func loadConsentForm1(){
        // load back button
        
        consentView = UIView()
        let iconSize: CGFloat = 15.0
        let titleHeight: CGFloat = 15.0
        
        let buttonWidth: CGFloat = isMediumRectangle ? self.adViewFrame!.width * 0.8 : self.adViewFrame!.width * 0.4
        let buttonHeight: CGFloat = isMediumRectangle ? self.adViewFrame!.height * 0.2 : self.adViewFrame!.height/2
        let buttonLabelFontSize: CGFloat = textFontSize12
        
        consentView!.backgroundColor = self.greyBackgroundColor
//        self.parent?.view.addSubview(consentView)
        
        let lightConfiguration = UIImage.SymbolConfiguration(pointSize: iconSize, weight: .light, scale: .small)
        let backButtonUIImageView: UIImageView = UIImageView(image: UIImage(systemName: "arrow.backward", withConfiguration: lightConfiguration))
        backButtonUIImageView.contentMode = .scaleAspectFit
        backButtonUIImageView.tintColor = self.purpleColor
        backButtonUIImageView.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
        backButtonUIImageView.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
        backButtonUIImageView.isUserInteractionEnabled = true
        let backButtonUITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backButtonClicked))
        backButtonUIImageView.addGestureRecognizer(backButtonUITapGestureRecognizer)
        
        let titleView = UILabel()
        titleView.text = "Ads by doceree"
        titleView.font = .systemFont(ofSize: textFontSize12)
        titleView.textColor = self.purpleColor
        titleView.widthAnchor.constraint(equalToConstant: self.adViewFrame!.width).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: titleHeight).isActive = true
        titleView.textAlignment = .center
        
        // horizontal stackview 1
        let horizontalStackView1 = UIStackView()
        horizontalStackView1.axis = .horizontal
        horizontalStackView1.distribution = UIStackView.Distribution.equalSpacing
        horizontalStackView1.alignment = .fill
        
        horizontalStackView1.addArrangedSubview(backButtonUIImageView)
        horizontalStackView1.addArrangedSubview(titleView)
        horizontalStackView1.translatesAutoresizingMaskIntoConstraints = false
        
        consentView!.addSubview(horizontalStackView1)
        
        let lightConfigurationWithSmallScale = UIImage.SymbolConfiguration(pointSize: 13, weight: .light, scale: .small)
        
        let btnReportAd = UIButton()
        btnReportAd.setTitle("Report this Ad", for: .normal)
        btnReportAd.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        btnReportAd.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        btnReportAd.setTitleColor(self.blackColor, for: .normal)
        btnReportAd.backgroundColor = self.whiteColor
        btnReportAd.titleLabel?.font = .systemFont(ofSize: buttonLabelFontSize) // UIFont(name: YourfontName, size: 12)
        btnReportAd.translatesAutoresizingMaskIntoConstraints = false
        btnReportAd.isUserInteractionEnabled = true
        let adReportTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(reportAdClicked))
        btnReportAd.addGestureRecognizer(adReportTapGestureRecognizer)
        
        let btnWhyThisAd = UIButton()
        btnWhyThisAd.setTitle("Why this Ad?", for: .normal)
        let infoImage = UIImage(systemName: "info.circle", withConfiguration: lightConfigurationWithSmallScale)
        infoImage?.withTintColor(self.purpleColor)
        btnWhyThisAd.setImage(infoImage, for: .normal)
        btnWhyThisAd.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        btnWhyThisAd.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        btnWhyThisAd.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        btnWhyThisAd.setTitleColor(self.blackColor, for: .normal)
        btnWhyThisAd.backgroundColor = self.whiteColor
        btnWhyThisAd.titleLabel?.font = .systemFont(ofSize: buttonLabelFontSize) // UIFont(name: YourfontName, size: 12)
        btnWhyThisAd.semanticContentAttribute = .forceRightToLeft
        btnWhyThisAd.translatesAutoresizingMaskIntoConstraints = false
        btnWhyThisAd.isUserInteractionEnabled = true
        let whyThisTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(whyThisClicked))
        btnWhyThisAd.addGestureRecognizer(whyThisTapGestureRecognizer)
        
        // horizontal stackview 2
        let horizontalStackView2 = UIStackView()
        horizontalStackView2.axis =  self.isMediumRectangle ? .vertical : .horizontal
        horizontalStackView2.distribution = self.isMediumRectangle ? .fillEqually : .fill
        horizontalStackView2.alignment = .center
        horizontalStackView2.spacing = 8.0
        horizontalStackView2.addArrangedSubview(btnReportAd)
        horizontalStackView2.addArrangedSubview(btnWhyThisAd)
        
        if isMediumRectangle {
            btnReportAd.topAnchor.constraint(equalTo: horizontalStackView2.topAnchor, constant: self.adViewFrame!.height * 0.25).isActive = true
        }
        
        horizontalStackView2.translatesAutoresizingMaskIntoConstraints = false
        
        //         vertical stackview
        verticalStackView = UIStackView()
        verticalStackView?.axis = .vertical
        verticalStackView?.distribution = .fillProportionally
        verticalStackView?.alignment = .center
        verticalStackView?.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView?.addArrangedSubview(horizontalStackView1)
        verticalStackView?.addArrangedSubview(horizontalStackView2)
        //        verticalStackView!.addArrangedSubview(firstLineStackView)
        
        consentView!.addSubview(verticalStackView!)
        
        verticalStackView!.topAnchor.constraint(equalTo: consentView!.topAnchor, constant: 0).isActive = true
        verticalStackView!.bottomAnchor.constraint(equalTo: consentView!.bottomAnchor, constant: self.isMediumRectangle ? -self.adViewFrame!.height * 0.25 : 0).isActive = true
        verticalStackView!.leadingAnchor.constraint(equalTo: consentView!.leadingAnchor, constant: 0).isActive = true
        verticalStackView!.trailingAnchor.constraint(equalTo: consentView!.trailingAnchor, constant: 0).isActive = true
        
        consentView!.frame = CGRect(x: .zero, y: .zero, width: adViewFrame!.width, height: adViewFrame!.height)
        
        if (!self.isRichMedia) {
        self.docereeAdView!.addSubview(consentView!)
        } else {
//            self.docereeWebView!.addSubview(consentView!)

            for v in rootViewController!.view.subviews{
                v.removeFromSuperview()
            }
            consentView!.frame = CGRect(x: .zero, y: .zero, width: adViewFrame!.width, height: adViewFrame!.height)
            self.rootViewController?.view.addSubview(consentView!)
        }
//        consentView!.frame = adViewFrame!
//        rootViewController?.view.addSubview(consentView!)
    }
    
    // MARK: Load Consent form2
    private func loadConsentForm2(){
        // load back button
        
        consentView = UIView()
        consentView!.backgroundColor = self.greyBackgroundColor
        
        let buttonWidth: CGFloat = isMediumRectangle ? self.adViewFrame!.width * 0.8 : self.adViewFrame!.width * 0.3
        let buttonHeight: CGFloat = self.adViewFrame!.height * 0.8
        let buttonLabelFontSize: CGFloat = self.isBanner ? textFontSize10 : textFontSize12
        
        let btnAdCoveringContent = UIButton()
        btnAdCoveringContent.setTitle("Ad is covering the content of the website.", for: .normal)
        btnAdCoveringContent.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        btnAdCoveringContent.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        btnAdCoveringContent.setTitleColor(self.blackColor, for: .normal)
        btnAdCoveringContent.backgroundColor = self.whiteColor
        btnAdCoveringContent.titleLabel?.lineBreakMode = .byWordWrapping
        btnAdCoveringContent.titleLabel?.textAlignment = .center
        btnAdCoveringContent.titleLabel?.font = .systemFont(ofSize: buttonLabelFontSize) // UIFont(name: YourfontName, size: 12)
        btnAdCoveringContent.translatesAutoresizingMaskIntoConstraints = false
        btnAdCoveringContent.isUserInteractionEnabled = true
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(adCoveringContentClicked))
        btnAdCoveringContent.addGestureRecognizer(tap1)
        
        let btnAdInappropriate = UIButton()
        btnAdInappropriate.setTitle("Ad was inappropriate.", for: .normal)
        btnAdInappropriate.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        btnAdInappropriate.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        btnAdInappropriate.setTitleColor(self.blackColor, for: .normal)
        btnAdInappropriate.backgroundColor = self.whiteColor
        btnAdInappropriate.titleLabel?.lineBreakMode = .byWordWrapping
        btnAdInappropriate.titleLabel?.textAlignment = .center
        btnAdInappropriate.titleLabel?.font = .systemFont(ofSize: buttonLabelFontSize) // UIFont(name: YourfontName, size: 12)
        btnAdInappropriate.translatesAutoresizingMaskIntoConstraints = false
        btnAdInappropriate.isUserInteractionEnabled = true
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(adWasInappropriateClicked))
        btnAdInappropriate.addGestureRecognizer(tap2)
        
        let btnAdNotInterested = UIButton()
        btnAdNotInterested.setTitle("Not interested in this ad.", for: .normal)
        btnAdNotInterested.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        btnAdNotInterested.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        btnAdNotInterested.setTitleColor(self.blackColor, for: .normal)
        btnAdNotInterested.backgroundColor = self.whiteColor
        btnAdNotInterested.titleLabel?.lineBreakMode = .byWordWrapping
        btnAdNotInterested.titleLabel?.textAlignment = .center
        btnAdNotInterested.titleLabel?.font = .systemFont(ofSize: buttonLabelFontSize) // UIFont(name: YourfontName, size: 12)
        btnAdNotInterested.translatesAutoresizingMaskIntoConstraints = false
        btnAdNotInterested.isUserInteractionEnabled = true
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(adNotInterestedClicked))
        btnAdNotInterested.addGestureRecognizer(tap3)
        
        // horizontal stackview 2
        let horizontalStackView2 = UIStackView()
        horizontalStackView2.axis = isMediumRectangle ? .vertical : .horizontal
        horizontalStackView2.distribution = .fillEqually
        horizontalStackView2.alignment = .center
        horizontalStackView2.spacing = self.isMediumRectangle ? 8.0 : 4.0
        horizontalStackView2.addArrangedSubview(btnAdCoveringContent)
        horizontalStackView2.addArrangedSubview(btnAdInappropriate)
        horizontalStackView2.addArrangedSubview(btnAdNotInterested)
        horizontalStackView2.translatesAutoresizingMaskIntoConstraints = false
        
        let verticalConstraintConstant: CGFloat
        let horizontalConstraintConstant: CGFloat
        
        if isMediumRectangle {
            btnAdCoveringContent.topAnchor.constraint(equalTo: horizontalStackView2.topAnchor, constant: self.adViewFrame!.height * 0.2).isActive = true
        }
        
        consentView!.addSubview(horizontalStackView2)
        
        horizontalStackView2.topAnchor.constraint(equalTo: consentView!.topAnchor, constant: self.isLeaderboard ? self.adViewFrame!.height * 0.2 : 0).isActive = true
        horizontalStackView2.bottomAnchor.constraint(equalTo: consentView!.bottomAnchor, constant: (self.isMediumRectangle || self.isLeaderboard) ? -self.adViewFrame!.height * 0.2 : 0).isActive = true
        horizontalStackView2.leadingAnchor.constraint(equalTo: consentView!.leadingAnchor, constant: self.isLeaderboard ? 32 :  4).isActive = true
        horizontalStackView2.trailingAnchor.constraint(equalTo: consentView!.trailingAnchor, constant: self.isLeaderboard ? -32 : -4).isActive = true
  
        consentView!.frame = CGRect(x: .zero, y: .zero, width: adViewFrame!.width, height: adViewFrame!.height)
//        self.docereeAdView!.addSubview(consentView!)
        
        if (!self.isRichMedia) {
        self.docereeAdView!.addSubview(consentView!)
        } else {
//            self.docereeWebView!.addSubview(consentView!)

            for v in rootViewController!.view.subviews{
                v.removeFromSuperview()
            }
            consentView!.frame = CGRect(x: .zero, y: .zero, width: adViewFrame!.width, height: adViewFrame!.height)
            self.rootViewController?.view.addSubview(consentView!)
        }
//        consentView!.frame = adViewFrame!
//        rootViewController?.view.addSubview(consentView!)
    }
    
    // MARK: Load Consent form3
    private func loadConsentForm3(){
        // load back button
        
        consentView = UIView()
        consentView!.backgroundColor = self.greyBackgroundColor
//        self.parent?.view.addSubview(consentView)
        
        let buttonWidth: CGFloat = isMediumRectangle ? self.adViewFrame!.width * 0.8 : self.adViewFrame!.width * 0.4
        let buttonHeight: CGFloat = self.adViewFrame!.height * 0.9
        let textFontSize: CGFloat = self.isBanner ? self.textFontSize8 : self.textFontSize12
                
        let btn1 = UIButton()
        btn1.setTitle("I'm not interested\n in seeing ads for this product.", for: .normal)
        btn1.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        btn1.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        btn1.setTitleColor(self.blackColor, for: .normal)
        btn1.backgroundColor = self.whiteColor
        btn1.titleLabel?.lineBreakMode = .byWordWrapping
        btn1.titleLabel?.textAlignment = .center
        btn1.titleLabel?.font = .systemFont(ofSize: textFontSize) // UIFont(name: YourfontName, size: 12)
        btn1.translatesAutoresizingMaskIntoConstraints = false
        btn1.isUserInteractionEnabled = true
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(adNotInterestedClicked1))
        btn1.addGestureRecognizer(tap1)
        
        let btn2 = UIButton()
        btn2.setTitle("I'm not interested\n in seeing ads for this brand.", for: .normal)
        btn2.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        btn2.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        btn2.setTitleColor(self.blackColor, for: .normal)
        btn2.backgroundColor = self.whiteColor
        btn2.titleLabel?.lineBreakMode = .byWordWrapping
        btn2.titleLabel?.textAlignment = .center
        btn2.titleLabel?.font = .systemFont(ofSize: textFontSize) // UIFont(name: YourfontName, size: 12)
        btn2.translatesAutoresizingMaskIntoConstraints = false
        btn2.isUserInteractionEnabled = true
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(adNotInterestedClicked2))
        btn2.addGestureRecognizer(tap2)
        
        let btn3 = UIButton()
        btn3.setTitle("I'm not interested in seeing ads for this category.", for: .normal)
        btn3.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        btn3.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        btn3.setTitleColor(self.blackColor, for: .normal)
        btn3.backgroundColor = self.whiteColor
        btn3.titleLabel?.lineBreakMode = .byWordWrapping
        btn3.titleLabel?.textAlignment = .center
        btn3.titleLabel?.font = .systemFont(ofSize: textFontSize) // UIFont(name: YourfontName, size: 12)
        btn3.translatesAutoresizingMaskIntoConstraints = false
        btn3.isUserInteractionEnabled = true
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(adNotInterestedClicked3))
        btn3.addGestureRecognizer(tap3)
        
        let btn4 = UIButton()
        btn4.setTitle("I'm not interested in seeing ads from pharmaceutical brands.", for: .normal)
        btn4.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        btn4.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        btn4.setTitleColor(self.blackColor, for: .normal)
        btn4.backgroundColor = self.whiteColor
        btn4.titleLabel?.lineBreakMode = .byWordWrapping
        btn4.titleLabel?.textAlignment = .center
        btn4.titleLabel?.font = .systemFont(ofSize: textFontSize) // UIFont(name: YourfontName, size: 12)
        btn4.translatesAutoresizingMaskIntoConstraints = false
        btn4.isUserInteractionEnabled = true
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(adNotInterestedClicked4))
        btn4.addGestureRecognizer(tap4)
        
        // horizontal stackview 2
        let horizontalStackView2 = UIStackView()
        horizontalStackView2.axis = self.isMediumRectangle ? .vertical : .horizontal
        horizontalStackView2.distribution = .fillEqually
        horizontalStackView2.alignment = .center
        horizontalStackView2.spacing = self.isMediumRectangle ? 6.0 : 4.0
        horizontalStackView2.addArrangedSubview(btn1)
        horizontalStackView2.addArrangedSubview(btn2)
        horizontalStackView2.addArrangedSubview(btn3)
        horizontalStackView2.addArrangedSubview(btn4)
        horizontalStackView2.translatesAutoresizingMaskIntoConstraints = false
        
        if isMediumRectangle {
            btn1.topAnchor.constraint(equalTo: horizontalStackView2.topAnchor, constant: self.adViewFrame!.height * 0.1).isActive = true
        }
        
        consentView!.addSubview(horizontalStackView2)
        
        horizontalStackView2.topAnchor.constraint(equalTo: consentView!.topAnchor, constant: 0).isActive = true
        horizontalStackView2.bottomAnchor.constraint(equalTo: consentView!.bottomAnchor, constant: self.isMediumRectangle ?
                                                        -self.adViewFrame!.height * 0.1 : 0).isActive = true
        horizontalStackView2.leadingAnchor.constraint(equalTo: consentView!.leadingAnchor, constant: 4).isActive = true
        horizontalStackView2.trailingAnchor.constraint(equalTo: consentView!.trailingAnchor, constant: -4).isActive = true
        
        consentView!.frame = CGRect(x: .zero, y: .zero, width: adViewFrame!.width, height: adViewFrame!.height)
//        self.docereeAdView!.addSubview(consentView!)
        
        if (!self.isRichMedia) {
        self.docereeAdView!.addSubview(consentView!)
        } else {
//            self.docereeWebView!.addSubview(consentView!)

            for v in rootViewController!.view.subviews{
                v.removeFromSuperview()
            }
            consentView!.frame = CGRect(x: .zero, y: .zero, width: adViewFrame!.width, height: adViewFrame!.height)
            self.rootViewController?.view.addSubview(consentView!)
        }
        
//        consentView!.frame = adViewFrame!
//        rootViewController?.view.addSubview(consentView!)
    }
    
    // load feedback
    private func loadAdConsentFeedback(_ adblockLevel: String){
        self.removeAllViews()
        let consentView: UIView = UIView()
        consentView.frame = CGRect(x: 0.0, y: 0.0, width: self.adViewSize!.width, height: self.adViewSize!.height)
        consentView.backgroundColor = self.greyBackgroundColor
        
        let titleView = UILabel()
        titleView.text = "Thank you for reporting this to us. \nYour feedback will help us improve. \nThis ad by doceree will now be closed."
        
        titleView.font = titleView.font.withSize(textFontSize12)
        titleView.textColor = self.blackColor
        titleView.frame = consentView.frame
        titleView.center.x = consentView.center.x
        titleView.center.y = consentView.center.y
        titleView.textAlignment = .center
        titleView.lineBreakMode = .byWordWrapping
        titleView.numberOfLines = 3
        consentView.addSubview(titleView)
       
//        consentView.frame = adViewFrame!
//        rootViewController?.view.addSubview(consentView)
        consentView.frame = CGRect(x: .zero, y: .zero, width: adViewFrame!.width, height: adViewFrame!.height)
//        self.docereeAdView!.addSubview(consentView)
        
        if (!self.isRichMedia) {
        self.docereeAdView!.addSubview(consentView)
        } else {
//            self.docereeWebView!.addSubview(consentView!)

            for v in rootViewController!.view.subviews{
                v.removeFromSuperview()
            }
            consentView.frame = CGRect(x: .zero, y: .zero, width: adViewFrame!.width, height: adViewFrame!.height)
            self.rootViewController?.view.addSubview(consentView)
        }
        
        UIView.animate(withDuration: 3, delay: 0.5, options: .curveEaseIn, animations: {
            consentView.alpha = 0
        }) { [self] _ in
            self.docereeAdView?.refresh()
            if let plaformUid = NSKeyedUnarchiver.unarchiveObject(withFile: AdResponseForPlatform.ArchivingUrl.path) as? String{
                self.callAdBlockService(self.docereeAdView!.cbId!, adblockLevel, self.docereeAdView!.docereeAdUnitId, plaformUid)
            }
        }
    }
    
    @objc func whyThisClicked(_ sender: UITapGestureRecognizer){
        DocereeAdView.self.didLeaveAd = true
        let whyThisLink = "https://support.doceree.com/hc/en-us/articles/360050646094-Why-this-Ad-"
        let url = URL(string: whyThisLink)
        if url != nil && UIApplication.shared.canOpenURL(url!){
            UIApplication.shared.openURL(url!)
        }
    }
    
    @objc func reportAdClicked(_ sender: UITapGestureRecognizer){
        // open second consent screen
        loadConsentForm2()
    }
    
    @objc func backButtonClicked(_ sender: UITapGestureRecognizer){
        // back button pressed
        self.docereeAdView?.refresh()
        // remove this view and refresh ad
    }
    
    private func removeAllViews(){
        for v in self.consentView!.subviews{
            v.removeFromSuperview()
        }
    }
    
    private func refreshAdView(){
        self.docereeAdView?.removeFromSuperview()
//        self.docereeAdView?.removeAllViews()
//        self.docereeAdView?.refresh()
    }
    
    @objc func adCoveringContentClicked(_ sender: UITapGestureRecognizer){
        loadAdConsentFeedback(BlockLevel.AdCoveringContent.info.blockLevelCode)
    }
    
    @objc func adWasInappropriateClicked(_ sender: UITapGestureRecognizer){
        loadAdConsentFeedback(BlockLevel.AdWasInappropriate.info.blockLevelCode)
    }
    
    @objc func adNotInterestedClicked(_ sender: UITapGestureRecognizer){
        loadConsentForm3()
    }
    
    @objc func adNotInterestedClicked1(_ sender: UITapGestureRecognizer){
        loadAdConsentFeedback(BlockLevel.NotInterestedInCampaign.info.blockLevelCode)
    }
    
    @objc func adNotInterestedClicked2(_ sender: UITapGestureRecognizer){
        loadAdConsentFeedback(BlockLevel.NotInterestedInBrand.info.blockLevelCode)
    }
    
    @objc func adNotInterestedClicked3(_ sender: UITapGestureRecognizer){
        loadAdConsentFeedback(BlockLevel.NotInterestedInBrandType.info.blockLevelCode)
    }
    
    @objc func adNotInterestedClicked4(_ sender: UITapGestureRecognizer){
        loadAdConsentFeedback(BlockLevel.NotInterestedInClientType.info.blockLevelCode)
    }
    
    private func callAdBlockService(_ advertiserCampId: String?, _ blockLevel: String?, _ publisherACSID: String?, _ platformuid: String?){
        let restManager = RestManager()
        restManager.sendAdBlockRequest(advertiserCampId, blockLevel, platformuid, publisherACSID)
    }
    
    private func getAdTypeBySize(adSize: AdSize) -> AdType{
        let width: Int = Int(adSize.width)
        let height: Int = Int(adSize.height)
        let dimens: String = "\(width)x\(height)"
        switch dimens{
        case "320x50":
            return AdType.BANNER
        case "300x250":
            return AdType.MEDIUMRECTANGLE
        case "320x100":
            return AdType.LARGEBANNER
        case "468x60":
            return AdType.FULLSIZE
        case "728x90":
            return AdType.LEADERBOARD
        default:
            return AdType.INVALID
        }
    }
    
    // MARK: Horizontal Containers
    
    // MARK: Vertical Containers
    
    enum AdType{
        case BANNER
        case FULLSIZE
        case MEDIUMRECTANGLE
        case LEADERBOARD
        case LARGEBANNER
        case INVALID
    }
    
    enum BlockLevel{
        case AdCoveringContent
        case AdWasInappropriate
        case NotInterestedInCampaign
        case NotInterestedInBrand
        case NotInterestedInBrandType
        case NotInterestedInClientType
        
        var info: (blockLevelCode: String, blockLevelDesc: String){
            switch self{
            case .AdCoveringContent:
                return ("overlappingAd", "Ad is covering the content of the website.")
            case .AdWasInappropriate:
                return ("inappropriateAd", "Ad was inappropriate.")
            case .NotInterestedInCampaign:
                return ("notInterestedInCampaign", "I'm not interested in seeing ads for this product")
            case .NotInterestedInBrand:
                return ("notInterestedInBrand", "I'm not interested in seeing ads for this brand.")
            case .NotInterestedInBrandType:
                return ("notInterestedInBrandType", "I'm not interested in seeing ads for this category.")
            case .NotInterestedInClientType:
                return ("notInterestedInClientType", "I'm not interested in seeing ads from pharmaceutical brands.")
            }
        }
    }
}
