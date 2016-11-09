//
//  CreditCardInformationVC.swift
//  bclub
//
//  Created by Bruno Gama on 13/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import VMaskTextField
import SwiftyColor
import Stripe

class CreditCardInformationVC : UIViewController, FetchableContentProtocol {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var textFields: [UITextField]!
    
    var user:User?
    let apiClient = ApiClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        textFields.first?.becomeFirstResponder()
    }
    
    // MARK: - ACTIONS -
        
    @IBAction func nextAction(sender: UIButton) {
        
        sender.enabled = false
        
        if !isFormValid() {
            
            let messages = ["É preciso preencher todos os campos",
                            "Número do cartão inválido",
                            "Data de validade inválida",
                            "Código de verificação inválido"]
            
            let validations = [{ self.areallFieldsFilled() },
                               { self.isCardNumberValid() },
                               { self.isExpirationDateValid() },
                               { self.isCVCValid() }]
            
            var message = ""
            
            for (index, value) in validations.enumerate() {
                if !value() {
                    message = messages[index]
                    break
                }
            }            
            
            let controller = UIAlertController(title: "B.Club", message: message, preferredStyle: .Alert)
            controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(controller, animated: true, completion: nil)
            
            sender.enabled = true
            
            return
        }
        
        buildUser()
        presentLoadingView()
        self.user?.voucher = nil
        apiClient.registerUser(user!) { result in
        
            self.dismissLoadingView()
            
            sender.enabled = true
            
            switch result {
            case .Success(let user):
                self.presentSuccess(user)
                
            case .Failure(let error):
                self.presentErrorMessage(error)
            }
        }
    }
    
    func presentSuccess(user:User) {
        let vc = UIAlertController(title: "B.Club", message: "Registro finalizado com sucesso, por favor confirme o e-mail", preferredStyle: .Alert)
        let handler = UIAlertAction(title: "OK", style: .Default) { _ in
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        vc.addAction(handler)
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func presentErrorMessage(fault:Fault?) {
        let vc = UIAlertController(title: "Atenção", message: "Não foi possível efetuar o pagamento, verifique suas informações e tente novamente.", preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    func buildUser() {
        user!.cardOwnerName = textFields.first!.text!
        let cardNumbers    = textFields[1].text!.onlyNumbers
        let index = cardNumbers.startIndex.advancedBy(cardNumbers.characters.count - 4)
        let end   = cardNumbers.endIndex.predecessor()
        let cardLast4      = cardNumbers[index...end]
        user!.cardNumber = cardNumbers
        user!.cardLast4     = cardLast4
        user!.cardValidUntil = textFields[2].text!
        user!.cardCvc        = textFields.last!.text!
    }
    
    func areallFieldsFilled() -> Bool {
        let bools = textFields.map{ $0.text == nil ? false : !($0.text?.isBlank)! }        
        return !Set(bools).contains(false)
    }
    
    func  isFormValid() -> Bool {
        return areallFieldsFilled() && isCardNumberValid() && isExpirationDateValid() && isCVCValid()
    }
    
    func isCardNumberValid() -> Bool {
        let cardNumberTextField = textFields[1]
        let validation = STPCardValidator.validationStateForNumber(cardNumberTextField.text!, validatingCardBrand: false)
        
        return validation == .Valid ? true : false
    }
    
    func isExpirationDateValid() -> Bool {
        let expirationDateTextField = textFields[2]
        
        if let monthYear = expirationDateTextField.text?.componentsSeparatedByString("/") {
            if monthYear.count > 1 {
                let month = monthYear[0]
                let monthValidation = STPCardValidator.validationStateForExpirationMonth(month)
                
                if monthValidation == .Valid {
                    let year = monthYear[1]
                    let yearValidation = STPCardValidator.validationStateForExpirationYear(year, inMonth: month)
                    
                    return yearValidation == .Valid ? true : false
                }
                else {
                    return false
                }
                
            }
            else {
                return false
            }
        }
        
        return false
    }
    
    func isCVCValid() -> Bool {
        let cvcTextField = textFields[3]
        let cardBrand = STPCardValidator.brandForNumber(textFields[1].text!)        
        
        let validation = STPCardValidator.validationStateForCVC(cvcTextField.text!, cardBrand: cardBrand)
        
        return validation == .Valid ? true : false
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
        UIView.animateWithDuration(0.25) {
            self.scrollView.contentOffset = CGPointZero
        }
    }
    
    
    
    func configureTextFields() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let masks = ["#### #### #### ####", "##/##", "###"]
        for (i, textField) in textFields.enumerate() {
            let layer = textField.layer
            layer.borderColor = Color.bclNeighborhoodTextColor().CGColor
            layer.borderWidth = 1
            layer.cornerRadius = 0
            
            let paddingView = UIView(frame: CGRectMake(0, 0, 10, textField.frame.height))
            textField.leftView = paddingView
            textField.leftViewMode = UITextFieldViewMode.Always
            textField.delegate = self
            
            if let placeholder = textField.placeholder {
                textField.attributedPlaceholder = NSAttributedString(string:placeholder, attributes: [NSForegroundColorAttributeName: Color.bclNeighborhoodTextColor()])
            }
            if i > 0 {
                let maskedTextField = textField as! VMaskTextField
                maskedTextField.mask = masks[i - 1]
            }
        }
        
        UITextField.connectFields(textFields)
    }
}

// MARK: - UITextFieldDelegate -

extension CreditCardInformationVC : UITextFieldDelegate {

    func textFieldDidBeginEditing(textField: UITextField) {
        UIView.animateWithDuration(0.25) {
            self.scrollView.contentOffset = CGPoint(x: 0, y: textField.frame.origin.y)
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == textFields.first! {
            return true
        }
        let t = textField as! VMaskTextField
        return t.shouldChangeCharactersInRange(range, replacementString: string)
    }
}