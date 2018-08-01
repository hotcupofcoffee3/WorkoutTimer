//
//  RoutineTableViewCell.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 8/1/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class RoutineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var routineNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
