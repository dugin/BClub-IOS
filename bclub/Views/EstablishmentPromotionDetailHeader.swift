//
//  EstablishmentPromotionDetailHeader.swift
//  bclub
//
//  Created by Bruno Gama on 01/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import Eureka

class EstablishmentPromotionDetailHeaderCell: Cell<EstablishmentPromotion>, CellType {
    
    @IBOutlet weak var promotionImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var neighborhoodAndDistanceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func setup() {
        super.setup()
        
        selectionStyle = .None
    }
}



final class EstablishmentPromotionDetailHeaderRow: Row<EstablishmentPromotion, EstablishmentPromotionDetailHeaderCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        
        displayValueFor = nil
        cellProvider = CellProvider<EstablishmentPromotionDetailHeaderCell>(nibName: "EstablishmentPromotionDetailHeaderCell")
    }
    
}
