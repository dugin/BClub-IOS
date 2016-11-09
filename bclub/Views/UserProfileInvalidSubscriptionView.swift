//
//  UserProfileInvalidSubscriptionView.swift
//  bclub
//
//  Created by Bruno Gama on 17/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import SwiftyColor

protocol UserProfileInvalidSubscriptionViewProtocol : class {
    func openSubscriptionController()
}

@IBDesignable class UserProfileInvalidSubscriptionView : UIView {
    
    weak var delegate:UserProfileInvalidSubscriptionViewProtocol?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func selectSubscriptionPlanTap(sender: AnyObject) {
        delegate?.openSubscriptionController()
    }
}
