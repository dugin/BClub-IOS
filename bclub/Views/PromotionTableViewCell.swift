//
//  PromotionTableViewCell.swift
//  bclub
//
//  Created by Bruno Gama on 24/05/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import SwiftyColor
import Nuke

class PromotionTableViewCell: UITableViewCell {
    @IBOutlet weak var promotionImageView: UIImageView!
    @IBOutlet weak var establishmentNameLabel: UILabel!
    @IBOutlet weak var establishmentTypeLabel: UILabel!
    @IBOutlet weak var establishmentLocalizationLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var weekdaysView: WeekdaysView!
    
    var establishmentPromotion:EstablishmentPromotion? {
        didSet {
            establishmentNameLabel.text = establishmentPromotion?.establishment?.name?.uppercaseString
            establishmentTypeLabel.text = establishmentPromotion?.establishment?.category?.name
            
            if let imageUrl = establishmentPromotion?.imageUrl {
                let url  = NSURL(string:imageUrl)
                if url != nil {
                    self.promotionImageView.image = nil
                    self.promotionImageView.nk_setImageWith(url!)
                }
            }
            
            
            if let promotions = establishmentPromotion?.promotions {
                configureDiscountLabel()
                configureWeekDays(promotions)
            }

            configureLocalizationInformation(establishmentPromotion?.establishment?.address?.neighborhood?.name)
        }
    }
    
    var currentLocation:CLLocation? {
        didSet {
            if currentLocation != nil && establishmentPromotion != nil {
                configureLocalizationInformation(establishmentPromotion?.establishment?.address?.neighborhood?.name)
            }
        }
    }

    private func configureDiscountLabel() {
        var formattedDiscount = ""
        let (min, max) = (establishmentPromotion?.getMinMax())!
        formattedDiscount =  min == 0 ? "\(max)%" : "\(min) - \(max)%"
        discountLabel.text = formattedDiscount
        discountLabel.superview?.hidden = min == 0 && max == 0
    }
    
    private func configureWeekDays(promotions:[Promotion]!) {
        var weekdayTimetable = timeTable(Promotion())
        
        for p in promotions {
            for (index, element) in timeTable(p).enumerate() {
                weekdayTimetable[index] += element
            }
        }
        
        weekdaysView.weekdays = weekdayTimetable.map{ (!$0.isBlank) ? true : false }
    }
    
    
    func timeTable(promotion:Promotion) -> [String]! {
        return [promotion.monday,
                promotion.tuesday,
                promotion.wednesday,
                promotion.thursday,
                promotion.friday,
                promotion.saturday,
                promotion.sunday]
    }
    
    private func configureLocalizationInformation(neighborhood:String!) {
        var localizationInformation = neighborhood
        if currentLocation != nil {
            if let toGeoPoint = establishmentPromotion?.establishment?.address?.geolocation {
                let roundedTwoDigit = self.currentLocation?.distanceFromGeoPoint(toGeoPoint)
                localizationInformation = "\(neighborhood) - \(roundedTwoDigit!) Km"
            }
        }
        
        establishmentLocalizationLabel.text = localizationInformation
    }
}