//
//  StatefulUserVC.swift
//  bclub
//
//  Created by Bruno Gama on 07/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import KeychainAccess

public final class StatefulUserVC: UIViewController {
    
    @IBOutlet weak var actionableButton: UIButton!
    @IBOutlet weak var informationLabel: UILabel!
    
    var targetSegue = ""
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        targetSegue = "SignUpLoginSegue"
        
        actionableButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        let keychain = Keychain(service: Constants.KeychainAccess.Service)
        guard let email = keychain[Constants.KeychainAccess.Email] else {
            return
        }
        
        targetSegue = "UserProfileSegue"
        actionableButton.setTitle("MINHA CONTA", forState: .Normal)
        actionableButton.titleLabel?.adjustsFontSizeToFitWidth = true
        actionableButton.titleLabel?.minimumScaleFactor = 0.5
        actionableButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        informationLabel.text   = "Logado como: \(email)"
    }

    @IBAction func openLoginOrSignUpVc() {
        self.parentViewController?.performSegueWithIdentifier(targetSegue, sender: nil)
    }
}