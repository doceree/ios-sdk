//
//  AdConsentUIView.swift
//  DocereeAdsSdk
//
//  Created by dushyant pawar on 09/03/21.
//  Copyright © 2021 Doceree. All rights reserved.
//

import UIKit

class AdConsentUIView: UIView {
    
    // MARK: private vars
    private var form1: UIView?
    private var form2: UIView?
    private var form3: UIView?
    
    private var horizontalStackView: UIStackView?
    private var verticalStackView: UIStackView?
    
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
    
    convenience init?(with adSize: AdSize, frame: CGRect, rootVC: UIViewController){
        self.init()
        adViewSize = adSize
        adViewFrame = frame
        rootViewController = rootVC
        loadConsentForm1()
    }
        
    // MARK: Initialize AdConsentUIView
    
    // MARK: Horizontal Containers
    
    // MARK: Vertical Containers
    
    // MARK: Load Consent form1
    private func loadConsentForm1(){
        // load back button
        
        let consentView: UIView = UIView()
        consentView.backgroundColor = UIColor(hexString: "#F2F2F2")
//        self.parent?.view.addSubview(consentView)
        
        let lightConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .light, scale: .small)
        let backButtonUIImageView: UIImageView = UIImageView(image: UIImage(systemName: "arrow.backward", withConfiguration: lightConfiguration))
        backButtonUIImageView.contentMode = .scaleAspectFit
        backButtonUIImageView.tintColor = UIColor(hexString: "#6C40F7")
        backButtonUIImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        backButtonUIImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        backButtonUIImageView.isUserInteractionEnabled = true
        let backButtonUITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backButtonClicked))
        backButtonUIImageView.addGestureRecognizer(backButtonUITapGestureRecognizer)
        
        let titleView = UILabel()
        titleView.text = "Ads by doceree"
        titleView.font = titleView.font.withSize(12)
        titleView.textColor = UIColor(hexString: "#6C40F7")
        titleView.widthAnchor.constraint(equalToConstant: self.adViewFrame!.width).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        titleView.textAlignment = .center
        
        // horizontal stackview 1
        let horizontalStackView1 = UIStackView()
        horizontalStackView1.axis = .horizontal
        horizontalStackView1.distribution = UIStackView.Distribution.equalSpacing
        horizontalStackView1.alignment = .fill
        
        horizontalStackView1.addArrangedSubview(backButtonUIImageView)
        horizontalStackView1.addArrangedSubview(titleView)
        horizontalStackView1.translatesAutoresizingMaskIntoConstraints = false
        
        consentView.addSubview(horizontalStackView1)
        
        let lightConfigurationWithSmallScale = UIImage.SymbolConfiguration(pointSize: 13, weight: .light, scale: .small)
        
        let btnReportAd = UIButton()
        btnReportAd.setTitle("Report this Ad", for: .normal)
        btnReportAd.widthAnchor.constraint(equalToConstant: self.adViewFrame!.width * 0.4).isActive = true
        btnReportAd.heightAnchor.constraint(equalToConstant: self.adViewFrame!.height/2).isActive = true
        btnReportAd.setTitleColor(UIColor(hexString: "#000000"), for: .normal)
        btnReportAd.backgroundColor = UIColor(hexString: "#FFFFFF")
        btnReportAd.titleLabel?.font = .systemFont(ofSize: 12) // UIFont(name: YourfontName, size: 12)
        btnReportAd.translatesAutoresizingMaskIntoConstraints = false
        btnReportAd.isUserInteractionEnabled = true
        let adReportTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(reportAdClicked))
        btnReportAd.addGestureRecognizer(adReportTapGestureRecognizer)
        
        let btnWhyThisAd = UIButton()
        btnWhyThisAd.setTitle("Why this Ad?", for: .normal)
        let infoImage = UIImage(systemName: "info.circle", withConfiguration: lightConfigurationWithSmallScale)
        infoImage?.withTintColor(UIColor(hexString: "#6C40F7"))
        btnWhyThisAd.setImage(infoImage, for: .normal)
        btnWhyThisAd.widthAnchor.constraint(equalToConstant: self.adViewFrame!.width * 0.4).isActive = true
        btnWhyThisAd.heightAnchor.constraint(equalToConstant: self.adViewFrame!.height/2).isActive = true
        btnWhyThisAd.setTitleColor(UIColor(hexString: "#000000"), for: .normal)
        btnWhyThisAd.backgroundColor = UIColor(hexString: "#FFFFFF")
        btnWhyThisAd.titleLabel?.font = .systemFont(ofSize: 12) // UIFont(name: YourfontName, size: 12)
        btnWhyThisAd.semanticContentAttribute = .forceRightToLeft
        btnWhyThisAd.translatesAutoresizingMaskIntoConstraints = false
        btnWhyThisAd.isUserInteractionEnabled = true
        let whyThisTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(whyThisClicked))
        btnWhyThisAd.addGestureRecognizer(whyThisTapGestureRecognizer)
        
        //         horizontal stackview 2
        let horizontalStackView2 = UIStackView()
        horizontalStackView2.axis = .horizontal
        horizontalStackView2.distribution = .fill
        horizontalStackView2.alignment = .center
        horizontalStackView2.spacing = 8.0
        horizontalStackView2.addArrangedSubview(btnReportAd)
        horizontalStackView2.addArrangedSubview(btnWhyThisAd)
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
        
        consentView.addSubview(verticalStackView!)
        
        verticalStackView!.topAnchor.constraint(equalTo: consentView.topAnchor, constant: 0).isActive = true
        verticalStackView!.bottomAnchor.constraint(equalTo: consentView.bottomAnchor, constant: 0).isActive = true
        verticalStackView!.leadingAnchor.constraint(equalTo: consentView.leadingAnchor, constant: 0).isActive = true
        verticalStackView!.trailingAnchor.constraint(equalTo: consentView.trailingAnchor, constant: 0).isActive = true
        
        
        consentView.frame = adViewFrame!
        rootViewController?.view.addSubview(consentView)
    }
    
    // MARK: Load Consent form2
    private func loadConsentForm2(){
        // load back button
        
        let consentView: UIView = UIView()
        consentView.backgroundColor = UIColor(hexString: "#F2F2F2")
//        self.parent?.view.addSubview(consentView)
        
        // add scrollview here
//        let scrollView = UIScrollView()
        
        let btnAdCoveringContent = UIButton()
        btnAdCoveringContent.setTitle("Ad is covering the content of the website.", for: .normal)
        btnAdCoveringContent.widthAnchor.constraint(equalToConstant: self.adViewFrame!.width * 0.3).isActive = true
        btnAdCoveringContent.heightAnchor.constraint(equalToConstant: self.adViewFrame!.height * 0.8).isActive = true
        btnAdCoveringContent.setTitleColor(UIColor(hexString: "#000000"), for: .normal)
        btnAdCoveringContent.backgroundColor = UIColor(hexString: "#FFFFFF")
        btnAdCoveringContent.titleLabel?.lineBreakMode = .byWordWrapping
        btnAdCoveringContent.titleLabel?.textAlignment = .center
        btnAdCoveringContent.titleLabel?.font = .systemFont(ofSize: 10) // UIFont(name: YourfontName, size: 12)
        btnAdCoveringContent.translatesAutoresizingMaskIntoConstraints = false
        btnAdCoveringContent.isUserInteractionEnabled = true
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(adCoveringContentClicked))
        btnAdCoveringContent.addGestureRecognizer(tap1)
        
        let btnAdInappropriate = UIButton()
        btnAdInappropriate.setTitle("Ad was inappropriate.", for: .normal)
        btnAdInappropriate.widthAnchor.constraint(equalToConstant: self.adViewFrame!.width * 0.3).isActive = true
        btnAdInappropriate.heightAnchor.constraint(equalToConstant: self.adViewFrame!.height * 0.8).isActive = true
        btnAdInappropriate.setTitleColor(UIColor(hexString: "#000000"), for: .normal)
        btnAdInappropriate.backgroundColor = UIColor(hexString: "#FFFFFF")
        btnAdInappropriate.titleLabel?.lineBreakMode = .byWordWrapping
        btnAdInappropriate.titleLabel?.textAlignment = .center
        btnAdInappropriate.titleLabel?.font = .systemFont(ofSize: 10) // UIFont(name: YourfontName, size: 12)
        btnAdInappropriate.translatesAutoresizingMaskIntoConstraints = false
        btnAdInappropriate.isUserInteractionEnabled = true
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(adWasInappropriateClicked))
        btnAdInappropriate.addGestureRecognizer(tap2)
        
        let btnAdNotInterested = UIButton()
        btnAdNotInterested.setTitle("Not interested in this ad.", for: .normal)
        btnAdNotInterested.widthAnchor.constraint(equalToConstant: self.adViewFrame!.width * 0.3).isActive = true
        btnAdNotInterested.heightAnchor.constraint(equalToConstant: self.adViewFrame!.height * 0.8).isActive = true
        btnAdNotInterested.setTitleColor(UIColor(hexString: "#000000"), for: .normal)
        btnAdNotInterested.backgroundColor = UIColor(hexString: "#FFFFFF")
        btnAdNotInterested.titleLabel?.lineBreakMode = .byWordWrapping
        btnAdNotInterested.titleLabel?.textAlignment = .center
        btnAdNotInterested.titleLabel?.font = .systemFont(ofSize: 10) // UIFont(name: YourfontName, size: 12)
        btnAdNotInterested.translatesAutoresizingMaskIntoConstraints = false
        btnAdNotInterested.isUserInteractionEnabled = true
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(adNotInterestedClicked))
        btnAdNotInterested.addGestureRecognizer(tap3)
        
        // horizontal stackview 2
        let horizontalStackView2 = UIStackView()
        horizontalStackView2.axis = .horizontal
        horizontalStackView2.distribution = .fillEqually
        horizontalStackView2.alignment = .center
        horizontalStackView2.spacing = 4.0
        horizontalStackView2.addArrangedSubview(btnAdCoveringContent)
        horizontalStackView2.addArrangedSubview(btnAdInappropriate)
        horizontalStackView2.addArrangedSubview(btnAdNotInterested)
        horizontalStackView2.translatesAutoresizingMaskIntoConstraints = false
        
        consentView.addSubview(horizontalStackView2)
        
        horizontalStackView2.topAnchor.constraint(equalTo: consentView.topAnchor, constant: 0).isActive = true
        horizontalStackView2.bottomAnchor.constraint(equalTo: consentView.bottomAnchor, constant: 0).isActive = true
        horizontalStackView2.leadingAnchor.constraint(equalTo: consentView.leadingAnchor, constant: 4).isActive = true
        horizontalStackView2.trailingAnchor.constraint(equalTo: consentView.trailingAnchor, constant: -4).isActive = true
        
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.addSubview(horizontalStackView2)
//        horizontalStackView2.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0).isActive = true
//        horizontalStackView2.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0).isActive = true
//        horizontalStackView2.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0).isActive = true
//        horizontalStackView2.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0).isActive = true
//
//        consentView.addSubview(scrollView)
//
//
//        horizontalStackView2.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
//        horizontalStackView2.widthAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true

        
        consentView.frame = adViewFrame!
        rootViewController?.view.addSubview(consentView)
    }
    
    // MARK: Load Consent form3
    private func loadConsentForm3(){
        // load back button
        
        let consentView: UIView = UIView()
        consentView.backgroundColor = UIColor(hexString: "#F2F2F2")
//        self.parent?.view.addSubview(consentView)
        
        let btn1 = UIButton()
        btn1.setTitle("I'm not interested\n in seeing ads for this product.", for: .normal)
        btn1.widthAnchor.constraint(equalToConstant: self.adViewFrame!.width * 0.4).isActive = true
        btn1.heightAnchor.constraint(equalToConstant: self.adViewFrame!.height/2).isActive = true
        btn1.setTitleColor(UIColor(hexString: "#000000"), for: .normal)
        btn1.backgroundColor = UIColor(hexString: "#FFFFFF")
        btn1.titleLabel?.lineBreakMode = .byWordWrapping
        btn1.titleLabel?.textAlignment = .center
        btn1.titleLabel?.font = .systemFont(ofSize: 12) // UIFont(name: YourfontName, size: 12)
        btn1.translatesAutoresizingMaskIntoConstraints = false
        btn1.isUserInteractionEnabled = true
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(adNotInterestedClicked1))
        btn1.addGestureRecognizer(tap1)
        
        let btn2 = UIButton()
        btn2.setTitle("I'm not interested\n in seeing ads for this brand.", for: .normal)
        btn2.widthAnchor.constraint(equalToConstant: self.adViewFrame!.width * 0.4).isActive = true
        btn2.heightAnchor.constraint(equalToConstant: self.adViewFrame!.height/2).isActive = true
        btn2.setTitleColor(UIColor(hexString: "#000000"), for: .normal)
        btn2.backgroundColor = UIColor(hexString: "#FFFFFF")
        btn2.titleLabel?.lineBreakMode = .byWordWrapping
        btn2.titleLabel?.textAlignment = .center
        btn2.titleLabel?.font = .systemFont(ofSize: 12) // UIFont(name: YourfontName, size: 12)
        btn2.translatesAutoresizingMaskIntoConstraints = false
        btn2.isUserInteractionEnabled = true
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(adNotInterestedClicked2))
        btn2.addGestureRecognizer(tap2)
        
        let btn3 = UIButton()
        btn3.setTitle("I'm not interested\n in seeing ads for this category.", for: .normal)
        btn3.widthAnchor.constraint(equalToConstant: self.adViewFrame!.width * 0.4).isActive = true
        btn3.heightAnchor.constraint(equalToConstant: self.adViewFrame!.height/2).isActive = true
        btn3.setTitleColor(UIColor(hexString: "#000000"), for: .normal)
        btn3.backgroundColor = UIColor(hexString: "#FFFFFF")
        btn3.titleLabel?.lineBreakMode = .byWordWrapping
        btn3.titleLabel?.textAlignment = .center
        btn3.titleLabel?.font = .systemFont(ofSize: 12) // UIFont(name: YourfontName, size: 12)
        btn3.translatesAutoresizingMaskIntoConstraints = false
        btn3.isUserInteractionEnabled = true
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(adNotInterestedClicked3))
        btn3.addGestureRecognizer(tap3)
        
        let btn4 = UIButton()
        btn4.setTitle("I'm not interested in\n seeing ads from pharmaceutical brands.", for: .normal)
        btn4.widthAnchor.constraint(equalToConstant: self.adViewFrame!.width * 0.4).isActive = true
        btn4.heightAnchor.constraint(equalToConstant: self.adViewFrame!.height/2).isActive = true
        btn4.setTitleColor(UIColor(hexString: "#000000"), for: .normal)
        btn4.backgroundColor = UIColor(hexString: "#FFFFFF")
        btn4.titleLabel?.lineBreakMode = .byWordWrapping
        btn4.titleLabel?.textAlignment = .center
        btn4.titleLabel?.font = .systemFont(ofSize: 12) // UIFont(name: YourfontName, size: 12)
        btn4.translatesAutoresizingMaskIntoConstraints = false
        btn4.isUserInteractionEnabled = true
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(adNotInterestedClicked4))
        btn4.addGestureRecognizer(tap4)
        
        // horizontal stackview 2
        let horizontalStackView2 = UIStackView()
        horizontalStackView2.axis = .horizontal
        horizontalStackView2.distribution = .fillEqually
        horizontalStackView2.alignment = .center
        horizontalStackView2.spacing = 8.0
        horizontalStackView2.addArrangedSubview(btn1)
        horizontalStackView2.addArrangedSubview(btn2)
        horizontalStackView2.addArrangedSubview(btn3)
        horizontalStackView2.addArrangedSubview(btn4)
        horizontalStackView2.translatesAutoresizingMaskIntoConstraints = false
        
        consentView.addSubview(horizontalStackView2)
        
        horizontalStackView2.topAnchor.constraint(equalTo: consentView.topAnchor, constant: 0).isActive = true
        horizontalStackView2.bottomAnchor.constraint(equalTo: consentView.bottomAnchor, constant: 0).isActive = true
        horizontalStackView2.leadingAnchor.constraint(equalTo: consentView.leadingAnchor, constant: 0).isActive = true
        horizontalStackView2.trailingAnchor.constraint(equalTo: consentView.trailingAnchor, constant: 0).isActive = true
        
        
        consentView.frame = adViewFrame!
        rootViewController?.view.addSubview(consentView)
    }
    
    // load feedback
    private func loadAdConsentFeedback(){
        let consentView: UIView = UIView()
        consentView.backgroundColor = UIColor(hexString: "#F2F2F2")
        
        let titleView = UILabel()
        titleView.text = "Thank you for reporting this to us.\n Your feedback will help us improve.\n This ad by doceree will now be closed."
        titleView.font = titleView.font.withSize(12)
        titleView.textColor = UIColor(hexString: "#000000")
        titleView.frame = CGRect(x: consentView.center.x, y: consentView.center.y, width: titleView.intrinsicContentSize.width, height: titleView.intrinsicContentSize.height)
        titleView.textAlignment = .center
        
        consentView.addSubview(titleView)
        consentView.frame = adViewFrame!
        rootViewController?.view.addSubview(consentView)
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
        // remove this view and refresh ad
    }
    
    @objc func adCoveringContentClicked(_ sender: UITapGestureRecognizer){
    }
    
    @objc func adWasInappropriateClicked(_ sender: UITapGestureRecognizer){
    }
    
    @objc func adNotInterestedClicked(_ sender: UITapGestureRecognizer){
        loadConsentForm3()
    }
    
    @objc func adNotInterestedClicked1(_ sender: UITapGestureRecognizer){
    }
    
    @objc func adNotInterestedClicked2(_ sender: UITapGestureRecognizer){
    }
    
    @objc func adNotInterestedClicked3(_ sender: UITapGestureRecognizer){
    }
    
    @objc func adNotInterestedClicked4(_ sender: UITapGestureRecognizer){
    }
    
    private func getLayoutOrientation(var adSize: AdSize){
    }
    
    // MARK: Horizontal Containers
    
    // MARK: Vertical Containers
    
}

