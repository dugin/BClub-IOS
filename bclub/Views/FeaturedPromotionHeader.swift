//
//  FeaturedPromotionHeader.swift
//  bclub
//
//  Created by Bruno Gama on 26/05/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import Nuke

class FeaturedPromotionHeader:UIView {
    @IBOutlet weak var promotionImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    var parentController: PromotionListVC!
    var promotion:EstablishmentPromotion! {
        didSet {
            if let imageUrl = promotion.imageUrl {
                let url  = NSURL(string:imageUrl)

                if url != nil {
                    promotionImageView.image = nil
                    promotionImageView.nk_setImageWith(url!)
                }
            }
            
            let attrStr = NSMutableAttributedString(attributedString: titleLabel.attributedText!)
            attrStr.replaceCharactersInRange(NSRange(location: 0, length: 4), withString: (promotion?.establishment?.name)!)
            titleLabel.attributedText = attrStr
            if let promotions = promotion?.promotions {
                configureDiscountLabel(promotions)
            }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(FeaturedPromotionHeader.handleTap(_:)))
            self.addGestureRecognizer(tap)
        }
    }
    
    func handleTap(gestureRecognizer: UIGestureRecognizer) {
        parentController.performSegueWithIdentifier(parentController.kSegueEstablishmentFeaturedPromotionDetail, sender: self)
    }
    
    private func configureDiscountLabel(promotions:[Promotion]!) {
        var discount = ""
        for p in promotions {
            discount = discount + " - \(Int(p.percent as Double * 100))"
        }
        discount = discount + "%"
        
        if discount.characters.count > 3 {
            let index:String.Index = discount.startIndex.advancedBy(3)
            discountLabel.text = discount.substringFromIndex(index)
        }
        else {
            discountLabel.text = discount
        }
    }
    
}