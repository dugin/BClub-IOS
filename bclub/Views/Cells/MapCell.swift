//
//  MapCell.swift
//  bclub
//
//  Created by Bruno Gama on 02/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

import Eureka

class MapCell: Cell<Establishment>, CellType {
    
    
    @IBOutlet weak var mapView: MKMapView!
    override func setup() {
        super.setup()
        
        selectionStyle = .None
    }
}



final class MapRow: Row<Establishment, MapCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        
        displayValueFor = nil
        cellProvider = CellProvider<MapCell>(nibName: MapCell.nibName)
    }
}
