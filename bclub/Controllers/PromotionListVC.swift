//
//  PromotionListVC.swift
//  bclub
//
//  Created by Douglas on 02/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import SwiftyColor
import SnapKit

class PromotionListVC: UIViewController, UITableViewDelegate  {
    
    let kSegueEstablishmentDetail = "EstablishmentPromotionDetail"
    let kSegueEstablishmentFeaturedPromotionDetail = "EstablishmentFeaturedPromotionDetail"
    let kSeguePromotionFilter = "SeguePromotionFilter"
    let fontName = "OpenSans-Light"
    
    var backendless = Backendless.sharedInstance()
    var promotionList = [AnyObject]()
    private var dataSource:PromotionListDatasource!
    var locationManager = LocationManager()
    
    var splashWasShowed = false
    var goFromSplash = false
    
    var promotionsLoagingView: PromotioListLoadingView!
    var userCity:City?
    var currentCity:City? {
        didSet {
            setupCityFilterButton()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cityFilterButton: UIButton!
    
    var pullToRefreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = UIImageView.init(image: UIImage(named:"logo"))
        
        promotionsLoagingView = PromotioListLoadingView()
        setupTableView()
        setupLocationManager()
        setupCityFilterButton()
        registerObservers()
        
        //QUANDO CRIAR EXIBE TUTORIAL
        //CASO NAO SEJA ASSINANTE
        let tutorialViewController = UIStoryboard(name: "Tutorial", bundle: nil).instantiateViewControllerWithIdentifier("TutorialVC")
        dataSource.resetContent()
        presentViewController(tutorialViewController, animated: true) {}
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        /*
        if !NSUserDefaults.standardUserDefaults().tutorialWasPresented! {
            let tutorialViewController = UIStoryboard(name: "Tutorial", bundle: nil).instantiateViewControllerWithIdentifier("TutorialVC")
            dataSource.resetContent()
            presentViewController(tutorialViewController, animated: true) {}
        } else {
            requestUserLocation()
        }*/
        if (goFromSplash) {
            requestUserLocation()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func hasContent() -> Bool {
        return dataSource.count > 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(kSegueEstablishmentDetail, sender: dataSource[indexPath.row])
    }
    
    // MARK: - Helpers
    
    func startCustomLoading() {
        if let nav = navigationController where !splashWasShowed {
            nav.view.addSubview(promotionsLoagingView)
            promotionsLoagingView.dotsLoadingView.startAnimating()
            
            promotionsLoagingView.snp_makeConstraints{ (make) -> Void in
                make.edges.equalTo(EdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            }
            
            splashWasShowed = true
        }
    }
    
    func stopCustomLoading() {
        if promotionsLoagingView.superview != nil {
            promotionsLoagingView.removeFromSuperview()
        }
    }
    
    func testAssinar() {
        stopCustomLoading();
        let targetStoryboardName = "UserManagement"
        let targetStoryboard = UIStoryboard(name: targetStoryboardName, bundle: nil)
        let vc = targetStoryboard.instantiateViewControllerWithIdentifier("SubscriptionPlanSelection") as UIViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupTableView() {
        pullToRefreshControl = UIRefreshControl()
        pullToRefreshControl.addTarget(self, action: #selector(PromotionListVC.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(pullToRefreshControl)
        tableView.tableFooterView = UIView()
        let nibName = UINib(nibName: PromotionTableViewCell.nibName, bundle:nil)
        tableView.registerNib(nibName, forCellReuseIdentifier: PromotionTableViewCell.identifier)
        tableView.rowHeight = 333
        dataSource = PromotionListDatasource(tableView: self.tableView, parentController: self)
        tableView.dataSource = self.dataSource
        tableView.delegate = self
    }
    
    func setupLocationManager() {
        locationManager.updateFrequency = 30 * 60
        locationManager.changedLocationCallback = { location, city in
            if let l = location {
                self.dataSource.currentLocation = l.location!
            }
            self.userCity = city
            self.requestDataForCity(city)
        }
    }
    
    func setupCityFilterButton() {
        if let city = self.currentCity {
            cityFilterButton.setTitle(city.name!, forState: .Normal)
        }
        else {
            cityFilterButton.setTitle("Todas as cidades", forState: .Normal)
        }
    }
    
    func registerObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PromotionListVC.handleBackFromFilterNotification(_:)), name: Constants.Notifications.backFromFilter, object: nil)
    }
    
    @IBAction func pushToFilter() {
        performSegueWithIdentifier(Constants.GlobalSegues.cityFilter, sender: nil)
    }
    
    func requestDataForCity(city:City?) {
        self.currentCity = city
        if !Reachability.isConnectedToNetwork() {
            presentNoInternetAlert()
        } else {
            splashWasShowed = false
            startCustomLoading()
            self.dataSource.getPromotionsForCity(city) {
                self.stopCustomLoading()
                self.tableView.scrollToTop()
                self.tableView.flashScrollIndicators()
            }
        }
    }
    
    func requestUserLocation() {
        if hasContent() {
            return
        }
        
        startCustomLoading()
        
        if Reachability.isConnectedToNetwork() {
            locationManager.requestUserLocation()
        } else {
            presentNoInternetAlert()
        }
    }
    
    // MARK: - Navigation
    
    func presentNoInternetAlert() {
        let alert = UIAlertController(title: "", message: "Verifique sua conexão com a internet e tente novamente", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Tentar novamente", style: .Default, handler: { _ in
            self.requestUserLocation()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kSegueEstablishmentDetail {
            let controller = segue.destinationViewController as! PromotionDetailVC
            controller.establishmentPromotion = sender as! EstablishmentPromotion
            controller.currentLocation = dataSource.currentLocation
        }
        else if segue.identifier == kSegueEstablishmentFeaturedPromotionDetail {
            let controller = segue.destinationViewController as! PromotionDetailVC
            controller.establishmentPromotion = (sender as! FeaturedPromotionHeader).promotion
            controller.currentLocation = dataSource.currentLocation
        }
        else if segue.identifier == kSeguePromotionFilter {
            let controller = segue.destinationViewController as! PromotionListBuilderVC
            controller.currentLocation = dataSource.currentLocation
            controller.filteredPromotions = dataSource.promotions
            controller.currentCity = self.currentCity
        }
        else if segue.identifier == Constants.GlobalSegues.cityFilter {
            let controller = (segue.destinationViewController as! UINavigationController).viewControllers.first as! CityFilterVC
            controller.delegate = self
        }
    }
    
    // MARK: - Notification Handler
    
    func handleBackFromFilterNotification(notification: NSNotification) {        
        if let city = notification.object as? City {
            self.currentCity = city
            dataSource.getPromotionsForCity(city) {
                self.tableView.scrollToTop()
                self.tableView.flashScrollIndicators()
            }
        }
    }
    
    // MARK: - Actions

    @IBAction func refresh(sender: UIRefreshControl) {
        dataSource.getPromotionsForCity(self.currentCity) {
            sender.endRefreshing()
            self.tableView.scrollToTop()
            self.tableView.flashScrollIndicators()
        }
    }

    @IBAction func menuAction(sender: UIBarButtonItem) {
        let targetStoryboardName = "UserManagement"
        let targetStoryboard = UIStoryboard(name: targetStoryboardName, bundle: nil)
        let rootController = targetStoryboard.instantiateInitialViewController() as! UINavigationController
        self.navigationController?.pushViewController(rootController.viewControllers.first!, animated: true)
    }
}

extension PromotionListVC : CityFilterDelegate {

    // MARK: - CityFilterDelegate
    
    func selectedCity(city:City) {
        self.requestDataForCity(city)
    }
}