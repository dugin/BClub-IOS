//
//  CityFilterProtocol.swift
//  bclub
//
//  Created by Bruno Gama on 03/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

protocol CityFilterDelegate:class {
    func selectedCity(city:City) -> Void
}