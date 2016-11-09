//
//  UserProfileDetailedView.swift
//  bclub
//
//  Created by Bruno Gama on 17/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import SwiftyColor
import QuartzCore

class UserProfileDetailedView : UIView {
    
    
    @IBOutlet weak var expirationTextField: UITextField!
    @IBOutlet weak var activatedTextField: UITextField!
    @IBOutlet weak var installmentTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    // MARK: - PRIVATE METHODS -
    
    func configure() {
        setupTextFields()
    }
    
    func setupTextFields() {
        let textFields = [activatedTextField, expirationTextField, installmentTextField]
        
        for textField in textFields {
            let layer = textField.layer
            layer.borderColor = Color.bclNeighborhoodTextColor().CGColor
            layer.borderWidth = 1
            layer.cornerRadius = 0
            
            let paddingView = UIView(frame: CGRectMake(0, 0, 10, textField.frame.height))
            textField.leftView = paddingView
            textField.leftViewMode = UITextFieldViewMode.Always
            textField.enabled = false
        }
    }
}