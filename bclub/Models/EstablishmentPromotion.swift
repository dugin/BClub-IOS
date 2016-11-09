//
//  EstablishmentPromotion.swift
//  bclub
//
//  Created by Bruno Gama on 26/05/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

class EstablishmentPromotion:BackendlessEntity {
    var night:NSNumber?
    var active:NSNumber?
    var restriction:String?
    var featuredDate:NSDate?
    var afternoon:NSNumber?
    var imageUrl:String?
    var morning:NSNumber?
    var promotions:[Promotion]?
    var establishment:Establishment?
}

protocol MinMaxDiscountPercentage {}
extension EstablishmentPromotion: MinMaxDiscountPercentage{
    func getMinMax() -> (min:Int, max:Int) {
        let percentList = promotions?.map{ Int(Double($0.percent) * 100) }
        if percentList?.count > 1 {
            let min = percentList!.minElement()
            let max = percentList!.maxElement()
            return (min:min!, max:max!)
        } else if percentList?.count == 1 {
            return (min:0, max:percentList!.first!)
        } else {
            return (min:0, max:0)
        }
    }
}