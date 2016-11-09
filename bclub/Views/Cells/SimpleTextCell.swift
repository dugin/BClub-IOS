//
//  SimpleTextCell.swift
//  bclub
//
//  Created by Bruno Gama on 31/05/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import Eureka

class SimpleTextCell: Cell<String>, CellType {
    
    @IBOutlet weak var label: UITextView!

    override func setup() {
        super.setup()
        
        selectionStyle = .None
        label.linkTextAttributes = [NSForegroundColorAttributeName : UIColor.bclRosyPinkColor(), NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue]

    }
}



final class SimpleTextRow: Row<String, SimpleTextCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        
        displayValueFor = nil
        cellProvider = CellProvider<SimpleTextCell>(nibName: SimpleTextCell.nibName)
    }
    
}
