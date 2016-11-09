//
//  CheckBoxCell.swift
//  bclub
//
//  Created by Bruno Gama on 03/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import Eureka

final class CheckBoxRow: Row<Int, CheckBoxCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        
        displayValueFor = nil
        cellProvider = CellProvider<CheckBoxCell>(nibName: "CheckBoxCell")
    }
}


class CheckBoxCell: Cell<Int>, CellType {
    
    var checked:Bool?
    private lazy var checkedImage = { return UIImage(named: "checked") }()
    private lazy var  uncheckedImage = { return UIImage(named: "unchecked") }()
    var buttonClickCallback:((cell:CheckBoxCell)->Void)?
    
    @IBOutlet weak private var checkBoxImage: UIImageView!
    @IBOutlet weak private var checkBoxLabel: UILabel!
    
    @IBAction func buttonClick(sender: AnyObject) {
        buttonClickCallback?(cell: self)
        let newValue = !isChecked()
        setChecked(newValue)
        checked = newValue
    }
    
    func setChecked(checked:Bool) {
        checkBoxImage?.image = UIImage(named:(checked) ? "checked" : "unchecked")
    }
    
    var checkBoxText:String? {
        didSet {
            checkBoxLabel.text = checkBoxText
        }
    }
    
    func isChecked() -> Bool {
        return checked!
    }
    
    override func setup() {
        super.setup()
        checked = true
        selectionStyle = .None
    }
}
