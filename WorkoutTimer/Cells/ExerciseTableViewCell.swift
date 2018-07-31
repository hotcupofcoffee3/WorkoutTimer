//
//  ExerciseTableViewCell.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {

    @IBOutlet weak var exerciseView: UIView!
    
    @IBOutlet weak var exerciseNameLabel: UILabel!
    
    @IBOutlet weak var exerciseTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
