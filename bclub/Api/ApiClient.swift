//
//  ApiClient.swift
//  BackendlessApiControllerAdventures
//
//  Created by Bruno Gama on 12/06/16.
//  Copyright © 2016 Bruno Gama. All rights reserved.
//

import Stripe
import KeychainAccess

struct ApiClient: BackendlessConsumer {
    let noConnectionFault = Fault.init(message: "No connection to the internet", detail: "", faultCode: "9999")
    let locationNotFound  = Fault.init(message: "Location not found", detail: "", faultCode: "9998")
    
    func getCurrentUserById(completion: (Result<User, Fault>) -> Void) {
        
        let keychain = Keychain(service: Constants.KeychainAccess.Service)
        guard let userId = keychain[Constants.KeychainAccess.UserId] else {
            completion(.Failure(noConnectionFault))
            return
        }
        
        getDataOfEntity(BackendlessUser.ofClass(), withQuery: Query.UserWithId(userId).dataQuery) { result in
            switch result {
            case .Success(let backendlessCollection):
                
                let user = User(backendlessUser: backendlessCollection.data.first! as! BackendlessUser)
                completion(.Success(user!))
            case .Failure(let fault):
                completion(.Failure(fault))
            }
        }
    }
    
    func verifyVoucher(email:String, voucher:String, completion: (Result<Bool, Fault>)-> Void) {
        getDataOfEntity(Voucher.ofClass(), withQuery:Query.VoucherSearch(email, voucher).dataQuery) { result in
            switch result {
            case .Success(let data):
                completion(.Success(data.data.count != 0))
            case .Failure(let fault):
                completion(.Failure(fault))
            }
        }
    }
    
    func logUser(email:String, cpf:String, completion: (Result<User, Fault>)->Void) {
        if Reachability.isConnectedToNetwork() {
            consumer.userService.login(email, password: cpf, response: { backendlessUser in
                let user = User(backendlessUser: backendlessUser)!
                
                let keychain = Keychain(service: Constants.KeychainAccess.Service)
                keychain[Constants.KeychainAccess.UserId] = backendlessUser.objectId!
                keychain[Constants.KeychainAccess.Email] = backendlessUser.email!
                
                completion(.Success(user))
                }, error: { fault in
                    completion(.Failure(fault))
            })
        } else {
            completion(.Failure(noConnectionFault))
        }
    }
    
    func resendEmail(email:String, cpf:String, completion: (Result<Bool, Fault>)->Void) {
        let args = ["USER_EMAIL": email, "USER_CPF": cpf]
        consumer.events.dispatch("ResendConfirmation", args: args, response: { objects in
            completion(.Success(true))
            }, error: { fault in
                completion(.Failure(fault))
        })
    }
    
    func registerUser(user:User, completion: (Result<User, Fault>)->Void) {
        if user.voucher == nil {
            Stripe.setDefaultPublishableKey(Constants.Stripe.Production.Key)
            STPAPIClient.sharedClient().createTokenWithCard(user.cardParams) { token, error in
                if token != nil {
                    user.stripeToken = token!.tokenId
                    
                    if let _ = user.objectId {
                        self.updateUserAndSubscribeToPlan(user, completion: completion)
                    } else {
                        self.registerUserAndSendEvent(user, event: "SubscribeUser", completion: completion)
                    }
                    
                } else {
                    completion(.Failure(Fault.init(message: "Stripe error", detail: error?.localizedDescription, faultCode: "8888")))
                }
            }
        }
        else {
            self.registerUserAndSendEvent(user, event: "Voucher") { result in
                switch result {
                case .Success(let user):
                    completion(.Success(user))
                case .Failure(let fault):
                    completion(.Failure(fault))
                }
            }
        }
    }
    
    func registerUserAndSendEvent(user:User, event:String, completion: (Result<User, Fault>) -> Void) {
        
        consumer.userService.registering(user.backendlessUser(), response: { registeredUser in
            var args:[String:AnyObject] = [:]
            args["USER_ID"] = registeredUser.objectId
            
            if let voucher = user.voucher {
                args["VOUCHER_NAME"] = voucher.name
            }
            
            self.consumer.events.dispatch(event, args: args, response: { objects in
                completion(.Success(User(backendlessUser: registeredUser)!))
            }, error: { fault in
                completion(.Failure(fault))
            })
            
        }, error: { fault in
            completion(.Failure(fault))
        })

    }
    
    func updateUserAndSubscribeToPlan(user: User, completion: (Result<User, Fault>) -> Void) {
        let args = user.dictionaryRepresentation
        
        self.consumer.events.dispatch("CreateUser", args: args, response: { _ in
            
            self.consumer.events.dispatch("SubscribeUser", args: args, response: { _ in
                completion(.Success(user))
            }, error: { fault in
                completion(.Failure(fault))
            })
            
        }, error: { fault in
            completion(.Failure(fault))
        })
    }
    
    func fetchFeaturedPromotionAndOrdinaryPromotionsForCity(city:City?, completion: (Result<(featured:EstablishmentPromotion?, promotions:[EstablishmentPromotion]), [Fault]?>)-> Void) {
        
        var featured:EstablishmentPromotion?
        var ordinaryPromotions:[EstablishmentPromotion] = []
        var failure:[Fault]? = []
        let dispatch_group: dispatch_group_t = dispatch_group_create()
        let cityId = city != nil ? city?.objectId! : ""
        dispatch_group_enter(dispatch_group)
        self.fetchOrdinaryPromotionsForCityId(cityId!) { result in
            switch result {
            case .Success(let promotions):
                ordinaryPromotions = promotions
            case .Failure(let fault):
                failure?.append(fault)
            }
            dispatch_group_leave(dispatch_group)
        }
        
        dispatch_group_enter(dispatch_group)
        self.fetchFeaturedPromotionForCityId(cityId!, andDate:NSDate()) { result in
            switch result {
            case .Success(let promotion):
                featured = promotion
            case .Failure(let fault):
                failure?.append(fault)
            }
            dispatch_group_leave(dispatch_group)
        }
        
        
        dispatch_group_notify(dispatch_group, dispatch_get_main_queue()) {
            if failure?.count > 0 {
                completion(.Failure(failure))
            } else {
                let promotions = (featured:featured, promotions:ordinaryPromotions)
                completion(.Success(promotions))
            }
        }
    }

    func fetchOrdinaryPromotionsForCityId(cityId: String, completion: (Result<[EstablishmentPromotion], Fault>)-> Void) {
        getDataOfEntity(EstablishmentPromotion.ofClass(), withQuery: Query.OrdinaryPromotionsForCityId(cityId).dataQuery) { result in
            switch result {
            case .Success(let data):
                
                var page = data.data as! [EstablishmentPromotion]
                while (data.totalObjects != page.count) {
                    data.nextPage()
                    page.appendContentsOf(data.data as! [EstablishmentPromotion])
                }
                
                completion(.Success(page))
            case .Failure(let fault):
                completion(.Failure(fault))
            }
        }
    }
    
    func fetchFeaturedPromotionForCityId(cityId: String, andDate date:NSDate, completion: (Result<EstablishmentPromotion?, Fault>)-> Void) {
        getDataOfEntity(EstablishmentPromotion.ofClass(), withQuery: Query.FeaturedPromotionsForCityId(cityId, NSDate()).dataQuery) { result in
            switch result {
            case .Success(let backendlessResult):
                if let featuredPromotion:EstablishmentPromotion = backendlessResult.data!.first as? EstablishmentPromotion {
                    completion(.Success(featuredPromotion))
                }
                else {
                    completion(.Success(nil))
                }
            case .Failure(let fault):
                completion(.Failure(fault))
            }
        }
    }
    
    func getCityWithLocation(location:CLLocation, completion: (Result<City?, Fault>)-> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            if error != nil {
                completion(.Failure(self.locationNotFound))
                return
            }
            
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            if let city = placeMark.addressDictionary!["City"] as? String {
                self.getCityWithName(city, completion: completion)
            }
        }
    }
    
    func getCityWithName(name:String, completion: (Result<City?, Fault>)-> Void) {
        getDataOfEntity(City.ofClass(), withQuery: Query.CitySearch(name).dataQuery) { result in
            switch result {
            case .Success(let data):
                completion(.Success(data.data?.first as? City))
            case .Failure(let fault):
                completion(.Failure(fault))
            }
        }
    }
    
    
    func getCitiesWithString(string:String, completion: (Result<[City]?, Fault>)-> Void) {
        getDataOfEntity(City.ofClass(), withQuery: Query.CitiesWithSubstring(string).dataQuery) { result in
            switch result {
            case .Success(let data):
                var page = data.data as! [City]
                while (data.totalObjects != page.count) {
                    data.nextPage()
                    page.appendContentsOf(data.data as! [City])
                }
                
                completion(.Success(page))
            case .Failure(let fault):
                completion(.Failure(fault))
            }
        }
    }
    
    func getCategories(completion: (Result<[EstablishmentCategory]?, Fault>)-> Void) {
        getDataOfEntity(EstablishmentCategory.ofClass(),
                        withQuery: Query.Categories().dataQuery) { result in
            switch result {
            case .Success(let data):
                completion(.Success(data.data as? [EstablishmentCategory]))
            case .Failure(let fault):
                completion(.Failure(fault))
            }
        }
    }
    
    func checkCpfExistanceByEmail(cpf: String, completion: (Result<Bool, Fault>)-> Void) {
        getDataOfEntity(BackendlessUser.ofClass(), withQuery:Query.CpfSearch(cpf).dataQuery) { result in
            switch result {
            case .Success(let data):
                completion(.Success(data.data.count != 0))
            case .Failure(let fault):
                completion(.Failure(fault))
            }
        }
    }
    
    func checkUserExistanceByEmail(email: String, completion: (Result<Bool, Fault>)-> Void) {
        getDataOfEntity(BackendlessUser.ofClass(), withQuery:Query.EmailSearch(email).dataQuery) { result in
            switch result {
            case .Success(let data):
                completion(.Success(data.data.count != 0))
            case .Failure(let fault):
                completion(.Failure(fault))
            }
        }
    }
    
    func fetchEstablishmentPromotionsWithParameters(parameters: SearchParameters, completion: (Result<[EstablishmentPromotion], Fault>) -> Void) {
        getDataOfEntity(EstablishmentPromotion.ofClass(), withQuery: Query.UserBuiltSearch(parameters).dataQuery) { result in
            switch result {
            case .Success(let data):
                var page = data.data as! [EstablishmentPromotion]
                while (data.totalObjects != page.count) {
                    data.nextPage()
                    page.appendContentsOf(data.data as! [EstablishmentPromotion])
                }
                
                completion(.Success(page))
            case .Failure(let fault):
                completion(.Failure(fault))
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func getDataOfEntity(entity: AnyClass, withQuery query: BackendlessDataQuery, completion: (BackendlessResult<BackendlessCollection>)-> Void) {
        if Reachability.isConnectedToNetwork() {
            let dataStore = consumer.persistenceService.of(entity.ofClass())
            dataStore.find(query, response: { result in
                    completion(.Success(result))
                }, error: { fault in
                    completion(.Failure(fault))
            })
        } else {
            completion(.Failure(noConnectionFault))
        }
    }
}