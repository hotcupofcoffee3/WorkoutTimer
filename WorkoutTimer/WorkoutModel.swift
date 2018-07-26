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
        
        if workoutInfoArray.isEmpty {
            
            return print("Something went wrong: 'workoutInfoArray' had no object in it.")
            
        } else if workoutInfoArray.count > 1 {
            
            return print("Something went wrong: 'workoutInfoArray' had more than 1 object in it.")
            
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
////            let newWorkout = WorkoutInfo(context: context)
////            newWorkout.sets = 5
////            self.saveData()
//            print("Nothing")
//            print(workoutInfoArray.count)
//
//        } else {
//
//            print(workoutInfoArray.count)
//
////            let newWorkout = WorkoutInfo(context: context)
////            newWorkout.sets = 5
//
////            for item in workoutInfoArray {
////
////                context.delete(item)
////                saveData()
////
////            }
//
//        }
        
    }
    
}










