//
//  WeekdaysView.swift
//  bclub
//
//  Created by Bruno Gama on 09/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import SwiftyColor

@IBDesignable class WeekdaysView: UIView {

    @IBOutlet var weekdayLabels: [UILabel]!
    var view: UIView!

    private var _weekdays:[Bool] = (0..<7).map{ _ in false }
    var weekdays:[Bool] {
        get {
            return self._weekdays
        }
        set {
            self._weekdays = newValue
            configureLabels()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        xibSetup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        xibSetup()
    }
    
    // MARK: - Private Methods
    
    private func disableLabel(label:UILabel) {
        label.textColor = Color.bclDisabledWeekdayTextColor()
        label.backgroundColor = Color.bclDisabledWeekdayBackgroundColor()
    }
    
    private func enableLabel(label:UILabel) {
        label.textColor = Color.white
        label.backgroundColor = Color.bclRosyPinkColor()
    }
    
    private func configureLabels() {
        for (index, enableWeekDay) in self._weekdays.enumerate() {
            if enableWeekDay {
                enableLabel(weekdayLabels[index])
            } else {
                disableLabel(weekdayLabels[index])
            }
        }
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "WeekdaysView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        addSubview(view)
    }
}