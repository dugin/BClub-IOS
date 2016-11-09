//
//  PromotionListDatasource.swift
//  bclub
//
//  Created by Bruno Gama on 26/05/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation

class PromotionListDatasource: NSObject {
    
    let apiClient = ApiClient()
    private var tableView:UITableView!
    private var isFetchingData:Bool = false
    private var ordinaryPromotionList:[EstablishmentPromotion] = []
    private var featuredPromotionList:[EstablishmentPromotion] = []
    
    var promotions:[EstablishmentPromotion] {
        get {
            return ordinaryPromotionList
        }
    }
    
    private var _currentLocation:CLLocation?
    
    var currentLocation:CLLocation? {
        get {
            return self._currentLocation
        }
        set {
            self._currentLocation = newValue
            tableView.reloadData()
        }
    }
    
    var count:Int? {
        get {
            return self.ordinaryPromotionList.count
        }
    }
    
    var parentController: PromotionListVC!
    
    func resetContent() {
        ordinaryPromotionList = []
        featuredPromotionList = []
    }
    
    init(tableView:UITableView!, parentController: PromotionListVC) {
        self.tableView = tableView
        self.parentController = parentController
    }
    
    func getPromotionsForCity(city:City?, onComplete:(()->Void)?) {
        if isFetchingData {
            return
        }
        
        isFetchingData = true
        
        apiClient.fetchFeaturedPromotionAndOrdinaryPromotionsForCity(city) { result in
            switch result {
            case .Success(let promotions):
                if let featured = promotions.featured {
                    self.featuredPromotionList = [featured]
                }
                self.ordinaryPromotionList = promotions.promotions
                
            case .Failure(_):
                break
            }
            
            if let _ = self.currentLocation {
                self.ordinaryPromotionList.sortInPlace( {
                    guard let location0 = $0.establishment?.address?.geolocation, let location1 = $1.establishment?.address?.geolocation else {
                        return false
                    }
                    
                    return self.currentLocation?.distanceFromGeoPoint(location0) < self.currentLocation?.distanceFromGeoPoint(location1)
                })
            }
        
            if self.featuredPromotionList.count > 0 {
                let featuredPromotionHeader = FeaturedPromotionHeader.loadFromNib()
                featuredPromotionHeader.promotion = self.featuredPromotionList.first
                featuredPromotionHeader.parentController = self.parentController
                self.tableView.tableHeaderView = featuredPromotionHeader
            }
            else {
                self.tableView.tableHeaderView = UIView()
            }
            
            if let callback = onComplete {
                callback()
            }
            
            self.isFetchingData = false
            self.tableView.reloadData()
            self.tableView.scrollToTop()
        }
    }
    
    subscript(index: Int) -> EstablishmentPromotion {
        return ordinaryPromotionList[index]
    }
}


extension PromotionListDatasource: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(PromotionTableViewCell.cellName()) as? PromotionTableViewCell else {
            fatalError("Could not create PromotionTableViewCell")
        }
        
        cell.currentLocation = currentLocation
        cell.establishmentPromotion = ordinaryPromotionList[indexPath.row]
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ordinaryPromotionList.count
    }
}