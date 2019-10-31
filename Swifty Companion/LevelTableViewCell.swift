//
//  LevelTableViewCell.swift
//  Swifty Companion
//
//  Created by Kondelelani NEDZINGAHE on 2019/10/22.
//  Copyright © 2019 Kondelelani NEDZINGAHE. All rights reserved.
//

import UIKit

class LevelTableViewCell: UITableViewCell {

    @IBOutlet weak var skillName: UILabel!
    @IBOutlet weak var skillLevel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var skillItem: (String, String, Float)!{
        didSet{
            if let s = skillItem{
                skillName.text = s.0;
                skillLevel.text = s.1;
                progressBar.setProgress(s.2, animated: true);
                progressBar.tintColor = UIColor(red: CGFloat(0.0), green: CGFloat(s.2), blue: CGFloat(0.3), alpha: CGFloat(1.0 - s.2));
            }
        }
    }
}
