//
//  LocationManager.swift
//  bclub
//
//  Created by Bruno Gama on 22/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    
    let locationManager = CLLocationManager()
    var locationManagerTimer = NSTimer()
    var changedLocationCallback: ((locationCoordinate:CLLocationCoordinate2D?, city:City?) -> Void)?
    var distanceThreshold: CLLocationDistance = 5000
    var updateFrequency: NSTimeInterval = 40 * 60
    var gpsTimeout = NSTimer()
    let TIMEOUT = 8.0
    var GPS_DID_TIMEOUT = false
    private var _lastAvailableCoordinate:CLLocationCoordinate2D?
    let apiClient = ApiClient()
    var city:City?
    
    var lastAvailableCoordinate:CLLocationCoordinate2D? {
        set {
            if let lastAvailableLocation = _lastAvailableCoordinate?.location, let location = newValue?.location {
                if lastAvailableLocation.distanceFromLocation(location) > distanceThreshold {
                    fetchCityWithLocation(location)
                }
            } else if let location = newValue?.location {
                fetchCityWithLocation(location)
            }
            
            _lastAvailableCoordinate = newValue
        }
        
        get {
            return _lastAvailableCoordinate
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func requestUserLocation() {
        if GPS_DID_TIMEOUT {
            stopUpdating()
            return
        }
        
        setupTimeout()
        locationManager.requestWhenInUseAuthorization()
        if canRequestLocation() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopUpdating() {
        GPS_DID_TIMEOUT = true
        locationManager.stopUpdatingLocation()
        gpsTimeout.invalidate()
        self.changedLocationCallback?(locationCoordinate: nil, city:nil)
    }
    
    func canRequestLocation() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    func resetManagerStateAndUpdateLocation() {
        setupTimeout()
        requestUserLocation()
    }
    
    private func fetchCityWithLocation(location:CLLocation) {
        self.apiClient.getCityWithLocation(location) { result in
            switch result {
            case .Success(let city):
                self.city = city
            default:
                self.city = nil
            }
            self.GPS_DID_TIMEOUT = false
            self.gpsTimeout.invalidate()
            self.changedLocationCallback?(locationCoordinate: location.coordinate, city:self.city)
        }
    }
    
    private func setupTimeout() {
        GPS_DID_TIMEOUT = false
        gpsTimeout.invalidate()
        gpsTimeout = NSTimer.scheduledTimerWithTimeInterval(TIMEOUT, target: self, selector: #selector(stopUpdating), userInfo: nil, repeats: false)
    }
    
    private func setupManagerUpdateInterval(manager: CLLocationManager) {
        manager.stopUpdatingLocation()
        locationManagerTimer.invalidate()
        locationManagerTimer = NSTimer.scheduledTimerWithTimeInterval(updateFrequency, target: self, selector: #selector(resetManagerStateAndUpdateLocation), userInfo: nil, repeats: false)
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationValue = manager.location?.coordinate else {
            return
        }
        
        setupManagerUpdateInterval(manager)
        lastAvailableCoordinate = locationValue
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        setupManagerUpdateInterval(manager)
        setupTimeout()
        GPS_DID_TIMEOUT = true
        lastAvailableCoordinate = nil
    }
}