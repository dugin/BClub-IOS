//
//  SubscriptionPlanSelectionVC.swift
//  bclub
//
//  Created by Bruno Gama on 09/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

class SubscriptionPlanSelectionVC: UITableViewController {
    
    var plans:[SubscriptionPlan] = []
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialValues()
        setupControllerValues()
    }
    
    // MARK: - UITableViewDelegate  and UITableViewDatasource-
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:SubscriptionPlanCell = tableView.dequeueReusableCellWithIdentifier(SubscriptionPlanCell.cellName()) as! SubscriptionPlanCell
        cell.subscriptionPlan = plans[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let plan = plans[indexPath.row]
        
        if plan.recurrence == .None {
            performSegueWithIdentifier("pushTOSignUpVoucher", sender: nil)
        }
        else {
            if let _ = user {
                performSegueWithIdentifier("renewSubscriptionSegue", sender: plan.recurrence.rawValue)
            }
            else {
                performSegueWithIdentifier("pushTOSignUp", sender: plan.recurrence.rawValue)
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plans.count
    }
    
    // MARK: - Segue - 
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier  == "renewSubscriptionSegue" {
            let vc = segue.destinationViewController as! CreditCardInformationVC
            if let u = user {
                u.plan = sender as! String
                vc.user = u
            }
        }
        else if segue.identifier  == "pushTOSignUp" {
            let vc = segue.destinationViewController as! SignUpVC
            vc.plan = sender as! String
        }
    }
    
    // MARK: - PRIVATE METHODS -
    
    private func setupInitialValues() {
        plans = [
            SubscriptionPlan(recurrence: .Yearly, price: 108.00, title: "Assinatura Anual", summarization: "40% de desconto, economize R$ 72,00", gotoAction: "Fazer Assinatura Anual"),
            SubscriptionPlan(recurrence: .Semiannual, price: 72.00, title: "Assinatura Semestral", summarization: "20% de desconto, economize R$ 18,00", gotoAction: "Fazer Assinatura Semestral"),
            SubscriptionPlan(recurrence: .Monthly, price: 15.00, title: "Assinatura Mensal", summarization: "Conheça os benefícios do B.Club", gotoAction: "Fazer Assinatura Mensal"),
        ]
        
        if user == nil {
            plans.append(SubscriptionPlan(recurrence: .None, price: 0.00, title: "Ganhei um cupom para\nconhecer o B.Club", summarization: "Teste por um mês as vantagens do B.Club", gotoAction: "Testar o B.Club"))
        }
        
        tableView.reloadData()
    }
    
    private func setupControllerValues() {
        tableView?.backgroundColor = UIColor.bclBlackTwoColor()
        tableView?.tableFooterView = UIView()
        tableView?.separatorStyle = .None
    }
    
    // MARK: - ACTIONS -

}