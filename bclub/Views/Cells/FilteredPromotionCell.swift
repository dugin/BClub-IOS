//
//  FilteredPromotionCell.swift
//  bclub
//
//  Created by Bruno Gama on 03/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import Eureka
import SwiftyColor


final class FilteredPromotiontRow: Row<EstablishmentPromotion, FilteredPromotionCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        
        displayValueFor = nil
        cellProvider = CellProvider<FilteredPromotionCell>(nibName: FilteredPromotionCell.nibName)
    }
}

class FilteredPromotionCell: Cell<EstablishmentPromotion>, CellType {
    
    @IBOutlet weak var establishmentLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var promotionImage: UIImageView!
    var buttonActionBlock:(()->Void)?
    
    
    override func setup() {
        super.setup()
        
        selectionStyle = .None
    }
    @IBAction func buttonAction(sender: AnyObject) {
        buttonActionBlock?()
    }
}
