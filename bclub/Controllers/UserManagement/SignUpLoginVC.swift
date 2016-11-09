//
//  SignUpLoginVC.swift
//  bclub
//
//  Created by Bruno Gama on 09/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import SwiftyColor
import VMaskTextField

class SignUpLoginVC: UIViewController, FetchableContentProtocol {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cpfTextField: VMaskTextField!
    private let errorMessages:[String] = ["É preciso preencher todos os campos", "E-mail digitado não é válido", "CPF Inválido"]
    let apiClient = ApiClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllerValues()
    }
    
    // MARK: - ACTIONS -
    
    @IBAction func loginAction() {
        dismissKeyboard()
        if !validateForm() {
            var message = ""
            let validations = [({ return self.areallFieldsFilled() }), ({ return self.isEmailValid() }), ({ return self.isCpfValid() })]
            for (i, b) in validations.enumerate() {
                if !b() {
                    message = errorMessages[i]
                    break
                }
            }
            
            let controller = UIAlertController(title: "B.Club", message: message, preferredStyle: .Alert)
            controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(controller, animated: true, completion: nil)
            
            return
        }
        
        self.presentLoadingView()
        
        apiClient.logUser(emailTextField.text!, cpf: cpfTextField.text!.onlyNumbers) { result in
            self.dismissLoadingView()
            switch result {
            case .Success(_):
                self.navigationController?.popToRootViewControllerAnimated(true)
            case .Failure(let fault):
                self.presentErrorMessage(fault)
            }
        }
    }
    
    // MARK: - PRIVATE METHODS -
    

    func presentResendEmailSuccess() {
        let vc = UIAlertController(title: "B.Club", message: "Você receberá um novo e-mail em breve", preferredStyle: .Alert)
        let handler = UIAlertAction(title: "OK", style: .Default) { _ in
            self.navigationController?.popToViewController(self.navigationController!.viewControllers[2], animated: true)
        }
        vc.addAction(handler)
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func presentErrorMessage() {
        let vc = UIAlertController(title: "Atenção", message: "Ocorreu um erro ao tentar recadastra o usuário", preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func areallFieldsFilled() -> Bool {
        return !(emailTextField.text!.isBlank && cpfTextField.text!.isBlank)
    }
    
    private func setupControllerValues() {
        let textFields = [emailTextField, cpfTextField]
        
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
        cpfTextField.mask = "###.###.###-##"
    }
    
    private func validateForm() -> Bool {
        let validations = [{ self.areallFieldsFilled() }, { self.isEmailValid() }, { self.isCpfValid() }]
        return !Set(validations.map{ $0() }).contains(false)
    }

    private func isCpfValid() -> Bool {
        return (self.cpfTextField!.text!.isCPFValid)
    }
    
    private func isEmailValid() -> Bool {
        return (self.emailTextField!.text!.isEmail)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
        UIView.animateWithDuration(0.25) {
            self.scrollView.contentOffset = CGPointZero
        }
    }
    
    func presentErrorMessage(fault:Fault) {
        var message = ""
        if let faultCode:String = fault.faultCode {
            if faultCode == "3003" {
                message = "E-mail ou CPF inválidos"
            } else {
                message = "Você precisa confirmar o e-mail antes de fazer o login"
            }
        }
        
        let vc = UIAlertController(title: "Atenção", message: message, preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        if validateForm() {
            let resendAction = UIAlertAction(title: "Re-enviar o e-mail", style: .Default) { _ in
                self.presentLoadingView()
                
                self.apiClient.resendEmail(self.emailTextField.text!, cpf: self.cpfTextField.text!.onlyNumbers) { result in
                    self.dismissLoadingView()
                    switch result {
                    case .Success(_):
                        self.presentResendEmailSuccess()
                    case  .Failure(let fault):
                        self.presentErrorMessage(fault)
                    }
                }
            }
            
            vc.addAction(resendAction)
        }
        
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
}

extension SignUpLoginVC : UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        UIView.animateWithDuration(0.25) {
            self.scrollView.contentOffset = CGPoint(x: 0, y: textField.frame.origin.y)
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let maskTextField = textField as? VMaskTextField else {
            return true
        }
        
        return maskTextField.shouldChangeCharactersInRange(range, replacementString: string)
    }
}
