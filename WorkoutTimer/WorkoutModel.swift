//
//  WorkoutModel.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/23/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Workout {
    
    enum CurrentTimer {
        
        case interval
        case transition
        
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var workoutInfo = [WorkoutInfo]()
    
    func saveData() {
        
        do {
            
            try context.save()
            
        } catch {
            
            print("Error saving data: \(error)")
            
        }
        
    }
    
    func loadData() {
        
        let request: NSFetchRequest<WorkoutInfo> = WorkoutInfo.fetchRequest()
        
        do {
            
            workoutInfo = try context.fetch(request)
            
        } catch {
            
            print("Error loading Workout Info: \(error)")
            
        }
        
    }
    
}










