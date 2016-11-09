//
//  EstablishmentPromotionContent.swift
//  bclub
//
//  Created by Bruno Gama on 01/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import SwiftyColor
import PhoneNumberKit

struct EstablishmentPromotionContent {
    let fontName = "OpenSans-Light"
    let boldFontName = "OpenSans"
    var establismentPromotions:EstablishmentPromotion?
    
    init(_ establishmentPromotions:EstablishmentPromotion) {
        self.establismentPromotions = establishmentPromotions
    }
    
    private func headerAttributes() -> [String:AnyObject!] {
        let fontSize:CGFloat = 19.0
        return [NSFontAttributeName:UIFont(name: boldFontName, size:fontSize)!, NSForegroundColorAttributeName: 0xFCFCFC~]
    }
    
    private func sundayMondaNoonAttribytes() -> [String:AnyObject!] {
        let fontSize:CGFloat = 16.0
        return [NSFontAttributeName:UIFont(name: fontName, size:fontSize)!, NSForegroundColorAttributeName: 0x888B8D~]
    }
    
    private func textAttributes() -> [String:AnyObject!] {
        let fontSize:CGFloat = 15.0
        return [NSFontAttributeName:UIFont(name: fontName, size:fontSize)!, NSForegroundColorAttributeName: UIColor.bclTextColor()]
    }
    
    private func establismentDetail() -> NSMutableAttributedString {
        let atttributedString = NSMutableAttributedString()
        atttributedString.appendAttributedString(NSAttributedString(string:"DESCRIÇÃO\n", attributes: headerAttributes()))
        if let detail = establismentPromotions?.establishment?.detail {
            atttributedString.appendAttributedString(NSAttributedString(string:detail, attributes: textAttributes()))
        }
        
        return atttributedString
    }
    
    private func restrictionTextParagraph() -> NSMutableAttributedString {
        let atttributedString = NSMutableAttributedString()
        atttributedString.appendAttributedString(NSAttributedString(string:"RESTRIÇÕES\n", attributes: headerAttributes()))
        if let restriction = establismentPromotions?.restriction {
            atttributedString.appendAttributedString(NSAttributedString(string:restriction, attributes: textAttributes()))
        }
        
        return atttributedString
    }
    
    private func contactTextParagraph() -> NSMutableAttributedString {
        let atttributedString = NSMutableAttributedString()
        atttributedString.appendAttributedString(NSAttributedString(string:"CONTATO\n", attributes: headerAttributes()))
        
        var contact = ""
        if let address = establismentPromotions?.establishment?.address {
            contact = address.description + "\n"
        }
        
        if let telephones = establismentPromotions?.establishment?.telephones {
            let formatter = PartialFormatter(defaultRegion: "BR")
            contact +=  telephones.map{  formatter.formatPartial($0.number!) }.joinWithSeparator("\n")
        }
        
        atttributedString.appendAttributedString(NSAttributedString(string:contact, attributes: textAttributes()))
        
        return atttributedString
    }
    
    func paragraphData() -> [NSMutableAttributedString] {
        var paragraphs = [NSMutableAttributedString]()
        paragraphs.append(establismentDetail())
        if let restriction = establismentPromotions?.restriction {
            if !restriction.isEmpty {
                paragraphs.append(restrictionTextParagraph())
            }
        }
        paragraphs.append(contactTextParagraph())
        return paragraphs
    }
}