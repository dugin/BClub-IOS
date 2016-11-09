//
//  PromotioListLoadingView.swift
//  bclub
//
//  Created by Douglas on 09/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyColor

class PromotioListLoadingView: UIView {
    
    var backgroundImageView: UIImageView!
    var logoImageView: UIImageView!
    var descriptionLabel: UILabel!
    var dotsLoadingView: DotsLoadingView!
    
    convenience init() {
        self.init(frame: CGRectZero)
        
        setup()
    }
    
    // MARK: -
    
    func setup() {
        backgroundImageView = UIImageView()
        backgroundImageView.image = UIImage(named: "splash_image")
        backgroundImageView.accessibilityLabel = "splash_image"
        backgroundImageView.accessibilityIdentifier = "splash_image"
        addSubview(backgroundImageView)
        
        logoImageView = UIImageView()
        logoImageView.image = UIImage(named: "completeLogo")
        addSubview(logoImageView)

        descriptionLabel = UILabel()
        descriptionLabel.textAlignment = .Center
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textColor = Color.white
        descriptionLabel.font = UIFont(name: "OpenSans-Light", size:12)!
        descriptionLabel.text = "Buscando por estabelecimentos  próximos"
        
        addSubview(descriptionLabel)
        
        dotsLoadingView = DotsLoadingView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        
        dotsLoadingView.dotsColor = Color.bclRosyPinkColor()
        
        addSubview(dotsLoadingView)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        backgroundImageView.snp_makeConstraints { make in
            make.edges.equalTo(EdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
        
        logoImageView.snp_makeConstraints { make in
            make.top.equalTo(self.snp_top).offset(180)
            make.centerX.equalTo(self.snp_centerX)
        }
        
        descriptionLabel.snp_makeConstraints { make in
            make.top.equalTo(logoImageView.snp_bottom).offset(70)
            make.left.equalTo(self.snp_left).offset(80)
            make.right.equalTo(self.snp_right).offset(-80)
            make.centerX.equalTo(self.snp_centerX)
        }
        
        dotsLoadingView.snp_makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp_bottom)
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.centerX.equalTo(self.snp_centerX)
        }
    }

}
