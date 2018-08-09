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
    
    
    
    // ******
    // *** Properties
    // ******
    
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var workoutInfoArray = [WorkoutInfo]()
    var exerciseArray = [Exercise]()
    var routineArray = [String]()
    
    let keywords = Keywords()
    
    var currentSet = 1
    var currentExerciseIndex = 0
    
    var setNumberOfSets: Int = 0
    
    var setTransitionMinutes: Int = 0
    var setTransitionSeconds: Int = 0
    
    var setRestMinutes: Int = 0
    var setRestSeconds: Int = 0
    
    var setWorkoutMinutes: Int = 0
    var setWorkoutSeconds: Int = 0
    
    var setTotalIntervalSeconds: Int = 0
    var setTotalTransitionSeconds: Int = 0
    var setTotalRestSeconds: Int = 0
    
    var remainingIntervalMinutes: Int = 0
    var remainingIntervalSeconds: Int = 0
    
    var remainingTransitionMinutes: Int = 0
    var remainingTransitionSeconds: Int = 0
    
    var remainingRestMinutes: Int = 0
    var remainingRestSeconds: Int = 0
    
    var remainingWorkoutMinutes: Int = 0
    var remainingWorkoutSeconds: Int = 0
    
    var totalSecondsForProgress = 0
    var totalWorkoutSeconds = 0
    var totalWorkoutTimeLeft = 0
    
    var lastUsedRoutine = String()
    
    
    
    // ******
    // *** Save
    // ******
    
    
    
    func saveData() {
        
        do {
            
            try context.save()
            
        } catch {
            
            print("Error saving data: \(error)")
            
        }
        
    }
    
    func saveNewWorkoutInfo() {
        
        let newWorkout = WorkoutInfo(context: context)
        
        newWorkout.restMinutes = 0
        newWorkout.restSeconds = 0
        newWorkout.sets = 3
        newWorkout.transitionMinutes = 0
        newWorkout.transitionSeconds = 0
        
        self.saveData()
        
    }
    
    func saveNewExercise(named: String, minutes: Int = 0, seconds: Int = 0, routine: String) {
        
        let newExercise = Exercise(context: context)
        
        newExercise.intervalMinutes = Int64(minutes)
        newExercise.intervalSeconds = Int64(seconds)
        newExercise.name = named
        newExercise.orderNumber = Int64(exerciseArray.count)
        newExercise.routine = routine
        
        self.saveData()
        
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
        
        setTotalTransitionSeconds = (setTransitionMinutes * 60) + setTransitionSeconds
        
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
        
        setTotalRestSeconds = (setRestMinutes * 60) + setRestSeconds
        
    }
    
    func saveSets(sets: Int) {
        
        let workoutInfo = getWorkoutInfo()
        
        workoutInfo.sets = Int64(sets)
        
        saveData()
        
        setNumberOfSets = sets
        
    }
    
    func saveLastUsedRoutine(routine: String) {
        
        UserDefaults.standard.set(routine, forKey: keywords.routineKey)
        
        lastUsedRoutine = routine
        
    }
    
    
    
    // ******
    // *** Load
    // ******
    
    
    
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
    
    func loadExercises() -> [Exercise] {
        
        var exercises = [Exercise]()
        
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        
        do {
            
            exercises = try context.fetch(request)
            
        } catch {
            
            print("Error loading Workout Info: \(error)")
            
        }
        
        if exercises.isEmpty {
            
            print("'exercises' Array has no object in it.")
            
        }
        
        return exercises
        
    }
    
    func loadExercisesPerRoutine(routine: String) {
        
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        
        let routinePredicate = NSPredicate(format: keywords.routineMatchesKey, routine)
        
        request.predicate = routinePredicate
        
        request.sortDescriptors = [NSSortDescriptor(key: keywords.orderNumberKey, ascending: true)]
        
        do {
            
            exerciseArray = try context.fetch(request)
            
        } catch {
            
            print("Error loading Workout Info: \(error)")
            
        }
        
        if exerciseArray.isEmpty {
            
            return print("'exerciseArray' had no object in it.")
            
        }
        
//        print(routineArray)
//        for exercise in exerciseArray {
//            
//            print("\(exercise.name!): \(exercise.routine!)")
//            
//        }
        

    }
    
    func loadRoutines() {
        
        let exercises = loadExercises()
        
        for exercise in exercises {
            
            if routineArray.count == 0 {
                
                routineArray.append(exercise.routine!)
                
            }
            
            var isAdded = false
            
            for routine in routineArray {
                
                if routine == exercise.routine {
                    
                    isAdded = true
                    
                }
                
            }
            
            if !isAdded {
                
                routineArray.append(exercise.routine!)
                
            }
            
        }
        
    }
    
    func loadLastUsedRoutine() {
        
        if UserDefaults.standard.object(forKey: keywords.routineKey) == nil {
            
            saveLastUsedRoutine(routine: keywords.defaultKey)
            
        } else {
            
            if let routine = UserDefaults.standard.object(forKey: keywords.routineKey) as? String {
                
                lastUsedRoutine = routine
                
            }
            
        }
        
    }
    
    
    
    // ******
    // *** Retrieve Basic Workout Info and Specific Exercises
    // ******
    
    
    
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

    
    
    // ******
    // *** Update Exercise and Exercise Indices
    // ******
    
    
    
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
    
    func updateOrderNumbers() {
        
        for i in exerciseArray.indices {
            
            exerciseArray[i].orderNumber = Int64(i)
            
        }
        
        saveData()
        
    }
    
    func updateRoutineName(oldName: String, newName: String) {
        
        loadExercisesPerRoutine(routine: oldName)
        
        for exercise in exerciseArray {
            
            exercise.routine = newName
            
        }
        
        loadRoutines()
        
        for i in routineArray.indices {
            
            if routineArray[i] == oldName {
                
                routineArray.remove(at: i)
                
                break
                
            }
            
        }
        
        loadRoutines()
        
        saveLastUsedRoutine(routine: newName)
        
        saveData()
        
    }
    
    
    
    // ******
    // *** Delete
    // ******
    
    
    
    func deleteExercise(_ exercise: Exercise) {
        
        context.delete(exercise)
        
        saveData()
        
        loadExercisesPerRoutine(routine: lastUsedRoutine)
        
        for i in exerciseArray.indices {
            
            exerciseArray[i].orderNumber = Int64(i)
            
        }
        
        saveData()
        
    }
    
    func deleteAllSavedWorkoutInfoObjects() {
        
        loadWorkoutData()
        
        for item in workoutInfoArray {
            
            context.delete(item)
            
        }
        
        saveData()
        
    }
    
    func deleteRoutine(routineToDelete: String) {
        
        let exercises = loadExercises()
        
        for exercise in exercises {
            
            if exercise.routine == routineToDelete {
                
                context.delete(exercise)
                
            }
            
        }
        
        for i in routineArray.indices {
            
            if routineToDelete == routineArray[i] {

                routineArray.remove(at: i)
                
                break

            }

        }
        
        saveData()
        
        loadRoutines()
        
        if routineToDelete == lastUsedRoutine {
            
            saveLastUsedRoutine(routine: routineArray[0])
            
        }
        
    }
    
    
    
    // ******
    // *** Set Amounts to Remaining or Total Amounts
    // ******
    
    
    
    func setTotalAndRemainingStartingIntervalAmounts() {
        
        setTotalIntervalSeconds = (Int(exerciseArray[0].intervalMinutes * 60)) + Int(exerciseArray[0].intervalSeconds)
        
        remainingIntervalMinutes = Int(exerciseArray[0].intervalMinutes)
        remainingIntervalSeconds = Int(exerciseArray[0].intervalSeconds)
        
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
    
    func setTotalWorkoutSeconds() {
        
        var totalSeconds = Int()
        
        // Exercises
        
        for exercise in exerciseArray {
            
            for _ in 1...setNumberOfSets {
                
                totalSeconds += Int(exercise.intervalMinutes * 60)
                totalSeconds += Int(exercise.intervalSeconds)
                
            }

        }

        // Transitions
        
        if exerciseArray.count > 1 {
            
            for _ in 1...setNumberOfSets {
                
                for _ in 2...exerciseArray.count {
                    
                    totalSeconds += setTotalTransitionSeconds
                    
                }
                
            }
            
        }

        // Rest
        
        if setNumberOfSets > 1 {
            
            for _ in 2...setNumberOfSets {
                
                totalSeconds += setTotalRestSeconds
                
            }
            
        }
        
        totalWorkoutSeconds = totalSeconds
        
    }
    
    func setMinutesAndSecondsFromTotalWorkoutSeconds() {
        
        var minutes = Int()
        var seconds = Int()
        
        if (totalWorkoutSeconds / 60) < 1 {
            
            minutes = 0
            seconds = totalWorkoutSeconds
            
        } else if totalWorkoutSeconds == 60 {
            
            minutes = 1
            seconds = 0
            
        } else {
            
            var minutesAsDecimal: Double = (Double(totalWorkoutSeconds) / 60)
            
            minutesAsDecimal.round(.towardZero)
            
            minutes = Int(minutesAsDecimal)
            
            seconds = totalWorkoutSeconds - (minutes * 60)

        }
        
        setWorkoutMinutes = minutes
        setWorkoutSeconds = seconds
        
        remainingWorkoutMinutes = minutes
        remainingWorkoutSeconds = seconds
        
    }
    
    
    
    // ******
    // *** Initialization
    // ******
    
    
    
    func makeSureInitialWorkoutInfoObjectIsCreated() {
        
        if self.workoutInfoArray.count == 0 {
            
            saveNewWorkoutInfo()
            
            loadWorkoutData()
            
        }
        
    }
    
    func makeSureInitialExerciseObjectIsCreated() {
        
        if self.exerciseArray.count == 0 {
            
            saveNewExercise(named: "Exercise 1", minutes: 0, seconds: 30, routine: keywords.defaultKey)
            
            loadExercisesPerRoutine(routine: keywords.defaultKey)
            
        }

    }
    
    init() {
        
//        deleteAllSavedWorkoutInfoObjects()
        
        
        
        // Load saved amounts
        
        self.loadLastUsedRoutine()
        
        self.loadWorkoutData()
//        print(lastUsedRoutine)
        self.loadExercisesPerRoutine(routine: lastUsedRoutine)
        

        
        
        // For First Time Users, make sure initial amounts are set.
        
        self.makeSureInitialWorkoutInfoObjectIsCreated()
        self.makeSureInitialExerciseObjectIsCreated()

        
        
        // Set properties to their saved values.
        
        let workoutInfo = getWorkoutInfo()

        self.setNumberOfSets = Int(workoutInfo.sets)
        
        self.setTransitionMinutes = Int(workoutInfo.transitionMinutes)
        self.setTransitionSeconds = Int(workoutInfo.transitionSeconds)
        
        self.setRestMinutes = Int(workoutInfo.restMinutes)
        self.setRestSeconds = Int(workoutInfo.restSeconds)
        
        self.setTotalIntervalSeconds = setTotalSecondsForProgressForExercise(index: 0)
        self.setTotalTransitionSeconds = (setTransitionMinutes * 60) + setTransitionSeconds
        self.setTotalRestSeconds = (setRestMinutes * 60) + setRestSeconds
        
        self.remainingIntervalMinutes = Int(exerciseArray[0].intervalMinutes)
        self.remainingIntervalSeconds = Int(exerciseArray[0].intervalSeconds)
        
        self.remainingTransitionMinutes = setTransitionMinutes
        self.remainingTransitionSeconds = setTransitionSeconds
        
        self.remainingRestMinutes = setRestMinutes
        self.remainingRestSeconds = setRestSeconds
        
        self.totalSecondsForProgress = setTotalSecondsForProgressForExercise(index: 0)
        
        self.setTotalWorkoutSeconds()
        
        self.setMinutesAndSecondsFromTotalWorkoutSeconds()
        
        self.loadRoutines()
        
    }
    
}










