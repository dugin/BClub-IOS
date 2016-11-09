//
//  Establishment.swift
//  bclub
//
//  Created by Bruno Gama on 25/05/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

class Establishment:BackendlessEntity {
    var email:String?
    var detail:String?
    var name:String?
    var address:Address?
    var promotions:[Promotion]?
    var category:EstablishmentCategory?
    var telephones:[Telephone]?
}