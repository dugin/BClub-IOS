//
//  InputFilterCell.swift
//  bclub
//
//  Created by Bruno Gama on 03/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import Eureka
import QuartzCore
import SwiftyColor
final class InputFilterCellRow: Row<String, InputFilterCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        
        displayValueFor = nil
        cellProvider = CellProvider<InputFilterCell>(nibName: InputFilterCell.nibName)
    }
}


class InputFilterCell: Cell<String>, CellType, UITextFieldDelegate {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var containerView: UIView!        

    var searchButtonAction:((typedSearch:String)->Void)?
   
    override func setup() {
        super.setup()
        
        selectionStyle = .None
        let layer = containerView.layer
        layer.borderColor = UIColor.bclRosyPinkColor().CGColor
        layer.borderWidth = 1
        layer.cornerRadius = 0
        
        if let placeholder = searchTextField.placeholder {
            searchTextField.attributedPlaceholder = NSAttributedString(string:placeholder, attributes: [NSForegroundColorAttributeName: Color.bclWarmGreyColor(), NSFontAttributeName: UIFont(name: "OpenSans-Light", size:15)!])
        }
        
        searchTextField.delegate = self
    }

    
    @IBAction func buttonClick(sender: AnyObject) {
        searchButtonAction!(typedSearch: searchTextField.text!)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchButtonAction!(typedSearch: searchTextField.text!)
            return false
        }
        return true
    }
}
