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
    
    var workoutInfoArray = [WorkoutInfo]()
    
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
            
            workoutInfoArray = try context.fetch(request)
            
        } catch {
            
            print("Error loading Workout Info: \(error)")
            
        }
        
        if workoutInfoArray.isEmpty || workoutInfoArray.count > 1 {
            
            return print("Something went wrong loading the 'workoutInfoArray' because it had no object or more than 1 object in it.")
            
        }
        
    }
    
    func getWorkoutInfo() -> WorkoutInfo {
        
        loadData()
        
        return workoutInfoArray[0]
        
    }
    
    init() {
        
//        self.loadData()
//        if self.workoutInfoArray.count == 0 {
//            
//            let newWorkout = WorkoutInfo(context: context)
////            newWorkout.intervalMinutes = 0
//            self.saveData()
//            
//        }
        
    }
    
}










