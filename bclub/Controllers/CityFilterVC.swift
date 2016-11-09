//
//  CityFilterVC.swift
//  bclub
//
//  Created by Douglas on 31/05/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import UIKit
import SwiftyColor
import SnapKit
import Crashlytics

class CityFilterVC: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    weak var delegate:CityFilterDelegate?
    
    // MARK: - Properties
    
    var cityList: [City] = []
    var debounceTimer: NSTimer?
    var apiClient = ApiClient()
    var emptyStateLabel: UILabel!
    
    let fontName = "OpenSans-Light"
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupInitialValues()
        setupSearchBar()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Helpers
    
    func setupInitialValues() {
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            view.backgroundColor = Color.clear
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            view.insertSubview(blurEffectView, atIndex: 0)
        }
        else {
            self.view.backgroundColor = Color.bclBlackColor()
        }
        
        tableView.separatorColor = Color.bclWarmGreyColor()
        emptyStateLabel = UILabel()
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.textColor = Color.white
        emptyStateLabel.textAlignment = .Center
        emptyStateLabel.text = "Nenhuma cidade encontrada"
    }
    
    func setupSearchBar() {
        let defaltCity = NSUserDefaults.standardUserDefaults().defaultCity == nil ? "Todas as cidades" :  NSUserDefaults.standardUserDefaults().defaultCity
        
        searchBar.placeholder  = defaltCity
        searchBar.delegate = self
        
        searchBar.tintColor = Color.white
        
        let searchField = searchBar.valueForKey("searchField") as! UITextField
        searchField.textColor = Color.white
        searchField.font = UIFont(name: fontName, size:16)!
                
        
        let clearButton = searchField.valueForKey("clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView!.image?.imageWithRenderingMode(.AlwaysTemplate), forState: UIControlState.Normal)
        clearButton.tintColor = Color.white
        
        let imageView = UIImageView(image: UIImage(named: "UiCityPin"))
        searchField.leftView = imageView
        
        let placeholderLabel = searchField.valueForKey("placeholderLabel") as? UILabel
        placeholderLabel?.textColor = Color.white
        
        searchField.backgroundColor = Color.bclBlackColor()
        searchBar.backgroundImage = UIImage(color: Color.bclBlackColor())
    }
    
    func fetchData(onComplete:(()->Void)?) {
        
        apiClient.getCitiesWithString(searchBar.text!) { result in
            
            switch result {
            case .Success(let cities):
                self.cityList = cities!
                if !self.searchBar.text!.isEmpty {
                    self.tableView.reloadData()
                    if self.cityList.count == 0 {
                        self.showEmptyState()
                    }
                    else {
                        self.removeEmptyState()
                    }
                    if let callback = onComplete {
                        callback()
                    }
                }
            case .Failure(_):
                break
            }
            
        }
    }
    
    func debounceFetchData() {
        fetchData(nil)
    }
    
    private func citiesQuery() -> BackendlessDataQuery {
        let query:BackendlessDataQuery = BackendlessDataQuery()
        query.whereClause = "name LIKE '\(searchBar.text!)%'"
        return query
    }
    
    func showEmptyState() {
        if emptyStateLabel.superview == nil {
            view.addSubview(emptyStateLabel)
            
            emptyStateLabel.snp_makeConstraints() { make in
                make.centerX.equalTo(view.snp_centerX)
                make.top.equalTo(searchBar.snp_bottom).offset(20)
                make.left.equalTo(view.snp_left).offset(20)
                make.right.equalTo(view.snp_right).offset(-20)
            }
        }
    }
    
    func removeEmptyState() {
        if emptyStateLabel.superview != nil {
            emptyStateLabel.removeFromSuperview()
        }
    }

    // MARK: - IBAction
    
    @IBAction func dismissVC(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

// MARK: - Table View -

extension CityFilterVC: UITableViewDelegate, UITableViewDataSource {
    
    struct TableViewConstants {
        static let cellIdentifier = "CityCell"
    }
    
    func bindCell(cell: CityTableViewCell, withCity city: City) {
        cell.backgroundColor = Color.bclBlackColor()
        cell.nameLabel.textColor = Color.white
        cell.nameLabel.text = city.name
    }
    
    // MARK: - DataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewConstants.cellIdentifier) as! CityTableViewCell
        
        let city = cityList[indexPath.row]
        bindCell(cell, withCity: city)
        
        return cell
    }
    
    // MARK: - Delegate
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let city = cityList[indexPath.row]
    
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.delegate!.selectedCity(city)
        dismissViewControllerAnimated(true) {}
    }
}

// MARK: - UISearchBarDelegate -

extension CityFilterVC: UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let timer = debounceTimer {
            timer.invalidate()
        }
        
        if searchBar.text!.isEmpty {
            cityList = []
            tableView.reloadData()
            removeEmptyState()
        }
        else {
            debounceTimer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: #selector(CityFilterVC.debounceFetchData), userInfo: nil, repeats: false)
        }
    }
    
}
