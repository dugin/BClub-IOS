//
//  SearchParameters.swift
//  bclub
//
//  Created by Bruno Gama on 12/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

struct SearchParameters {
    var inputString:String = ""
    var weekdays:[Int] = []
    var establishmentCategories:[EstablishmentCategory] = []
    var discountList:[Double] = []
    var city:String = ""
}
