//
//  SignUpVC.swift
//  bclub
//
//  Created by Bruno Gama on 09/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import SwiftyColor
import MRProgress

class SignUpVC: UIViewController, FetchableContentProtocol {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    var plan = ""
    
    let apiClient = ApiClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllerValues()
        submitButton.enabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        emailTextField.becomeFirstResponder()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! PersonalDataVC
        vc.email = emailTextField.text!
        vc.plan = plan
    }
    
    // MARK: - PRIVATE METHODS -
    
    private func setupControllerValues() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let textFields = [emailTextField]
        
        textFields.forEach { textField in
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
        
        dismissKeyboard()
        presentLoadingView()
        
        apiClient.checkUserExistanceByEmail(emailTextField.text!) { result in
            
            self.dismissLoadingView()
            
            switch result {
            case .Success(let haveEmail):
                if !haveEmail {
                    self.performSegueWithIdentifier("AdditionalInformationVC", sender: nil)
                } else {
                    self.presentEmailAlreadyRegistered()
                }
            case .Failure(_):
                break
            }
        }
    }

    func presentEmailAlreadyRegistered() {
        let vc = UIAlertController(title: "Atenção", message: "O e-mail digitado já está registrado no servidor", preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(vc, animated: true, completion: nil)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension SignUpVC : UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            let email = "\(text)\(string)"
            submitButton.enabled = !email.isBlank && email.isEmail
        }
        return true
    }
}