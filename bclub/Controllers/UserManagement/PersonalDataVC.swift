//
//  PersonalDataVC.swift
//  bclub
//
//  Created by Bruno Gama on 10/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import SwiftyColor
import SafariServices
import VMaskTextField
import KeychainAccess

class PersonalDataVC: UIViewController, FetchableContentProtocol {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var checkedImageView: UIImageView!
    
    @IBOutlet var textFields: [UITextField]!
    
    @IBOutlet weak var emailTextField: VMaskTextField!
    @IBOutlet weak var birthdayTextField: VMaskTextField!
    @IBOutlet weak var cpfTextField: VMaskTextField!
    @IBOutlet weak var phoneTextField: VMaskTextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var complementTextField: UITextField!
    @IBOutlet weak var zipcodeTextField: VMaskTextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    
    var apiClient = ApiClient()
    var email = ""
    var plan = ""
    var voucher = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllerValues()
        textFields.first?.text = email
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textFields[1].becomeFirstResponder()
    }
    
    // MARK: - SEGUES -
    
    private func prepareUser() -> User {
        let fmt = NSDateFormatter()
        fmt.dateFormat = "dd/MM/yyyy"
        
        let user        = User()
        user.email      = email
        user.plan       = plan
        user.birthdate  = fmt.dateFromString(birthdayTextField.text ?? "") ?? NSDate()
        user.cpf        = (cpfTextField.text ?? "").onlyNumbers
        user.telephone  = phoneTextField.text ?? ""
        user.name       = textFields[1].text ?? ""
        user.surname    = textFields[2].text ?? ""
        user.address    = addressTextField.text ?? ""
        user.complement = complementTextField.text ?? ""
        user.zipcode    = zipcodeTextField.text ?? ""
        user.city       = cityTextField.text ?? ""
        user.state      = stateTextField.text ?? ""
        
        return user
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        
        if voucher.isEmpty {
            if segue.identifier == "CreditCardInformationSegue" {
                let vc         = segue.destinationViewController as! CreditCardInformationVC
                vc.user        = self.prepareUser()
            }
        }
    }
    
    // MARK: - ACTIONS - 

    @IBAction func openTos() {
        if let url = NSURL(string: "http://www.bclub.io/termos_servico.html") {
            self.openWebview(url)
        }
    }
    
    @IBAction func checkIfValidAndSubmit() {
        dismissKeyboard()
        if !isFormValid() {
            let messagesAndValidations:[String:()->Bool] =
                ["É preciso preencher todos os campos": { self.areallFieldsFilled() },
                 "CPF inválido": { self.isCPFValid() },
                 "É necessário aceitar os Termos de Uso": { self.isTosChecked() },
                 "CEP inválido": { self.isBRZipcodeValid() }]
            
            var message = ""
            for (k, v) in messagesAndValidations {
                if !v() {
                    message = k
                    break
                }
            }
            
            let controller = UIAlertController(title: "B.Club", message: message, preferredStyle: .Alert)
            controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(controller, animated: true, completion: nil)
            
            return
        }
        
        dismissKeyboard()
        presentLoadingView()
        
        if voucher.isEmpty {
            
            apiClient.checkCpfExistanceByEmail(cpfTextField.text!) { result in
                self.dismissLoadingView()
                
                switch result {
                case .Success(let isCpfRegistered):
                    if !isCpfRegistered {
                        self.performSegueWithIdentifier("CreditCardInformationSegue", sender: nil)
                    } else {
                        self.presentCpfAlreadyRegistered()
                    }
                case  .Failure(_):
                    self.presentErrorMessage()
                }
            }
        }
        else {
            let user       = self.prepareUser()
            user.voucher =  Voucher(name: self.voucher, email: user.email, used: true)
            user.cardOwnerName  = ""
            user.cardLast4      = ""
            user.cardValidUntil = ""
            user.cardNumber     = ""
            user.cardCvc        = ""
            
            apiClient.registerUserAndSendEvent(user, event: "Voucher") { result in
                self.dismissLoadingView()
                
                switch result {
                case .Success(let user):
                    self.presentSuccess(user)
                case  .Failure(_):
                    self.presentVoucherErrorMessage()
                }
            }
        }
        
        
    }
    
    func presentSuccess(user:User?) {
        let vc = UIAlertController(title: "B.Club", message: "Registro finalizado com sucesso, por favor confirme o e-mail", preferredStyle: .Alert)
        let handler = UIAlertAction(title: "OK", style: .Default) { _ in
            self.navigationController?.popToViewController(self.navigationController!.viewControllers[2], animated: true)
        }
        vc.addAction(handler)
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func presentErrorMessage() {
        let vc = UIAlertController(title: "Atenção", message: "O CPF já está registrado no servidor", preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func presentVoucherErrorMessage() {
        let vc = UIAlertController(title: "Atenção", message: "Ocorreu um erro no servidor", preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    private func setupControllerValues() {
        configureTextFields()
    }
    
    func configureTextFields() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(dismissKeyboard))
        checkedImageView.hidden = true
        view.addGestureRecognizer(tap)
        
        textFields.forEach { textField in
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
        }
        
        cpfTextField.mask = "###.###.###-##"
        phoneTextField.mask = "(##) ####-######"
        zipcodeTextField.mask = "##.###-###"
        
        configureBirthdayTextField()
        UITextField.connectFields(textFields)
    }
    
    func configureBirthdayTextField() {
        birthdayTextField.mask = "##/##/####"
        let inputView = UIView(frame:CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen().bounds), 240))
        let picker = UIDatePicker()
        inputView.addSubview(picker)
        picker.date = NSDate().dateByAddingYears(-16).januaryFirst!
        picker.addTarget(self, action: #selector(updateTextField), forControlEvents: .ValueChanged)
        picker.datePickerMode = .Date
        picker.minimumDate = NSDate().dateByAddingYears(-100)
        picker.maximumDate = NSDate().dateByAddingDays(-1)
        
        let buttonWidth:CGFloat = 100
        let buttonHeight:CGFloat = 50
        var buttonFrame = CGRectZero
        buttonFrame.origin.x = (CGRectGetWidth(self.view.frame) / 2) - (buttonWidth / 2)
        buttonFrame.origin.y = ((CGRectGetHeight(picker.frame) + picker.frame.origin.y)) - (buttonHeight / 2)
        buttonFrame.size.width = buttonWidth
        buttonFrame.size.height = buttonHeight
        let doneButton = UIButton(frame: buttonFrame)
        doneButton.setTitle("OK", forState: .Normal)
        doneButton.setTitle("OK", forState: .Highlighted)
        doneButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        doneButton.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        inputView.addSubview(doneButton)
        doneButton.addTarget(self, action: #selector(doneSelectingDate), forControlEvents: UIControlEvents.TouchUpInside) // set button click event
        inputView.bringSubviewToFront(doneButton)
        birthdayTextField.inputView = inputView
    }
    
    func doneSelectingDate(sender:UIButton) {
        birthdayTextField.resignFirstResponder()
    }
    
    func updateTextField(sender:UIDatePicker) {
        handleDatePicker(sender)
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM/YYYY"
        birthdayTextField.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
        UIView.animateWithDuration(0.25) {
            self.scrollView.contentOffset = CGPointZero
        }
    }
    
    func presentCpfAlreadyRegistered() {
        let vc = UIAlertController(title: "Atenção", message: "O CPF utilizado já está registrado no servidor", preferredStyle: .Alert)
        vc.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func openWebview(url:NSURL) {
        let safariVC = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
        safariVC.view.tintColor = Color.bclRosyPinkColor()
        self.presentViewController(safariVC, animated: true, completion: nil)
    }
    
    @IBAction func toggleCheck() {
        checkedImageView.hidden = !checkedImageView.hidden
    }
    
    func  isFormValid() -> Bool {
        dismissKeyboard()
        return areallFieldsFilled() && isCPFValid() && isTosChecked() && isBRZipcodeValid()
    }
    
    func isTosChecked() -> Bool {
        return checkedImageView.hidden == false
    }
    
    func areallFieldsFilled() -> Bool {
        let bools = textFields.map{ $0.text == nil ? false : !($0.text?.isBlank)! }
        return !Set(bools).contains(false)
    }
    
    func isCPFValid() -> Bool {
        let cpf = cpfTextField.text!
        return cpf.isCPFValid
    }
    
    func isEmailValid() -> Bool {
        let email = emailTextField.text!
        return email.trimmed.isEmail
    }
    
    func isBRZipcodeValid() -> Bool {
        let pattern = "\\d{2}[\\.]\\d{3}[\\-]\\d{3}"
        
        let zipcode = zipcodeTextField.text ?? ""
        return zipcode.rangeOfString(pattern, options: .RegularExpressionSearch) != nil
    }
}

extension PersonalDataVC : UITextFieldDelegate {
    
    // MARK: - UITextFieldDelegate
    
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