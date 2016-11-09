//
//  ConfigurableSchemaName.swift
//  bclub
//
//  Created by Bruno Gama on 25/05/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import Pluralize_swift

protocol ConfigurableSchemaName {}

extension BackendlessEntity: ConfigurableSchemaName {}
extension ConfigurableSchemaName {
    static func schemaName()->String {
        return "\(self)".pluralize()
    }
}