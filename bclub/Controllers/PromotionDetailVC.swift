//
//  EstablishmentPromotionDetailVC.swift
//  bclub
//
//  Created by Bruno Gama on 30/05/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Eureka
import Pluralize_swift
import Nuke

class PromotionDetailVC: FormViewController {
    var establishmentPromotion:EstablishmentPromotion!
    var currentLocation:CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = establishmentPromotion.establishment?.name
        setupInitialValues()
        setupForm()
    }
    
    // MARK: Actions
    
    @IBAction func openActionController(sender: AnyObject) {
        let type = establishmentPromotion.establishment?.category?.name!
        let name = establishmentPromotion.establishment?.name!
        let promotionString = establishmentPromotion.promotions!.count == 1 ? "tem uma promoção" : "está com as seguintes promoções"
        var shareMessage = "O(a) \(type!), \(name!) \(promotionString)"
        establishmentPromotion.promotions?.forEach{ promotion in
            let formattedPromotionString = "\(Int(promotion.percent as Double * 100))% \(self.formattedInformation(promotion))"
            shareMessage += "\n"+formattedPromotionString
        }
    
        let shareVC: UIActivityViewController = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
        self.presentViewController(shareVC, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func setupInitialValues() {
        tableView?.backgroundColor = UIColor.bclBlackTwoColor()
        tableView?.tableFooterView = UIView()
        tableView?.separatorStyle = .None
        tableView?.indicatorStyle = .White
    }
    
    private func setupForm() {
        form +++ Section { section in
            var headerFooter = HeaderFooterView<UIView>(HeaderFooterProvider.Class)
            headerFooter.height = { 10 }
            
            section.header = headerFooter
            section.footer = headerFooter
        }
        setupHeader(establishmentPromotion)
        
        form +++ Section { section in
            var headerFooter = HeaderFooterView<UIView>(HeaderFooterProvider.Class)
            headerFooter.height = { 10 }
            
            section.header = headerFooter
            section.footer = headerFooter
        }
        setupDiscountInformation(establishmentPromotion.promotions!)
        
        form +++ Section { section in
            var headerFooter = HeaderFooterView<UIView>(HeaderFooterProvider.Class)
            headerFooter.height = { 10 }
            
            section.header = headerFooter
            section.footer = headerFooter
        }
        let establishmentPromotionContent = EstablishmentPromotionContent(establishmentPromotion)
        setupTextData(establishmentPromotionContent.paragraphData())

        form +++ Section { section in
            var headerFooter = HeaderFooterView<UIView>(HeaderFooterProvider.Class)
            headerFooter.height = { 10 }
            
            section.header = headerFooter
            section.footer = headerFooter
        }
        setupMap(establishmentPromotion.establishment!)
        
        self.tableView?.flashScrollIndicators()
    }
    
    private func setupMap(establishment:Establishment) {
        form.last!
            <<< MapRow { row in
                row.value = establishment
                row.cellSetup { cell, row in
                    cell.mapView.delegate = self
                    let delta = 10000.0
                    
                    if let geoLocation = establishment.address?.geolocation! {
                        let toLocation = CLLocation(latitude: geoLocation.latitude.doubleValue,
                            longitude: geoLocation.longitude.doubleValue)
                        let placemark: MKPlacemark = MKPlacemark( coordinate:toLocation.coordinate, addressDictionary: nil)
                        var region: MKCoordinateRegion = cell.mapView.region
                        region.center = (toLocation.coordinate)
                        region.span.longitudeDelta /= delta
                        region.span.latitudeDelta /= delta
                        cell.mapView.setRegion(region, animated: true)
                        cell.mapView.addAnnotation(placemark)
                    }
                        
                    else {
                        let location = establishment.address?.description
                        let geocoder:CLGeocoder = CLGeocoder();
                        geocoder.geocodeAddressString(location!) { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
                            if placemarks?.count > 0 {
                                let topResult:CLPlacemark = placemarks![0]
                                let placemark: MKPlacemark = MKPlacemark(placemark: topResult)
                                
                                var region: MKCoordinateRegion = cell.mapView.region
                                region.center = (placemark.location?.coordinate)!
                                region.span.longitudeDelta /= delta
                                region.span.latitudeDelta /= delta
                                cell.mapView.setRegion(region, animated: true)
                                cell.mapView.addAnnotation(placemark)
                                
                            }
                        }
                    }
                }
        }
    }
    
    
    private func imageRequest(url:NSURL) -> ImageRequest {
        var request = ImageRequest(URLRequest: NSURLRequest(URL: url))
        request.targetSize = CGSize(width: 532.0, height: 252.0)
        request.contentMode = .AspectFill
        request.memoryCacheStorageAllowed = true
        request.memoryCachePolicy = .ReloadIgnoringCachedImage
        request.priority = NSURLSessionTaskPriorityHigh
        return request
    }

    private func setupHeader(establishmentPromotion:EstablishmentPromotion) {
        let rowTag = "headerRow"
        form.last!
            <<< EstablishmentPromotionDetailHeaderRow() { row in
                row.tag = rowTag
                row.value = establishmentPromotion
                row.cellSetup { cell, row in
                    
                    if let imageUrl = establishmentPromotion.imageUrl {
                        let url  = NSURL(string:imageUrl)
                        if url != nil {
                            Nuke.taskWith(self.imageRequest(url!)) {
                                cell.promotionImageView.image = nil
                                cell.promotionImageView.image = $0.image
                            }.resume()
                        }
                    }
                    
                    
                    if let type = establishmentPromotion.establishment?.category?.name {
                        cell.typeLabel.text = type
                    }
                    else {
                        cell.typeLabel.text = ""
                    }
                    cell.nameLabel.text                    = establishmentPromotion.establishment?.name?.uppercaseString
                    let neighborhood = establishmentPromotion.establishment?.address?.neighborhood?.name
                    if self.currentLocation != nil {
                        if let toGeoPoint = establishmentPromotion.establishment?.address?.geolocation {
                            if let roundedTwoDigit = self.currentLocation?.formattedDistanceFromGeoPoint(toGeoPoint) {
                                cell.neighborhoodAndDistanceLabel.text = "\(neighborhood!) - \(roundedTwoDigit) Km"
                            }
                        }
                    } else {
                        cell.neighborhoodAndDistanceLabel.text = neighborhood!
                    }
                    cell.neighborhoodAndDistanceLabel.sizeToFit()
                }
        }
    }
    
    
    private func setupDiscountInformation(promotions:[Promotion]) {
        for (index, promotion) in promotions.enumerate() {
            let rowTag = "discount_row_\(index)"
            form.last! <<< DiscountInformationRow { row in
                row.tag = rowTag
                row.value = promotion
                row.cellSetup { cell, row in
                    cell.disccountLabel.text = "\(Int(promotion.percent as Double * 100))%"
                    cell.informationLabel.text = self.formattedInformation(promotion)
                    cell.informationLabel.sizeToFit()
                }
            }
        }
    }

    func timeTable(promotion:Promotion) -> [String]! {
        return [promotion.sunday,
                promotion.monday,
                promotion.tuesday,
                promotion.wednesday,
                promotion.thursday,
                promotion.friday,
                promotion.saturday]
    }

    func formattedInformation(promotion:Promotion) -> String {
        let fmt = NSDateFormatter()
        fmt.locale = NSLocale(localeIdentifier: "pt_BR")
        
        var daysOfTheWeekWithPromotion: [String] = []
        let booleanDaysOftheWeekWithPromotion = timeTable(promotion).map{ (!$0.isEmpty) }
        
        for (i, d) in booleanDaysOftheWeekWithPromotion.enumerate() {
            if d {
                daysOfTheWeekWithPromotion.append(fmt.weekdaySymbols[i])
            }
        }
        
        daysOfTheWeekWithPromotion = daysOfTheWeekWithPromotion.map { weekDay in
            weekDay.uppercaseString.stringByReplacingOccurrencesOfString("-FEIRA", withString: "").capitalizedString
        }
        
        let labelText = daysOfTheWeekWithPromotion.joinWithSeparator(", ")

        return labelText
    }
    
    
    private func setupTextData(formParagraphs:[NSMutableAttributedString]) {
        for (index, attrString) in formParagraphs.enumerate() {
            let rowTag = "paragraph_row_\(index + 1)"
            form.last! <<< SimpleTextRow { row in
                row.tag = rowTag
                row.value = attrString.string
                row.cellSetup { cell, row in
                    cell.label.attributedText = attrString
                    cell.label.sizeToFit()
                }
            }
        }
    }
}

extension PromotionDetailVC : MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationReuseId = "Place"
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(annotationReuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationReuseId)
        } else {
            anView!.annotation = annotation
        }
        // Resize image
        let pinImage = UIImage(named: "UIMapPin")
        let size = CGSize(width: 13, height: 16)
        UIGraphicsBeginImageContext(size)
        pinImage!.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        anView!.image = resizedImage
        anView!.backgroundColor = UIColor.clearColor()
        anView!.canShowCallout = false
        return anView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        openMapForPlaceAnnotation(view.annotation!)
    }
    
    func openMapForPlaceAnnotation(annotation: MKAnnotation) {
        let regionDistance:CLLocationDistance = 500
        let coordinates = annotation.coordinate
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [ MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center), MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = establishmentPromotion.establishment?.name
        mapItem.openInMapsWithLaunchOptions(options)
    }    
    
}
