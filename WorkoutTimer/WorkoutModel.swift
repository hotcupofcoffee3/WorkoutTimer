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
        case rest
        
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var workoutInfoArray = [WorkoutInfo]()
    var exerciseArray = [Exercise]()
    
    var currentSet = 1
    var currentExercise = 1
    
    var setNumberOfSets: Int = 0
    
    var setTransitionMinutes: Int = 0
    var setTransitionSeconds: Int = 0
    
    var setRestMinutes: Int = 0
    var setRestSeconds: Int = 0
    
    var setTotalIntervalSeconds: Int = 0
    var setTotalTransitionSeconds: Int = 0
    
    var remainingIntervalMinutes: Int = 0
    var remainingIntervalSeconds: Int = 0
    
    var remainingTransitionMinutes: Int = 0
    var remainingTransitionSeconds: Int = 0
    
    var totalSecondsForProgress = 0
    
    func saveData() {
        
        do {
            
            try context.save()
            
        } catch {
            
            print("Error saving data: \(error)")
            
        }
        
    }
    
    func loadWorkoutData() {
        
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
    
    func loadExercises() {
        
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        
        do {
            
            exerciseArray = try context.fetch(request)
            
        } catch {
            
            print("Error loading Workout Info: \(error)")
            
        }
        
        if exerciseArray.isEmpty {
            
            return print("Something went wrong: 'exerciseArray' had no object in it.")
            
        }
        
    }
    
    func getWorkoutInfo() -> WorkoutInfo {
        
        return workoutInfoArray[0]
        
    }
    
    func getExercise(named: String) -> Exercise? {
        
        var exerciseToReturn: Exercise?
        
        for exercise in exerciseArray {
            
            if exercise.name == named {
                
                exerciseToReturn = exercise
                
            }
            
        }
        
        return exerciseToReturn
        
    }
    
    func saveIntervalTime(exerciseName: String, minutes: Int, seconds: Int) {
        
        guard let exercise = getExercise(named: exerciseName) else { return }
        
        exercise.intervalMinutes = Int64(minutes)
        exercise.intervalSeconds = Int64(seconds)
        
        saveData()
        
    }
    
    func saveTransitionTime(minutes: Int, seconds: Int) {
        
        let workoutInfo = getWorkoutInfo()
        
        workoutInfo.transitionMinutes = Int64(minutes)
        workoutInfo.transitionSeconds = Int64(seconds)
        
        saveData()
        
        setTransitionMinutes = minutes
        setTransitionSeconds = seconds
        
    }
    
    func saveRestTime(minutes: Int, seconds: Int) {
        
        let workoutInfo = getWorkoutInfo()
        
        workoutInfo.restMinutes = Int64(minutes)
        workoutInfo.restSeconds = Int64(seconds)
        
        saveData()
        
        setRestMinutes = minutes
        setRestSeconds = seconds
        
    }
    
    func saveSets(sets: Int) {
        
        let workoutInfo = getWorkoutInfo()
        
        workoutInfo.sets = Int64(sets)
        
        saveData()
        
        setNumberOfSets = sets
        
    }
    
    func makeSureInitialWorkoutInfoObjectIsCreated() {
        
        if self.workoutInfoArray.count == 0 {
            
            saveNewWorkoutInfo()
            
            loadWorkoutData()
            
        }
        
    }
    
    func saveNewWorkoutInfo() {
        
        let newWorkout = WorkoutInfo(context: context)
        
        newWorkout.restMinutes = 0
        newWorkout.restSeconds = 0
        newWorkout.sets = 10
        newWorkout.transitionMinutes = 0
        newWorkout.transitionSeconds = 0
        
        self.saveData()
        
    }
    
    func saveNewExercise(named: String) {
        
        let newExercise = Exercise(context: context)
        
        newExercise.intervalMinutes = 0
        newExercise.intervalSeconds = 0
        newExercise.name = named
        
        self.saveData()
        
    }
    
    func deleteAllSavedWorkoutInfoObjects() {
        
        loadWorkoutData()
        
        for item in workoutInfoArray {
            
            context.delete(item)
            
        }
        
        saveData()
        
    }
    
    func setRemainingToSetAmounts() {
        
//        remainingIntervalMinutes = setIntervalMinutes
//        
//        remainingIntervalSeconds = setIntervalSeconds
        
        remainingTransitionMinutes = setTransitionMinutes
        
        remainingTransitionSeconds = setTransitionSeconds
        
    }
    
    init() {
        
//        deleteAllSavedWorkoutInfoObjects()
        
        self.loadWorkoutData()

        self.makeSureInitialWorkoutInfoObjectIsCreated()

        let workoutInfo = getWorkoutInfo()

        self.setNumberOfSets = Int(workoutInfo.sets)
        
        self.setTransitionMinutes = Int(workoutInfo.transitionMinutes)
        self.setTransitionSeconds = Int(workoutInfo.transitionSeconds)
        
        self.setRestMinutes = Int(workoutInfo.restMinutes)
        self.setRestSeconds = Int(workoutInfo.restSeconds)
        
//        self.setTotalIntervalSeconds = (setIntervalMinutes * 60) + setIntervalSeconds
        self.setTotalTransitionSeconds = (setTransitionMinutes * 60) + setTransitionSeconds
        
//        self.remainingIntervalMinutes = setIntervalMinutes
//        self.remainingIntervalSeconds = setIntervalSeconds
        
        self.remainingTransitionMinutes = setTransitionMinutes
        self.remainingTransitionSeconds = setTransitionSeconds
        
    }
    
}










