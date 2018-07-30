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
    var currentExerciseIndex = 0
    
    var setNumberOfSets: Int = 0
    
    var setTransitionMinutes: Int = 0
    var setTransitionSeconds: Int = 0
    
    var setRestMinutes: Int = 0
    var setRestSeconds: Int = 0
    
    var setTotalIntervalSeconds: Int = 0
    var setTotalTransitionSeconds: Int = 0
    var setTotalRestSeconds: Int = 0
    
    var remainingIntervalMinutes: Int = 0
    var remainingIntervalSeconds: Int = 0
    
    var remainingTransitionMinutes: Int = 0
    var remainingTransitionSeconds: Int = 0
    
    var remainingRestMinutes: Int = 0
    var remainingRestSeconds: Int = 0
    
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
            
            return print("'workoutInfoArray' had no object in it.")
            
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
            
            return print("'exerciseArray' had no object in it.")
            
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
        
        remainingTransitionMinutes = minutes
        remainingTransitionSeconds = seconds
        
    }
    
    func saveRestTime(minutes: Int, seconds: Int) {
        
        let workoutInfo = getWorkoutInfo()
        
        workoutInfo.restMinutes = Int64(minutes)
        workoutInfo.restSeconds = Int64(seconds)
        
        saveData()
        
        setRestMinutes = minutes
        setRestSeconds = seconds
        
        remainingRestMinutes = minutes
        remainingRestSeconds = seconds
        
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
    
    func saveTestingExercise(named: String, minutes: Int, seconds: Int) {
        
        let test = Exercise(context: context)
        
        test.name = named
        test.intervalMinutes = Int64(minutes)
        test.intervalSeconds = Int64(seconds)
        
        saveData()
        
    }
    
    func makeSureInitialExerciseObjectIsCreated() {
        
        if self.exerciseArray.count == 0 {
            
//            saveNewExercise(named: "Exercise")
            
            saveTestingExercise(named: "Exercise 1", minutes: 1, seconds: 12)
            saveTestingExercise(named: "Exercise 2", minutes: 2, seconds: 24)
            saveTestingExercise(named: "Exercise 3", minutes: 3, seconds: 36)
            
            loadExercises()
            
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
    
    func saveNewExercise(named: String, minutes: Int = 0, seconds: Int = 0) {
        
        let newExercise = Exercise(context: context)
        
        newExercise.intervalMinutes = Int64(minutes)
        newExercise.intervalSeconds = Int64(seconds)
        newExercise.name = named
        
        self.saveData()
        
    }
    
    func updateExercise(named: String, newName: String, newMinutes: Int, newSeconds: Int) {
        
        var updatingExercise: Exercise?
        
        for exercise in exerciseArray {
            
            if named == exercise.name {
                
                updatingExercise = exercise
                
            }
            
        }
        
        if let updatingExercise = updatingExercise {
            
            updatingExercise.intervalMinutes = Int64(newMinutes)
            updatingExercise.intervalSeconds = Int64(newSeconds)
            updatingExercise.name = newName
            
        } else {
            
            print("Could not find exercise to update.")
            
        }
        
        self.saveData()
        
    }
    
    func deleteExercise(_ exercise: Exercise) {
        
        context.delete(exercise)
        
        saveData()
        
        loadExercises()
        
    }
    
    func deleteAllSavedWorkoutInfoObjects() {
        
        loadWorkoutData()
        
        for item in workoutInfoArray {
            
            context.delete(item)
            
        }
        
        saveData()
        
    }
    
    func setTotalAndRemainingStartingIntervalAmounts() {
        
        let firstExercise = exerciseArray[0]
        
        setTotalIntervalSeconds = (Int(firstExercise.intervalMinutes * 60)) + Int(firstExercise.intervalSeconds)
        
        remainingIntervalMinutes = Int(firstExercise.intervalMinutes)
        remainingIntervalSeconds = Int(firstExercise.intervalSeconds)
        
    }

    func setRemainingToSetAmounts() {
        
        setTotalAndRemainingStartingIntervalAmounts()
        
        remainingTransitionMinutes = setTransitionMinutes
        
        remainingTransitionSeconds = setTransitionSeconds
        
    }
    
    func setTotalSecondsForProgressForExercise(index: Int) -> Int {
        
        let exercise = exerciseArray[index]
        
        let seconds = (Int(exercise.intervalMinutes * 60)) + Int(exercise.intervalSeconds)
        
        return seconds
        
    }
    
    init() {
        
//        deleteAllSavedWorkoutInfoObjects()
        
        self.loadWorkoutData()
        self.loadExercises()

        self.makeSureInitialWorkoutInfoObjectIsCreated()
        self.makeSureInitialExerciseObjectIsCreated()

        let workoutInfo = getWorkoutInfo()

        self.setNumberOfSets = Int(workoutInfo.sets)
        
        self.setTransitionMinutes = Int(workoutInfo.transitionMinutes)
        self.setTransitionSeconds = Int(workoutInfo.transitionSeconds)
        
        self.setRestMinutes = Int(workoutInfo.restMinutes)
        self.setRestSeconds = Int(workoutInfo.restSeconds)
        
        let firstExercise = exerciseArray[0]
        
        self.setTotalIntervalSeconds = setTotalSecondsForProgressForExercise(index: 0)
        self.setTotalTransitionSeconds = (setTransitionMinutes * 60) + setTransitionSeconds
        self.setTotalRestSeconds = (setRestMinutes * 60) + setRestSeconds
        
        self.remainingIntervalMinutes = Int(firstExercise.intervalMinutes)
        self.remainingIntervalSeconds = Int(firstExercise.intervalSeconds)
        
        self.remainingTransitionMinutes = setTransitionMinutes
        self.remainingTransitionSeconds = setTransitionSeconds
        
        self.remainingRestMinutes = setRestMinutes
        self.remainingRestSeconds = setRestSeconds
        
        self.totalSecondsForProgress = setTotalSecondsForProgressForExercise(index: 0)
        
//        print("Workout class loaded: Exercise array contains \(exerciseArray.count) objects.")
        
    }
    
}










