//
//  User.swift
//  bclub
//
//  Created by Bruno Gama on 10/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import Stripe

class User {
    var email                   = ""
    var name:String             = ""
    var surname:String          = ""
    var cpf:String?             = ""
    var birthdate:NSDate        = NSDate()
    var stripeToken:String      = ""
    var telephone:String        = ""
    var plan:String             = ""
    var cardLast4:String        = ""
    var cardOwnerName:String    = ""
    var customerId:String       = ""
    var subscriptionId:String   = ""
    var lastPaymentDate:NSDate  = NSDate()
    var validUntil:NSDate       = NSDate()
    var paymentSucceded:Bool    = false
    var subscriptionDate:NSDate = NSDate()
    var voucher:Voucher?
    var cardNumber              = ""
    var cardValidUntil          = ""
    var cardCvc                 = ""
    var objectId:String?
    var address: String         = ""
    var complement: String      = ""
    var zipcode: String         = ""
    var city: String            = ""
    var state: String           = ""

    var cardParams:STPCardParams {
        get {
            let cardParams      = STPCardParams()
            cardParams.name     = self.cardOwnerName
            cardParams.number   = self.cardNumber
            cardParams.cvc      = self.cardCvc
            let expirationComponents = self.cardValidUntil.componentsSeparatedByString("/").map{ UInt(Int($0)!) }
            cardParams.expYear  = expirationComponents.last!
            cardParams.expMonth = expirationComponents.first!
            return cardParams
        }
    }
    
    init() {}
    
    init?(backendlessUser:BackendlessUser) {
        objectId        = backendlessUser.objectId
        email           = backendlessUser.getProperty("email") as! String
        name            = backendlessUser.getProperty("name") as! String
        surname         = backendlessUser.getProperty("surname") as! String
        cpf             = backendlessUser.getProperty("cpf") as? String
        birthdate       = backendlessUser.getProperty("birthdate") as! NSDate
        stripeToken     = backendlessUser.getProperty("stripeToken") as! String
        telephone       = backendlessUser.getProperty("telephone") as! String
        plan            = backendlessUser.getProperty("plan") as! String
        cardLast4       = backendlessUser.getProperty("cardLast4") as! String
        cardOwnerName   = backendlessUser.getProperty("cardOwnerName") as! String
        customerId      = backendlessUser.getProperty("customerId") as! String
        subscriptionId  = backendlessUser.getProperty("subscriptionId") as! String
        lastPaymentDate = backendlessUser.getProperty("lastPaymentDate") as! NSDate
        validUntil      = backendlessUser.getProperty("validUntil") as! NSDate
        paymentSucceded = backendlessUser.getProperty("paymentSucceded") as! Bool

        if let subscription = backendlessUser.getProperty("subscriptionDate") {
            if let subscriptionDate = subscription as? NSDate {
                self.subscriptionDate = subscriptionDate
            }
        }
        if let voucher = backendlessUser.getProperty("voucher") {
            self.voucher = voucher as? Voucher
        }
    }
    
    var dictionaryRepresentation:[String:AnyObject] {
        get {
            var dictionary = [
                "EMAIL": email,
                "NAME": name,
                "SURNAME": surname,
                "CPF": cpf!,
                "BIRTHDATE": birthdate,
                "STRIPETOKEN": stripeToken,
                "TELEPHONE": telephone,
                "PLAN": plan,
                "CARDLAST4": cardLast4,
                "CARDOWNERNAME": cardOwnerName,
                "CUSTOMERID": customerId,
                "SUBSCRIPTIONID": subscriptionId,
                "LASTPAYMENTDATE": lastPaymentDate,
                "VALIDUNTIL": validUntil,
                "PAYMENTSUCCEDED": paymentSucceded,
                "ADDRESS": address,
                "COMPLEMENT": complement,
                "ZIPCODE": zipcode,
                "CITY": city,
                "STATE": state
            ]
            
            if voucher != nil {
                dictionary["VOUCHER"] = voucher
            }
            if let objectId = objectId {
                dictionary["USER_ID"] = objectId
            }
            return dictionary
        }
    }
    
    func backendlessUser() -> BackendlessUser {
        let user = BackendlessUser()
        user.email    = email
        user.password = cpf
        
        for (k, v) in dictionaryRepresentation {
            if k == "EMAIL" {
                continue
            }
            user.setProperty(k, object: v)
        }
        
        user.setProperty("password", object: cpf)
        
        if let userId = objectId {
            user.objectId = userId
        }
        
        return user
    }
    
    func mustSubscribePlan() -> Bool {
        let now = NSDate()
        let dateOrder = validUntil.compare(now)
        let isInThePast = dateOrder == .OrderedDescending
        return (!isInThePast && plan.isEmpty) || (!isInThePast && voucher == nil)
    }
}

