//
//  TimerModel.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 8/20/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation

class WorkoutTimer {
    
    func zero(unit: Int) -> String {
        
        var zero = "\(unit)"
        
        if unit <= 9 {
            
            zero = "0\(unit)"
            
        }
        
        return zero
        
    }
    
}
