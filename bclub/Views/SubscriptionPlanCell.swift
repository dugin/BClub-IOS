//
//  SubscriptionPlanCell.swift
//  bclub
//
//  Created by Bruno Gama on 09/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

class SubscriptionPlanCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var planDescriptionLabel: UILabel!
    @IBOutlet weak var gotoActionLabel: UILabel!
    
    var subscriptionPlan:SubscriptionPlan? {
        didSet {
            self.configureCell(subscriptionPlan!)
        }
    }
    
    func configureCell(subscriptionPlan:SubscriptionPlan) {
        titleLabel.text = subscriptionPlan.title
        planDescriptionLabel.text = subscriptionPlan.summarization
        gotoActionLabel.text = subscriptionPlan.gotoAction.uppercaseString
        priceLabel.attributedText = attributedPrice(subscriptionPlan.price)
        priceLabel.hidden = (subscriptionPlan.recurrence == .None)
    }
    
    func fontAttributeWithSize(size:CGFloat)->[String:AnyObject] {
        let fontName = "OpenSans-SemiboldItalic"
        return [NSFontAttributeName: UIFont(name: fontName, size:size)!,
                NSForegroundColorAttributeName: UIColor.bclRosyPinkColor()]
    }
    
    func attributedPrice(price:Double) -> NSAttributedString {
        let currencySize:CGFloat = 24.0
        let finalSize:CGFloat = 48.0
        let str = NSMutableAttributedString()
        let currencyString = NSAttributedString(string:"R$ ", attributes:fontAttributeWithSize(currencySize))
        str.appendAttributedString(currencyString)
        let priceTagString = NSAttributedString(string:"\(String(Int(price))),ºº", attributes: fontAttributeWithSize(finalSize))
        str.appendAttributedString(priceTagString)
        return str
    }
}