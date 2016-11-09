//  SignUpVoucherVC.swift
//
//  bclub
//
//  Created by Douglas on 13/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import SwiftyColor
import MRProgress

class SignUpVoucherVC: UIViewController, FetchableContentProtocol {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var voucherCodeTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    let apiClient = ApiClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllerValues()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        voucherCodeTextField.becomeFirstResponder()
    }
    
    func dismissKeyboard() {
        UIView.animateWithDuration(0.25) {
            self.scrollView.contentOffset = CGPointZero
        }
        view.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! PersonalDataVC
        vc.email = emailTextField.text!
        vc.voucher = voucherCodeTextField.text!
    }
    
    // MARK: - PRIVATE METHODS -
    
    private func setupControllerValues() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let textFields = [voucherCodeTextField, emailTextField]
        
        textFields.forEach { textField in
            textField.delegate = self
            
            let layer = textField.layer
            layer.borderColor = UIColor.bclWarmGreyColor().CGColor
            layer.borderWidth = 1
            layer.cornerRadius = 0
            
            let paddingView = UIView(frame: CGRectMake(0, 0, 10, textField.frame.height))
            textField.leftView = paddingView
            textField.leftViewMode = UITextFieldViewMode.Always
            
            
            if let placeholder = textField.placeholder {
                textField.attributedPlaceholder = NSAttributedString(string:placeholder, attributes: [NSForegroundColorAttributeName: Color.white])
            }
        }
    }
    
    private func isFormValid() -> Bool {
        if let txt = emailTextField.text {
            return !txt.isBlank && txt.isEmail
        } else {
            return false
        }
    }
    
    @IBAction func nextAction(sender: AnyObject) {
        if !isFormValid() {
            let controller = UIAlertController(title: "Email inválido", message: nil, preferredStyle: .Alert)
            controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(controller, animated: true, completion: nil)
            return
        }
        
        presentLoadingView()
        apiClient.verifyVoucher(emailTextField.text!, voucher: voucherCodeTextField.text!) { result in
            self.dismissLoadingView()
            switch result {
            case .Success(let voucherNotUsed):
                if voucherNotUsed {
                    self.performSegueWithIdentifier("AdditionalInformationVC", sender: nil)
                } else {
                    self.presentVoucherUserMessage()
                }
            case .Failure(let fault):
                self.presentErrorMessage(fault)
            }
        }
    }
    
    
    
    func presentVoucherUserMessage() {
        let vc = UIAlertController(title: "Atenção", message: "O Voucher já foi utilizado", preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func presentErrorMessage(error:Fault) {
        let vc = UIAlertController(title: "Atenção", message: "Ocorreu um erro ao tentar processar o voucher", preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

// MARK: - UITextFieldDelegate

extension SignUpVoucherVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        UIView.animateWithDuration(0.25) {
            self.scrollView.contentOffset = CGPoint(x: 0, y: textField.frame.origin.y)
        }
    }
}