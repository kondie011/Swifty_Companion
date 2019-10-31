//
//  ProjectTableViewCell.swift
//  Swifty Companion
//
//  Created by Kondelelani NEDZINGAHE on 2019/10/22.
//  Copyright © 2019 Kondelelani NEDZINGAHE. All rights reserved.
//

import UIKit

class ProjectTableViewCell: UITableViewCell {

    @IBOutlet weak var projName: UILabel!
    @IBOutlet weak var projMark: UILabel!
    
    var projItem: (String, String, UIColor)!{
        didSet{
            if let p = projItem{
                projName.text = p.0;
                projMark.text = p.1;
                projMark.textColor = p.2;
            }
        }
    }
}
