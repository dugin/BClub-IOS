//
//  FormViewControllerExtension.swift
//  bclub
//
//  Created by Bruno Gama on 31/05/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import Eureka

protocol KeyMappedForm {
    func setupForm(sections:[FormViewSection])
}

struct FormViewSection {
    var sectionId:String!
    var configurationFunction:((configurationObject:AnyObject?)->UIView?)?
    var rows:[FormViewRows]!
}

struct FormViewRows {
    var rowId:String!
    var configurationFunction:((configurationObject:AnyObject?)->UITableViewCell)!
}