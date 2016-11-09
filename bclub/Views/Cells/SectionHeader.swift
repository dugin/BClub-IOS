//
//  SectionHeader.swift
//  bclub
//
//  Created by Bruno Gama on 03/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import UIKit

class SectionHeader: UIView {
    
    @IBOutlet weak private var titleLabel: UILabel!
    var title:String? {
        didSet {
            titleLabel.text = title
        }
    }
}