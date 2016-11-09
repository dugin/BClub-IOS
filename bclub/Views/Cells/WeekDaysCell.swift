//
//  WeekDaysCell.swift
//  bclub
//
//  Created by Douglas on 03/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import Foundation
import Eureka
import SwiftyColor

public enum WeekDay: Int {
    case Monday = 1
    case Tuesday = 2
    case Wednesday = 3
    case Thursday = 4
    case Friday = 5
    case Saturday = 6
    case Sunday = 0
}

public class WeekDayCell : Cell<Set<WeekDay>>, CellType {
    
    @IBOutlet var sundayButton: UIButton!
    @IBOutlet var mondayButton: UIButton!
    @IBOutlet var tuesdayButton: UIButton!
    @IBOutlet var wednesdayButton: UIButton!
    @IBOutlet var thursdayButton: UIButton!
    @IBOutlet var fridayButton: UIButton!
    @IBOutlet var saturdayButton: UIButton!
    @IBOutlet weak var buttonsContainerView: UIView!
    
    public override func setup() {
        height = { 60 }
        row.title = nil
        super.setup()
        selectionStyle = .None
        for subview in buttonsContainerView.subviews {
            if let button = subview as? UIButton {
                button.backgroundColor = Color.clear
                button.setBackgroundImage(UIImage(color:Color.bclRosyPinkColor()) , forState: .Normal)
                button.setBackgroundImage(UIImage(color:Color.bclBlackColor()) , forState: .Selected)
                button.setTitleColor(Color.white, forState: .Normal)
                button.setTitleColor(Color.white.colorWithAlphaComponent(0.2), forState: .Selected)
            }
        }
    }
    
    public override func update() {
        row.title = nil
        super.update()
        let value = row.value
        mondayButton.selected = value?.contains(.Monday) ?? false
        tuesdayButton.selected = value?.contains(.Tuesday) ?? false
        wednesdayButton.selected = value?.contains(.Wednesday) ?? false
        thursdayButton.selected = value?.contains(.Thursday) ?? false
        fridayButton.selected = value?.contains(.Friday) ?? false
        saturdayButton.selected = value?.contains(.Saturday) ?? false
        sundayButton.selected = value?.contains(.Sunday) ?? false
        
        mondayButton.alpha = row.isDisabled ? 0.6 : 1.0
        tuesdayButton.alpha = mondayButton.alpha
        wednesdayButton.alpha = mondayButton.alpha
        thursdayButton.alpha = mondayButton.alpha
        fridayButton.alpha = mondayButton.alpha
        saturdayButton.alpha = mondayButton.alpha
        sundayButton.alpha = mondayButton.alpha
    }
    
    @IBAction func dayTapped(sender: UIButton) {
        dayTapped(sender, day: getDayFromButton(sender))
    }
    
    private func getDayFromButton(button: UIButton) -> WeekDay{
        switch button{
        case sundayButton:
            return .Sunday
        case mondayButton:
            return .Monday
        case tuesdayButton:
            return .Tuesday
        case wednesdayButton:
            return .Wednesday
        case thursdayButton:
            return .Thursday
        case fridayButton:
            return .Friday
        default:
            return .Saturday
        }
    }
    
    private func dayTapped(button: UIButton, day: WeekDay){
        button.selected = !button.selected
        if button.selected{
            row.value?.insert(day)
        }
        else{
            row.value?.remove(day)
        }                
    }

}

//MARK: WeekDayRow

public final class WeekDayRow: Row<Set<WeekDay>, WeekDayCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<WeekDayCell>(nibName: "WeekDaysCell")
    }
}
