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
    
    var setIntervalMinutes: Int = 0
    var setIntervalSeconds: Int = 0
    var setNumberOfSets: Int = 0
    var setTransitionMinutes: Int = 0
    var setTransitionSeconds: Int = 0
    
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
            
            return print("'workoutInfoArray' has \(workoutInfoArray.count)")
            
        }
        
    }
    
    func getWorkoutInfo() -> WorkoutInfo {
        
        return workoutInfoArray[0]
        
    }
    
    func saveIntervalTime(minutes: Int, seconds: Int) {
        
        let workoutInfo = getWorkoutInfo()
        
        workoutInfo.intervalMinutes = Int64(minutes)
        workoutInfo.intervalSeconds = Int64(seconds)
        
        saveData()
        
    }
    
    func saveTransitionTime(minutes: Int, seconds: Int) {
        
        let workoutInfo = getWorkoutInfo()
        
        workoutInfo.transitionMinutes = Int64(minutes)
        workoutInfo.transitionSeconds = Int64(seconds)
        
        saveData()
        
    }
    
    func saveSets(sets: Int) {
        
        let workoutInfo = getWorkoutInfo()
        
        workoutInfo.sets = Int64(sets)
        
        saveData()
        
    }
    
    func saveNewWorkoutInfoObject() {
        
        let newWorkout = WorkoutInfo(context: context)
        
        newWorkout.intervalMinutes = 0
        newWorkout.intervalSeconds = 0
        newWorkout.sets = 10
        newWorkout.transitionMinutes = 0
        newWorkout.transitionSeconds = 0
        
        self.saveData()
        
    }
    
    func deleteAllSavedWorkoutInfoObjects() {
        
        loadData()
        
        for item in workoutInfoArray {
            
            context.delete(item)
            
        }
        
        saveData()
        
    }
    
    init() {
        
//        deleteAllSavedWorkoutInfoObjects()
        
        self.loadData()

        if self.workoutInfoArray.count == 0 {

            saveNewWorkoutInfoObject()

        }

        let workoutInfo = getWorkoutInfo()

        self.setIntervalMinutes = Int(workoutInfo.intervalMinutes)
        self.setIntervalSeconds = Int(workoutInfo.intervalSeconds)
        self.setNumberOfSets = Int(workoutInfo.sets)
        self.setTransitionMinutes = Int(workoutInfo.transitionMinutes)
        self.setTransitionSeconds = Int(workoutInfo.transitionSeconds)
        
    }
    
}










