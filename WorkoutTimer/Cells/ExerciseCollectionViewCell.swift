//
//  ExerciseCollectionViewCell.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class ExerciseCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var exerciseCellView: UIView!
    
    @IBOutlet weak var exerciseNameLabel: UILabel!
    
    @IBOutlet weak var exerciseTimeLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        exerciseCellView.layer.borderColor = UIColor.white.cgColor
        exerciseCellView.layer.borderWidth = 1
    }

}
