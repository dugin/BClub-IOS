//
//  PromotionListBuilderVC.swift
//  bclub
//
//  Created by Bruno Gama on 03/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import Eureka
import SwiftyColor
import SnapKit
import Nuke

class PromotionListBuilderVC: FormViewController, FetchableContentProtocol {
    var apiClient = ApiClient()
    let backendless = Backendless.sharedInstance()
    let fontName = "OpenSans-Light"
    var timer = NSTimer()
    var searchParameters:SearchParameters = SearchParameters()
    var categories:[EstablishmentCategory] = [EstablishmentCategory]()
    var filteredPromotions:[EstablishmentPromotion] = []
    var currentLocation:CLLocation?
    let kAllCities = Constants.Strings.allCities
    let kSegueId = "FilteredEstablishmentPromotionDetail"
    var currentCity:City?
    
    @IBOutlet weak var cityFilterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInitialValues()
        
        fetchCategoriesIfNeeded { result, fault in
            if result != nil {
                self.categories = result!
                self.searchParameters.establishmentCategories = self.categories
                self.searchParameters.weekdays = [Int](0..<7)
                self.searchParameters.discountList = (2..<6).map{ Double($0) / 10 }
                if let objectId = self.currentCity?.objectId! {
                    self.searchParameters.city = objectId
                } else {
                    self.searchParameters.city = ""
                }
                
                self.setupForm()
                self.setupResultFormSection()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func imageRequest(url:NSURL) -> ImageRequest {
        var request = ImageRequest(URLRequest: NSURLRequest(URL: url))
        request.targetSize = CGSize(width: 100.0, height: 99.0)
        request.contentMode = .AspectFill
        request.memoryCacheStorageAllowed = true
        request.memoryCachePolicy = .ReloadIgnoringCachedImage
        request.priority = NSURLSessionTaskPriorityHigh
        return request
    }
    
    private func updateFilteredPromotions() {
        let responseSection = form.sectionByTag(FormSections.Response.rawValue)

        for filteredPromotion in self.filteredPromotions {
            let tag = "filtered_promotion_\(filteredPromotion.objectId)"
            responseSection! <<< FilteredPromotiontRow() {
                $0.tag = tag
                $0.value = filteredPromotion
            }.cellUpdate { cell, row in
                if let name = filteredPromotion.establishment?.name?.uppercaseString {
                    cell.establishmentLabel.text = name
                }
                if let category = filteredPromotion.establishment?.category?.name {
                    cell.typeLabel.text = category
                }
                
                let (min, max) = (filteredPromotion.getMinMax())
                cell.discountLabel.text = min == 0 ? "\(max)%" : "\(min) - \(max)%"
                
                cell.buttonActionBlock = {
                    self.performSegueWithIdentifier(self.kSegueId, sender: filteredPromotion)
                }
                if let imageUrl = filteredPromotion.imageUrl {
                    let url  = NSURL(string:imageUrl)
                    if url != nil {
                        Nuke.taskWith(self.imageRequest(url!)) {
                            cell.promotionImage.image = nil
                            cell.promotionImage.image = $0.image
                            }.resume()
                    }
                }
            }
        }
        
        if filteredPromotions.count > 0 {
            guard let section = responseSection else {
                return
            }
            
            let indexPath = NSIndexPath(forRow: 0, inSection: section.index!)
            tableView?.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
            tableView?.flashScrollIndicators()
        }
    }
    
    func requestFilteredPromotions() {
        self.presentLoadingView()
        apiClient.fetchEstablishmentPromotionsWithParameters(self.searchParameters) { result in
            switch result {
            case .Success(let promotions):
                self.filteredPromotions = promotions
            case .Failure(_):
                break
            }
            
            if let _ = self.currentLocation {
                self.filteredPromotions.sortInPlace( {
                    guard let location0 = $0.establishment?.address?.geolocation, let location1 = $1.establishment?.address?.geolocation else {
                        return false
                    }
                    
                    return self.currentLocation?.distanceFromGeoPoint(location0) < self.currentLocation?.distanceFromGeoPoint(location1)
                })
            }
            
            
            
            self.dismissLoadingView()
            self.setupResultFormSection()
        }
    }

    private func setupResultFormSection() {
        if form.sectionByTag(FormSections.Response.rawValue) == nil {
            let section = Section() { section in
                var header = HeaderFooterView<UIView>(HeaderFooterProvider.Class)
                header.height = { CGFloat.min }
                section.header = header
                
                var footer = HeaderFooterView<UIView>(HeaderFooterProvider.Class)
                footer.height = { CGFloat.min }
                section.footer = footer
                section.tag     = FormSections.Response.rawValue
            }
            
            form.append(section)
        }
        let responseSection = form.sectionByTag(FormSections.Response.rawValue)
        responseSection?.removeAll()
        self.updateFilteredPromotions()
    }
    
    private func fetchFilteredPromotions() {
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(requestFilteredPromotions), userInfo: nil, repeats: false)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == kSegueId) {
            let controller = segue.destinationViewController as! PromotionDetailVC
            controller.establishmentPromotion = sender as! EstablishmentPromotion
            controller.currentLocation = currentLocation
        } else if segue.identifier == Constants.GlobalSegues.cityFilter {
            let controller = (segue.destinationViewController as! UINavigationController).viewControllers.first as! CityFilterVC
            controller.delegate = self
        }
    }
    
    private func updateButtonName(name:String) {
        cityFilterButton.setTitle(name, forState: .Normal)
    }
    
    func setupCityFilterButton() {
        if let name = self.currentCity?.name! {
            updateButtonName(name)
        } else {
            updateButtonName("Todas as Cidades")
        }
        
        cityFilterButton.setBackgroundImage(UIImage(color: Color.bclBlackColor()), forState: .Normal)
        cityFilterButton.addTarget(self, action: #selector(pushToFilter), forControlEvents: .TouchUpInside)
        cityFilterButton.titleLabel?.font = UIFont(name: fontName, size:16)!
        cityFilterButton.setTitleColor(Color.white, forState: .Normal)
        
        let buttonImage = UIImage(named: "UiCityPin")
        
        cityFilterButton.setImage(buttonImage, forState: .Normal)
        cityFilterButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 38, bottom: 0, right: 0)
        cityFilterButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        cityFilterButton.contentHorizontalAlignment = .Left
    }
    
    func pushToFilter() {
        performSegueWithIdentifier(Constants.GlobalSegues.cityFilter, sender: nil)
    }
    
    private func setupInitialValues() {
        tableView?.backgroundColor = UIColor.bclBlackTwoColor()
        tableView?.tableFooterView = UIView()
        tableView?.separatorStyle = .None
        setupCityFilterButton()
    }
    
    private func fetchCategoriesIfNeeded(callBack:((result:[EstablishmentCategory]?, fault:Fault?)->Void)?) {
        if categories.count == 0 {
            self.presentLoadingView()
            apiClient.getCategories() { result in
                self.dismissLoadingView()
                switch result {
                case .Success(let categories):
                    callBack!(result: categories, fault: nil)
                case .Failure(let fault):
                    callBack!(result: nil, fault: fault)
                }
            }
        }
    }
    
    private func setupForm() {
        setupEstablishmentCategoryFormSection()
        setupDiscountFormSection()
        setupWeekDaysFormSection()
        setupInputSearchFormSection()
    }

    private func setupInputSearchFormSection() {
        form +++ Section { section in
            var header = HeaderFooterView<UIView>(HeaderFooterProvider.Class)
            header.height = { CGFloat.min }
            section.header = header
            } <<< InputFilterCellRow {
                $0.cell.searchButtonAction = { typedSearch in
                    self.submitSearch(typedSearch)
                }
            }
    }
    
    private func submitSearch(search:String) {
        self.searchParameters.inputString = search
        self.view.endEditing(true)
        self.timer.invalidate()
        self.requestFilteredPromotions()
    }
    
    private func setupWeekDaysFormSection() {
        form +++ Section { section in
                var header = HeaderFooterView<UIView>(HeaderFooterProvider.Class)
                header.height = { 5 }
                section.header = header
            
                var footer = HeaderFooterView<UIView>(HeaderFooterProvider.Class)
                footer.height = { CGFloat.min }
                section.footer = footer
            }
            <<< WeekDayRow() {
                $0.value = []
                }.onChange { row in
                    let weekdaysSet = Set(row.value!.map{ $0.rawValue })
                    let fullWeekSet = Set((0..<7))
                    self.searchParameters.weekdays = Array(fullWeekSet.subtract(weekdaysSet))
                    self.fetchFilteredPromotions()
        }
    }
    
    private func setupDiscountFormSection() {
        form +++ Section { section in
            var header = HeaderFooterView<UIView>(HeaderFooterProvider.Class)
            
            header.onSetupView = { (view, section) -> () in
                let headerView = view as UIView
                
                let headerLabel = UILabel()
                headerLabel.text  = "DESCONTO"
                headerLabel.textColor = Color.white
                headerLabel.textAlignment = .Left
                headerLabel.font = UIFont(name: self.fontName, size:14)!
                
                headerView.addSubview(headerLabel)
                
                headerLabel.snp_makeConstraints { (make) -> Void in
                    make.top.equalTo(headerView.snp_top).offset(8)
                    make.bottom.equalTo(headerView.snp_bottom).offset(-8)
                    make.left.equalTo(headerView.snp_left).offset(20)
                    make.right.equalTo(headerView.snp_right).offset(-20)
                }
            }
            
            header.height = { 50 }
            section.header = header
            
            var footer = HeaderFooterView<UIView>(HeaderFooterProvider.Class)
            footer.height = { CGFloat.min }
            section.footer = footer
        }
        
        for (index, number) in (2..<6).enumerate() {
            form.last! <<< CheckBoxRow() {
                    $0.tag = "\(FormRows.Discount.rawValue)_\(index)"
                    $0.value = number
                    $0.cell.checkBoxText = "\(Int(number * 10))%"
                    $0.cell.buttonClickCallback = {(cell:CheckBoxCell) -> Void in
                        let doubleObject = Double(number) / 10.0
                        if cell.isChecked() { // Is checked - will uncheck
                            let objectIndex = self.searchParameters.discountList.indexOf(doubleObject)
                            self.searchParameters.discountList.removeAtIndex(objectIndex!)
                        } else {
                            self.searchParameters.discountList.append(doubleObject)
                        }
                        
                        self.fetchFilteredPromotions()
                    }
                }
        }
    }
    
    private func setupEstablishmentCategoryFormSection() {
        form +++ Section { section in
            var header = HeaderFooterView<UIView>(HeaderFooterProvider.Class)
            
            header.onSetupView = { (view, section) -> () in
                let headerView = view as UIView
                
                let headerLabel = UILabel()
                headerLabel.text  = "TIPOS DE ESTABELECIMENTO"
                headerLabel.textColor = Color.white
                headerLabel.textAlignment = .Left
                headerLabel.font = UIFont(name: self.fontName, size:14)!
                
                headerView.addSubview(headerLabel)
                
                headerLabel.snp_makeConstraints { (make) -> Void in
                    make.top.equalTo(headerView.snp_top).offset(8)
                    make.bottom.equalTo(headerView.snp_bottom).offset(-8)
                    make.left.equalTo(headerView.snp_left).offset(20)
                    make.right.equalTo(headerView.snp_right).offset(-20)
                }
            }
            
            header.height = { 50 }
            section.header = header
            
            var footer = HeaderFooterView<UIView>(HeaderFooterProvider.Class)
            footer.height = { CGFloat.min }
            section.footer = footer
        }
        
        for (index, category) in categories.enumerate() {
            form.last! <<< CheckBoxRow() {
                $0.tag = "\(FormRows.Category.rawValue)_\(index)"
                $0.value = index
                $0.cell.checkBoxText = category.name!
                $0.cell.buttonClickCallback = {(cell:CheckBoxCell) -> Void in
                    let category = self.categories[index]
                    if cell.isChecked() { // Is checked - will uncheck
                        let objectIndex = self.searchParameters.establishmentCategories.indexOf(category)
                        self.searchParameters.establishmentCategories.removeAtIndex(objectIndex!)
                    } else {
                        self.searchParameters.establishmentCategories.append(category)
                    }
                    self.fetchFilteredPromotions()
                }
            }
        }
    }
    
    func sectionHeaderWithTitle(sectionTitle: String) -> HeaderFooterView<SectionHeader> {
        var header = HeaderFooterView<SectionHeader>(.NibFile(name: SectionHeader.nibName, bundle: nil))
        header.onSetupView = { (view, section) -> () in
            view.title = sectionTitle
        }
        
        header.height = { 30 }
        return header
    }
}

// MARK: - Eureka Form Sections and Rows -
extension PromotionListBuilderVC {
    enum FormSections:String {
        case Response = "PromotionListBuilderVC.FormSections.Response"
    }
    
    enum FormRows:String {
        case Weekday = "PromotionListBuilderVC.FormRows.Weekday"
        case Discount = "PromotionListBuilderVC.FormRows.Discount"
        case Category = "PromotionListBuilderVC.FormRows.Category"
    }
}

// MARK: - CityFilterDelegate
extension PromotionListBuilderVC: CityFilterDelegate {
    
    func selectedCity(city:City) -> Void {
        updateButtonName(city.name!)
        searchParameters.city = city.objectId!
        self.fetchFilteredPromotions()
        
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.backFromFilter, object: city, userInfo: nil)
    }
}