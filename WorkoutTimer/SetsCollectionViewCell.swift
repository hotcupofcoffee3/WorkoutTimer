//
//  SetsCollectionViewCell.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/23/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class SetsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var setNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setNumberLabel.layer.borderColor = UIColor.white.cgColor
        setNumberLabel.layer.borderWidth = 1
    }

}
