//
//  MenuCell.swift
//  bclub
//
//  Created by Bruno Gama on 08/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import Eureka
import SnapKit
import SwiftyColor

class MenuCell: Cell<String>, CellType {
    
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var button: UIButton!
    var cellAction:(()->Void)?
    
    override func setup() {
        super.setup()
        selectionStyle = .None
        height = { 44 }
    }
    
    @IBAction func buttonAction() {
        cellAction?()
    }
}

final class MenuRow: Row<String, MenuCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        
        displayValueFor = nil
        cellProvider = CellProvider<MenuCell>(nibName: MenuCell.nibName)
    }
}

