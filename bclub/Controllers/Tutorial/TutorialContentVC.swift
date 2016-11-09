//
//  TutorialContentVC.swift
//  bclub
//
//  Created by Douglas on 07/06/16.
//  Copyright © 2016 bclub. All rights reserved.
//

import UIKit

class TutorialContentVC: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!    
    
    // MARK: - Properties
    
    var pageIndex: Int!
    var titleText: String!
    var backgroundImage: UIImage!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleText
        backgroundImageView.image = backgroundImage
    }

}
