//
//  WorkoutModel.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/23/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import CoreData

class Workout {
    
    enum CurrentTimer {
        
        case interval
        case transition
        case rest
        case workout
        
    }
    
    
    
    // ******
    // *** MARK: - Properties
    // ******
    
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var workoutInfoArray = [WorkoutInfo]()
    var exerciseArray = [Exercise]()
    var routineArray = [String]()
    
    let keywords = Keywords()
    let timerForWorkout = TimerForWorkout()
    
    var currentSet = 1
    var currentExerciseIndex = 0
    
    var setNumberOfSets: Int = 0
    
    var setTransitionMinutes: Int = 0
    var setTransitionSeconds: Double = 0
    
    var setRestMinutes: Int = 0
    var setRestSeconds: Double = 0
    
    var setWorkoutMinutes: Int = 0
    var setWorkoutSeconds: Double = 0
    
    var setTotalIntervalSeconds: Double = 0
    var setTotalTransitionSeconds: Double = 0
    var setTotalRestSeconds: Double = 0
    
    var remainingIntervalMinutes: Int = 0
    var remainingIntervalSeconds: Double = 0
    
    var remainingTransitionMinutes: Int = 0
    var remainingTransitionSeconds: Double = 0
    
    var remainingRestMinutes: Int = 0
    var remainingRestSeconds: Double = 0
    
    var remainingWorkoutMinutes: Int = 0
    var remainingWorkoutSeconds: Double = 0
    
    var totalSecondsForProgress: Double = 0
    var totalWorkoutSeconds: Double = 0
    var totalWorkoutTimeLeft: Double = 0
    
    var lastUsedRoutine = String()
    
    
    
    // ******
    // *** MARK: - Save
    // ******
    
    
    
    func saveData() {
        
        do {
            
            try context.save()
            
        } catch {
            
            print("Error saving data: \(error)")
            
        }
        
    }
    
    func saveNewWorkoutInfo(routine: String) {
        
        let newWorkout = WorkoutInfo(context: context)
        
        newWorkout.restMinutes = 0
        newWorkout.restSeconds = 0
        newWorkout.sets = 3
        newWorkout.transitionMinutes = 0
        newWorkout.transitionSeconds = 0
        newWorkout.routine = routine
        
        self.saveData()
        
    }
    
    func saveNewRoutine(routine: String) {
        
        saveNewExercise(named: "Exercise 1", minutes: 0, seconds: 30, routine: routine, reps: 0)
        
        saveNewWorkoutInfo(routine: routine)
        
        self.saveData()
        
    }
    
    func saveNewExercise(named: String, minutes: Int = 0, seconds: Int = 0, routine: String, reps: Int = 0) {
        
        let newExercise = Exercise(context: context)
        
        newExercise.intervalMinutes = Int64(minutes)
        newExercise.intervalSeconds = Int64(seconds)
        newExercise.name = named
        newExercise.orderNumber = Int64(exerciseArray.count)
        newExercise.routine = routine
        newExercise.reps = Int64(reps)
        
        self.saveData()
        
    }
    
    func saveIntervalTime(exerciseName: String, minutes: Int, seconds: Int) {
        
        guard let exercise = getExercise(named: exerciseName) else { return }
        
        exercise.intervalMinutes = Int64(minutes)
        exercise.intervalSeconds = Int64(seconds)
        
        saveData()
        
    }
    
    func saveTransitionTime(routine: String, minutes: Int, seconds: Int) {
        
        let workoutInfo = getWorkoutInfo(routine: routine)
        
        workoutInfo.transitionMinutes = Int64(minutes)
        workoutInfo.transitionSeconds = Int64(seconds)
        
        saveData()
        
        setTransitionMinutes = minutes
        setTransitionSeconds = Double(seconds)
        
        remainingTransitionMinutes = minutes
        remainingTransitionSeconds = Double(seconds)
        
        setTotalTransitionSeconds = Double(setTransitionMinutes * 60) + setTransitionSeconds
        
    }
    
    func saveRestTime(routine: String, minutes: Int, seconds: Int) {
        
        let workoutInfo = getWorkoutInfo(routine: routine)
        
        workoutInfo.restMinutes = Int64(minutes)
        workoutInfo.restSeconds = Int64(seconds)
        
        saveData()
        
        setRestMinutes = minutes
        setRestSeconds = Double(seconds)
        
        remainingRestMinutes = minutes
        remainingRestSeconds = Double(seconds)
        
        setTotalRestSeconds = Double(setRestMinutes * 60) + setRestSeconds
        
    }
    
    func saveSets(routine: String, sets: Int) {
        
        let workoutInfo = getWorkoutInfo(routine: routine)
        
        workoutInfo.sets = Int64(sets)
        
        saveData()
        
        setNumberOfSets = sets
        
    }
    
    func saveReps(routine: String, exerciseRequested: String, reps: Int) {
        
        guard let exercise = loadSpecificExercise(routine: routine, specificExerciseRequested: exerciseRequested) else { return print("Could not save Reps because there was no exercise loaded from the 'loadSpecificExercise' function request.") }
        
        exercise.reps = Int64(reps)
        
        saveData()
        
    }
    
    func saveLastUsedRoutine(routine: String) {
        
        UserDefaults.standard.set(routine, forKey: keywords.routineKey)
        
        lastUsedRoutine = routine
        
    }
    
    
    
    // ******
    // *** MARK: - Load
    // ******
    
    
    
    func loadWorkoutDataPerRoutine(routine: String) {
        
        let request: NSFetchRequest<WorkoutInfo> = WorkoutInfo.fetchRequest()
        
        let workoutPredicate = NSPredicate(format: keywords.routineMatchesKey, routine)
        
        request.predicate = workoutPredicate
        
        do {
            
            workoutInfoArray = try context.fetch(request)
            
        } catch {
            
            print("Error loading Workout Info: \(error)")
            
        }
        
        if workoutInfoArray.isEmpty {
            
            return print("'workoutInfoArray' had no object in it.")
            
        } else if workoutInfoArray.count > 1 {
            for item in workoutInfoArray {
                print(item.routine!)
            }
            return print("Loaded per routine. 'workoutInfoArray' has \(workoutInfoArray.count)")
            
        }
        
    }
    
    func loadAllWorkoutData() {
        
        let request: NSFetchRequest<WorkoutInfo> = WorkoutInfo.fetchRequest()
        
        do {
            
            workoutInfoArray = try context.fetch(request)
            
        } catch {
            
            print("Error loading Workout Info: \(error)")
            
        }
        
        if workoutInfoArray.isEmpty {
            
            return print("'workoutInfoArray' had no object in it.")
            
        } else if workoutInfoArray.count > 1 {
            
            return print("Loaded all. 'workoutInfoArray' has \(workoutInfoArray.count)")
            
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
       
    }
    
    func loadSpecificExercise(routine: String, specificExerciseRequested: String) -> Exercise? {
        
        var currentExerciseArray = [Exercise]()
        
        var specificExercise: Exercise?
        
        let request: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        
        let routinePredicate = NSPredicate(format: keywords.routineMatchesKey, routine)
        
        request.predicate = routinePredicate
        
        request.sortDescriptors = [NSSortDescriptor(key: keywords.orderNumberKey, ascending: true)]
        
        do {
            
            currentExerciseArray = try context.fetch(request)
            
        } catch {
            
            print("Error loading Workout Info: \(error)")
            
        }
        
        if currentExerciseArray.isEmpty {
            
            print("'currentExerciseArray' had no object in it.")
            
        }
        
        for exercise in currentExerciseArray {
            
            if exercise.name == specificExerciseRequested {
                
                specificExercise = exercise
                
            }
            
        }
        
        return specificExercise
        
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
    // *** MARK: - Retrieve Basic Workout Info and Specific Exercises
    // ******
    
    
    
    func getWorkoutInfo(routine: String) -> WorkoutInfo {
        
        loadWorkoutDataPerRoutine(routine: routine)
        
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
    // *** MARK: - Update Exercise and Exercise Indices
    // ******
    
    
    
    func updateExercise(named: String, newName: String, newMinutes: Int, newSeconds: Int, newReps: Int) {
        
        var updatingExercise: Exercise?
        
        for exercise in exerciseArray {
            
            if named == exercise.name {
                
                updatingExercise = exercise
                
            }
            
        }
        
        if let updatingExercise = updatingExercise {
            
            updatingExercise.intervalMinutes = Int64(newMinutes)
            updatingExercise.intervalSeconds = Int64(newSeconds)
            updatingExercise.reps = Int64(newReps)
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
    // *** MARK: - Delete
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
        
        loadAllWorkoutData()
        
        for item in workoutInfoArray {
            
            context.delete(item)
            
        }
        
        saveData()
        
    }
    
    func deleteWorkoutInfo(routine: String) {
        
        loadAllWorkoutData()
        
        for workoutInfo in workoutInfoArray {
            
            if workoutInfo.routine == routine {
                
                context.delete(workoutInfo)
                
            }
            
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
        
        deleteWorkoutInfo(routine: routineToDelete)
        
        saveData()
        
        loadRoutines()
        
        if routineToDelete == lastUsedRoutine {
            
            saveLastUsedRoutine(routine: routineArray[0])
            
        }
        
    }
    
    
    
    // ******
    // *** MARK: - Checks for New and Updating Workout Info and Exercises, and for even seconds.
    // ******
    
    
    
    // Check if Exercise name already exists.
    
    func checkIfNameExists(isNew: Bool, oldExerciseName: String, newExerciseName: String) -> Bool {
        
        var isSame = false
        
        for exercise in exerciseArray {
            
            if isNew {
                
                if exercise.name!.lowercased() == newExerciseName.lowercased() {
                    
                    isSame = true
                    
                }
                
            } else {
                
                if exercise.name!.lowercased() == oldExerciseName.lowercased() {
                    
                    continue
                    
                } else if exercise.name!.lowercased() == newExerciseName.lowercased() {
                    
                    isSame = true
                    
                }
                
            }
            
        }
        
        return isSame
        
    }
    
    
    
    // Check if Routine name already exists.
    
    func checkIfNameExists(isNew: Bool, oldRoutineName: String, newRoutineName: String) -> Bool {
        
        var isSame = false
        
        for routine in routineArray {
            
            if !isNew && routine.lowercased() == oldRoutineName.lowercased() {
                
                continue
                
            } else {
                
                if routine.lowercased() == newRoutineName.lowercased() {
                    
                    isSame = true
                    
                }
                
            }
            
        }
        
        return isSame
        
    }
    
    // Check for if the remaining seconds is an even second.
    
    func checkIfSecondsAreEven(seconds: Double) -> Bool {
        
        return Int((seconds * 10).truncatingRemainder(dividingBy: 10).rounded()) % 10 == 0
        
    }
    
    
    
    // ******
    // *** MARK: - Set Amounts to Remaining or Total Amounts or Zero Time, and Convert Seconds
    // ******
    

    
    func convertSecondsToUsableDouble(seconds: Double) -> Double {
        
        return (seconds * 10).rounded() / 10
        
    }
    
    func convertWorkoutSecondsUpWhenTimersPaused() {
        
        remainingWorkoutSeconds = remainingWorkoutSeconds.rounded(.down)
        
    }
    
    func setRemainingToSetAmounts(forTimer: CurrentTimer, withIndex: Int = 0) {
        
        switch forTimer {
            
        case .interval :
            
            remainingIntervalMinutes = Int(exerciseArray[withIndex].intervalMinutes)

            remainingIntervalSeconds = Double(exerciseArray[withIndex].intervalSeconds)
           
        case .transition :
            
            remainingTransitionMinutes = setTransitionMinutes
            
            remainingTransitionSeconds = setTransitionSeconds
            
        case .rest :
            
            remainingRestMinutes = setRestMinutes
            
            remainingRestSeconds = setRestSeconds
            
        case .workout :
            
            remainingWorkoutMinutes = setWorkoutMinutes
            
            remainingWorkoutSeconds = setWorkoutSeconds
            
        }
        
    }
    
    func updateRemainingTimerMinutesAndSeconds(typeOfTimer: CurrentTimer) {
        
        var remainingMinutes = Int()
        var remainingSeconds = Double()
        
        switch typeOfTimer {
            
        case .interval :
            remainingMinutes = remainingIntervalMinutes
            remainingSeconds = remainingIntervalSeconds
            
        case .rest :
            remainingMinutes = remainingRestMinutes
            remainingSeconds = remainingRestSeconds
            
        case .transition :
            remainingMinutes = remainingTransitionMinutes
            remainingSeconds = remainingTransitionSeconds
            
        case .workout :
            remainingMinutes = remainingWorkoutMinutes
            remainingSeconds = remainingWorkoutSeconds
            
        }
        
        if remainingMinutes > 0 {
            
            if remainingSeconds > 0 {
                
                remainingSeconds = ((remainingSeconds * 10).rounded() / 10) - 0.1
                
            } else {
                
                remainingMinutes -= 1
                
                remainingSeconds = 59.9
            }
        } else {
            
            remainingSeconds = ((remainingSeconds * 10).rounded() / 10) - 0.1
            
            if remainingSeconds <= 5 && (checkIfSecondsAreEven(seconds: remainingSeconds)) && remainingSeconds > 0 && typeOfTimer != .workout {
                
                AudioServicesPlaySystemSound(1057)
                
            }
        }
        
        switch typeOfTimer {
            
        case .interval :
            remainingIntervalMinutes = remainingMinutes
            remainingIntervalSeconds = remainingSeconds
            
        case .rest :
            remainingRestMinutes = remainingMinutes
            remainingRestSeconds = remainingSeconds
            
        case .transition :
            remainingTransitionMinutes = remainingMinutes
            remainingTransitionSeconds = remainingSeconds
            
        case .workout :
            remainingWorkoutMinutes = remainingMinutes
            remainingWorkoutSeconds = remainingSeconds
            
        }
        
    }
    
    func setLabelTextForTimer(forTimer: CurrentTimer, withIndex: Int = 0, isRemaining: Bool) -> String {
        
        var labelText = ""
        
        switch forTimer {
            
        case .interval :
            
            if isRemaining {
                
                let seconds = convertSecondsToUsableDouble(seconds: remainingIntervalSeconds)
                
                labelText = "\(timerForWorkout.zero(unit: remainingIntervalMinutes)):\(timerForWorkout.zero(unit: Int(seconds)))"
                
            } else {
                
                labelText = "\(timerForWorkout.zero(unit: Int(exerciseArray[withIndex].intervalMinutes))):\(timerForWorkout.zero(unit: Int(exerciseArray[withIndex].intervalSeconds)))"
                
            }
            
        case .transition :
            
            if isRemaining {
                
                let seconds = convertSecondsToUsableDouble(seconds: remainingTransitionSeconds)
                
                labelText = "\(timerForWorkout.zero(unit: remainingTransitionMinutes)):\(timerForWorkout.zero(unit: Int(seconds)))"
                
            } else {
                
                labelText = "\(timerForWorkout.zero(unit: setTransitionMinutes)):\(timerForWorkout.zero(unit: Int(setTransitionSeconds)))"
                
            }
            
        case .rest :
            
            if isRemaining {
                
                let seconds = convertSecondsToUsableDouble(seconds: remainingRestSeconds)
                
                labelText = "\(timerForWorkout.zero(unit: remainingRestMinutes)):\(timerForWorkout.zero(unit: Int(seconds)))"
                
            } else {
                
                labelText = "\(timerForWorkout.zero(unit: setRestMinutes)):\(timerForWorkout.zero(unit: Int(setRestSeconds)))"
                
            }
            
        case .workout :
            
            if isRemaining {
                
                let seconds = convertSecondsToUsableDouble(seconds: remainingWorkoutSeconds)
                
                labelText = "\(timerForWorkout.zero(unit: remainingWorkoutMinutes)):\(timerForWorkout.zero(unit: Int(seconds)))"
                
            } else {
                
                labelText = "\(timerForWorkout.zero(unit: setWorkoutMinutes)):\(timerForWorkout.zero(unit: Int(setWorkoutSeconds)))"
                
            }
            
        }
        
        return labelText
        
    }
    
    func setRemainingToSetAmounts() {
        
        setTotalIntervalSeconds = Double(exerciseArray[0].intervalMinutes * 60) + Double(exerciseArray[0].intervalSeconds)
        
        remainingIntervalMinutes = Int(exerciseArray[0].intervalMinutes)
        remainingIntervalSeconds = Double(exerciseArray[0].intervalSeconds)
        
        remainingTransitionMinutes = setTransitionMinutes
        remainingTransitionSeconds = setTransitionSeconds
        
        remainingRestMinutes = setRestMinutes
        remainingRestSeconds = setRestSeconds
        
    }
    
    func setTotalSecondsForProgressForExercise(index: Int) -> Double {
        
        let exercise = exerciseArray[index]
        
        let seconds = Double(exercise.intervalMinutes * 60) + Double(exercise.intervalSeconds)
        
        return seconds
        
    }
    
    func setTotalWorkoutSeconds() {
        
        var totalSeconds = Double()
        
        // Exercises
        
        for exercise in exerciseArray {
            
            for _ in 1...setNumberOfSets {
                
                totalSeconds += Double(exercise.intervalMinutes * 60)
                totalSeconds += Double(exercise.intervalSeconds)
                
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
        
        // Accounting for Reps as pauses.
        
        let exercisesWithReps = 0
        
//        for exercise in exerciseArray {
//
//            if exercise.reps != 0 {
//
//                exercisesWithReps += 1
//
//            }
//
//        }
//
//        exercisesWithReps = (exercisesWithReps * setNumberOfSets)
        
        totalWorkoutSeconds = totalSeconds - Double(exercisesWithReps)
        
    }
    
    func setMinutesAndSecondsFromTotalWorkoutSeconds() {
        
        var minutes = Int()
        var seconds = Double()
        
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
            
            seconds = totalWorkoutSeconds - Double(minutes * 60)

        }
        
        setWorkoutMinutes = minutes
//        setWorkoutSeconds = seconds
        setWorkoutSeconds = convertSecondsToUsableDouble(seconds: seconds)
        
        remainingWorkoutMinutes = minutes
//        remainingWorkoutSeconds = seconds
        remainingWorkoutSeconds = convertSecondsToUsableDouble(seconds: seconds)
        
    }
    
    
    
    // ******
    // *** MARK: - Initialization
    // ******
    
    
    
    func makeSureInitialInfoIsCreatedAfterLoading() {
        
        if self.workoutInfoArray.count == 0 {
            
            saveNewExercise(named: "Exercise 1", minutes: 0, seconds: 30, routine: keywords.defaultKey)
            
            saveNewWorkoutInfo(routine: keywords.defaultKey)
            
            loadWorkoutDataPerRoutine(routine: keywords.defaultKey)
            
            loadExercisesPerRoutine(routine: keywords.defaultKey)
            
        }
        
    }
    
    init() {
        
//        deleteAllSavedWorkoutInfoObjects()
        
        
        
        // Load saved amounts
        
        self.loadLastUsedRoutine()
        
        self.loadWorkoutDataPerRoutine(routine: lastUsedRoutine)
        
        self.loadExercisesPerRoutine(routine: lastUsedRoutine)
        

        
        // For First Time Users, make sure initial amounts are set.
        
        self.makeSureInitialInfoIsCreatedAfterLoading()
        
        
        
        // Set properties to their saved values.
        
        let workoutInfo = getWorkoutInfo(routine: lastUsedRoutine)
        
        self.setNumberOfSets = Int(workoutInfo.sets)
        
        self.setTransitionMinutes = Int(workoutInfo.transitionMinutes)
        self.setTransitionSeconds = Double(workoutInfo.transitionSeconds)
        
        self.setRestMinutes = Int(workoutInfo.restMinutes)
        self.setRestSeconds = Double(workoutInfo.restSeconds)
        
        self.setTotalIntervalSeconds = setTotalSecondsForProgressForExercise(index: 0)
        self.setTotalTransitionSeconds = Double(setTransitionMinutes * 60) + setTransitionSeconds
        self.setTotalRestSeconds = Double(setRestMinutes * 60) + setRestSeconds
        
        self.remainingIntervalMinutes = Int(exerciseArray[0].intervalMinutes)
        self.remainingIntervalSeconds = Double(exerciseArray[0].intervalSeconds)
        
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










