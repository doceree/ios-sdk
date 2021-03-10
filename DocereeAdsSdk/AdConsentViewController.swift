//
//  AdConsentViewController.swift
//  DocereeAdsSdk
//
//  Created by dushyant pawar on 04/03/21.
//  Copyright © 2021 Doceree. All rights reserved.
//

import Foundation
import UIKit

class AdConsentViewController: UIViewController, UIApplicationDelegate{
    
    // MARK: private vars
    private var form1: UIView?
    private var form2: UIView?
    private var form3: UIView?
    
    private var verticalStackView: UIStackView?
    
    private var adViewSize: AdSize?
    
    private var frame: CGRect?
    private var rootViewController: UIViewController?
    
    // MARK: Initialize AdConsentUIView
    func initialize(parentViewController: UIViewController, adsize: AdSize, frame: CGRect){
        self.frame = frame
        self.adViewSize = adsize
        self.rootViewController = parentViewController
        loadConsentForm1()
    }

    // MARK: Load Consent form1
    private func loadConsentForm1(){
        // load back button
        
        let consentView: UIView = UIView()
        consentView.backgroundColor = UIColor(hexString: "#F2F2F2")
        self.parent?.view.addSubview(consentView)
        
        let lightConfiguration = UIImage.SymbolConfiguration(pointSize: 15, weight: .light, scale: .small)
        let backButtonUIImageView: UIImageView = UIImageView(image: UIImage(systemName: "arrow.backward", withConfiguration: lightConfiguration))
        backButtonUIImageView.contentMode = .scaleAspectFit
        backButtonUIImageView.tintColor = UIColor(hexString: "#6C40F7")
        backButtonUIImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        backButtonUIImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        let titleView = UILabel()
        titleView.text = "Ads by doceree"
        titleView.font = titleView.font.withSize(12)
        titleView.textColor = UIColor(hexString: "#6C40F7")
        titleView.widthAnchor.constraint(equalToConstant: self.frame!.width).isActive = true
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
        btnReportAd.widthAnchor.constraint(equalToConstant: self.frame!.width * 0.4).isActive = true
        btnReportAd.heightAnchor.constraint(equalToConstant: self.frame!.height/2).isActive = true
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
        btnWhyThisAd.widthAnchor.constraint(equalToConstant: self.frame!.width * 0.4).isActive = true
        btnWhyThisAd.heightAnchor.constraint(equalToConstant: self.frame!.height/2).isActive = true
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
        
        
        consentView.frame = frame!
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
        print("Clicked")
    }
    
    // MARK: Horizontal Containers
    
    // MARK: Vertical Containers
    
}

extension UIStackView {
    
    func addArrangedSubview(_ v:UIView, withMargin m:UIEdgeInsets )
    {
        let containerForMargin = UIView()
        containerForMargin.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: containerForMargin.topAnchor, constant:m.top ),
            v.bottomAnchor.constraint(equalTo: containerForMargin.bottomAnchor, constant: m.bottom ),
            v.leftAnchor.constraint(equalTo: containerForMargin.leftAnchor, constant: m.left),
            v.rightAnchor.constraint(equalTo: containerForMargin.rightAnchor, constant: m.right)
        ])
        
        addArrangedSubview(containerForMargin)
    }
}
