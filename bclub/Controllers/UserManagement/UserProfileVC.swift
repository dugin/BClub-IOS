//
//  UserProfileVC.swift
//  bclub
//
//  Created by Bruno Gama on 17/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import SnapKit

class UserProfileVC : UIViewController, FetchableContentProtocol {
    
    let apiClient = ApiClient()
    
    var scrollView: UIScrollView!
    var subscriptionView: UserProfileDetailedView!
    var invalidSubscriptionView: UserProfileInvalidSubscriptionView!
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView = UIScrollView()
        scrollView.delaysContentTouches = false
        view.addSubview(scrollView)
        
        subscriptionView = UserProfileDetailedView.loadFromNib()
        scrollView.addSubview(subscriptionView)
        
        invalidSubscriptionView = UserProfileInvalidSubscriptionView.loadFromNib()
        invalidSubscriptionView.delegate = self
        scrollView.addSubview(invalidSubscriptionView)
        
        scrollView.snp_makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.leading.equalTo(self.view)
            make.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        subscriptionView.snp_makeConstraints { (make) in
            make.top.equalTo(self.scrollView)
            make.leading.equalTo(self.scrollView)
            make.trailing.equalTo(self.scrollView)
            make.width.equalTo(self.scrollView)
            make.height.equalTo(431)
        }
        
        invalidSubscriptionView.snp_makeConstraints { (make) in
            make.top.equalTo(self.scrollView)
            make.leading.equalTo(self.scrollView)
            make.trailing.equalTo(self.scrollView)
            make.width.equalTo(self.scrollView)
            make.height.equalTo(350)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscriptionView.hidden = true
        invalidSubscriptionView.hidden = true
        
        presentLoadingViewWithTitle("Carregando usuário")
        
        apiClient.getCurrentUserById() { result in
            self.dismissLoadingView()
            
            switch result {
            case .Success(let user):
                self.configureUserProfile(user)
                
            case .Failure(_):
                break
            }
        }
    }
    
    // MARK: - PRIVATE METHODS -
    
    func configureUserProfile(user:User) {
        self.user = user
        if user.mustSubscribePlan() {
            invalidSubscriptionView.hidden = false
            return
        }
        
        let fmt = NSDateFormatter()
        fmt.dateFormat = "dd/MM/yyyy"
        
        subscriptionView.activatedTextField.text = "\(fmt.stringFromDate(user.subscriptionDate))"
        subscriptionView.expirationTextField.text = "\(fmt.stringFromDate(user.validUntil))"
        
        if let voucher = user.voucher {
            subscriptionView.installmentTextField.text = "Voucher: \(voucher.name)"
        } else {
            var installmentText:String = ""
            
            let plan = user.plan
            if plan ==  SubscriptionPlan.Recurrence.Yearly.rawValue {
                installmentText = "12x de R$ 9,00"
            } else if plan ==  SubscriptionPlan.Recurrence.Semiannual.rawValue {
                installmentText = "6x de R$ 12,00"
            } else if plan ==  SubscriptionPlan.Recurrence.Monthly.rawValue {
                installmentText = "1x de R$ 15,00"
            } else {
                installmentText = "Plano não computado"
            }
            
            subscriptionView.installmentTextField.text = installmentText
        }
        
        subscriptionView.hidden = false
    }
}

extension UserProfileVC : UserProfileInvalidSubscriptionViewProtocol {
    func openSubscriptionController() {
        let targetStoryboard = UIStoryboard(name: "UserManagement", bundle: nil)
        if let targetController = targetStoryboard.instantiateViewControllerWithIdentifier("SubscriptionPlanSelection") as? SubscriptionPlanSelectionVC {
            targetController.user = user
            navigationController?.pushViewController(targetController, animated: true)
        }
    }
}
