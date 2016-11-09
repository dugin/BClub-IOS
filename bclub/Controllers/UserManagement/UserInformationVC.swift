//
//  UserInformationVC.swift
//  bclub
//
//  Created by Bruno Gama on 07/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import Eureka
import SwiftyColor
import SafariServices

class UserInformationVC: FormViewController {

    typealias SectionsWithRows = (section:String?, tag:String, rows:[ActionableRow])
    
    private let kTosUrl = "http://www.bclub.io/tos_pp.html"
    
    @IBOutlet weak var userInformationVc: UIView!
    var faqAndHowToSection:SectionsWithRows {
        get {
            return (section:nil, tag: Form.Section.FaqAndHowTo, rows:[
                ActionableRow(text: "Como Funciona", imageName: nil, action: {
                    var defaults = NSUserDefaults.standardUserDefaults()
                    defaults.tutorialWasPresented = false
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }),
                ActionableRow(text: "FAQ", imageName: nil, action: {
                    if let url = NSURL(string: "http://www.bclub.io/faq.html") {
                        self.openWebview(url)
                    }
                })
            ])
        }
    }
    
    var contactSection:SectionsWithRows {
        get {
            return (section: "Contato", tag: Form.Section.Contact, rows:[
                ActionableRow(text: "contato@bclub.io", imageName: "UIMailIcon", action: {
                    UIApplication.sharedApplication().openURL(NSURL(string: "mailto:contato@bclub.io")!)
                }),
                ActionableRow(text: "www.bclub.io", imageName: "UILinkIcon", action: {
                    if let url = NSURL(string: "http://www.bclub.io") {
                        self.openWebview(url)
                    }
                })
            ])
        }
    }
    
    var legalSection:SectionsWithRows {
        get {
            return (section: "Legal", tag: Form.Section.Legal, rows:[
                ActionableRow(text: "Política de Privacidade", imageName: nil, action: {
                    if let url = NSURL(string: self.kTosUrl) {
                        self.openWebview(url)
                    }
                }),
                ActionableRow(text: "Termos do Uso", imageName: nil, action: {
                    if let url = NSURL(string: self.kTosUrl) {
                        self.openWebview(url)
                    }
                })
            ])
        }
    }
    
    
    // MARK: - Overriden Methods - 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.backgroundColor = UIColor.bclBlackTwoColor()
        tableView?.separatorStyle = .None
        setupForm()
    }
    
    // MARK: - Private Methods -
    
    func openWebview(url:NSURL) {
        let safariVC = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
        safariVC.view.tintColor = Color.bclRosyPinkColor()
        self.presentViewController(safariVC, animated: true, completion: nil)
    }
    
    func setupForm() {
        let sections = [faqAndHowToSection, contactSection, legalSection]
        sections.forEach { section in
            let (title, tag, rows) = section
            if title == nil {
                form +++ Section { section in
                    section.header = sectionRuler()
                    section.tag = tag
                    section.footer = sectionRuler()
                }
            }
            else {
                form +++ Section { section in
                    section.header = sectionHeaderWithTitle(title!.uppercaseString)
                    section.tag = tag
                    if tag != Form.Section.Legal {
                        section.footer = sectionRuler()
                    } else {
                        var headerFooter = HeaderFooterView<UIView>(HeaderFooterProvider.Class)
                        headerFooter.height = { 0 }
                        section.header = headerFooter
                    }
                }
            }
            
            for (index, actionableRow) in rows.enumerate() {
                form.last! <<< MenuRow {
                    $0.tag = "\(tag)_row_\(index)"
                    $0.value = actionableRow.text
                    $0.cell.cellAction  = actionableRow.action
                    let button = $0.cell.button
                    button.setTitle(actionableRow.text, forState: .Normal)
                    if actionableRow.imageName != nil {
                        button.setImage(UIImage(named:actionableRow.imageName!), forState: .Normal)
                        let edge = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
                        button.titleEdgeInsets = edge
                        button.imageEdgeInsets = UIEdgeInsetsZero
                    }
                }
            }
        }
    }
    
    func sectionHeaderWithTitle(sectionTitle: String) -> HeaderFooterView<SectionHeader> {
        var header = HeaderFooterView<SectionHeader>(.NibFile(name: SectionHeader.nibName, bundle: nil))
        header.onSetupView = { (view, section) -> () in
            view.title = sectionTitle
        }
        
        header.height = { 40 }
        return header
    }
    
    func sectionRuler() -> HeaderFooterView<SectionRuler> {
        var header = HeaderFooterView<SectionRuler>(.NibFile(name: SectionRuler.nibName, bundle: nil))
        header.height = { 4 }
        return header
    }
    
    override func insertAnimationForSections(sections: [Section]) -> UITableViewRowAnimation {
        return .None
    }
}

extension UserInformationVC {
    struct ActionableRow {
        var text = ""
        var imageName:String?
        var action:(()->Void)?
        
        init(text:String, imageName:String?, action:(()->Void)?) {
            self.text = text
            self.imageName = imageName
            self.action = action
        }
    }
    
    struct Form {
        struct Section {
            static let FaqAndHowTo = "FaqAndHowToSection"
            static let Contact = "ContactSection"
            static let Legal = "LegalSection"
        }
    }
}