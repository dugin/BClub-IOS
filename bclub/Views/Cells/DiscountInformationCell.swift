//
//  DiscountInformationCell.swift
//  bclub
//
//  Created by Bruno Gama on 01/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

import Eureka

class DiscountInformationCell: Cell<Promotion>, CellType {
    
    @IBOutlet weak var disccountLabel:UILabel!
    @IBOutlet weak var informationLabel:UILabel!
    
    override func setup() {
        super.setup()
        
        selectionStyle = .None
    }
}



final class DiscountInformationRow: Row<Promotion, DiscountInformationCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        
        displayValueFor = nil
        cellProvider = CellProvider<DiscountInformationCell>(nibName: "DiscountInformationCell")
    }
    
}
