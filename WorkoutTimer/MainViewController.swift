//
//  MainViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/23/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

// 1306 - Tock clicking sound (Keyboard click)
// 1072 - Kinda like a busy tone
// 1013 - Sounds kind of like a symbol or chime.
// 1057 - CURRENT COUNTDOWN: Sounds like a Dark-eyed Junco chirp.
// 1255 - CURRENT ENDING TRANSITION & REST: Double beep for starting.
// 1256 - CURRENT ENDING INTERVAL: Low to high quick beeps for starting.
// 1330 - CURRENT ENDING WORKOUT: Sherwood Forest



// ******
// *** TODO:
// ******



// SEE IF INTERVAL OR TRANSITION TIMER RESET THE REMAINING INTERVAL TIMES

// *** Continue organizing the timers and functionality of the timers.

// *** Make end of Interval Timer and Rep Popup match.

// *** Make end of Transition and Rest match.



// LONG: Change the timers to match the progress timer in .1 seconds.

// LONG: Make each label in the collection view be the main countdown.



// EXTRA LONG: Work on popup screen for dealing with the reps.

// EXTRA LONG: Work on popup screen for instructions.



import UIKit
import AVFoundation

class MainViewController: UIViewController {

    
    
    // ******
    // *** MARK: - Variables
    // ******
    
    
    
    let viewWidth = UIScreen.main.bounds.maxX
    
    let keywords = Keywords()
    let workout = Workout()
    let timerForWorkout = TimerForWorkout()
    
    var currentTimer = Workout.CurrentTimer.interval
    
    var mainTimer = Timer()
    var timerForInterval = Timer()
    var timerForTransition = Timer()
    var timerForProgress = Timer()
    var timerForTotalWorkout = Timer()
    
    var isTime = Bool()
    var isSets = Bool()
    var isTransition = Bool()
    var isExercise = Bool()
    var wasResetClicked = Bool()
    
    var timerIsStarted = false
    var beganWorkout = false
    var isCurrentlyDoingReps = false
    
    
    
    // ******
    // *** MARK: - IBOutlets
    // ******
    
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var workoutTimerView: UIView!
    @IBOutlet weak var totalTimeInWorkout: UILabel!
    @IBOutlet weak var totalTimeLeft: UILabel!
    
    @IBOutlet weak var setsView: UIView!
    @IBOutlet weak var setCollectionView: UICollectionView!
    
    @IBOutlet weak var timerProgress: UIProgressView!
    
    @IBOutlet weak var exerciseCollectionView: UICollectionView!
    @IBOutlet weak var exerciseCollectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var transitionView: UIView!
    @IBOutlet weak var transitionTitle: UILabel!
    @IBOutlet weak var transitionLabel: UILabel!
    
    @IBOutlet weak var restView: UIView!
    @IBOutlet weak var restTitle: UILabel!
    @IBOutlet weak var restLabel: UILabel!
    
    @IBOutlet weak var startStopButtonOutlet: UIButton!
    
    
    
    // ******
    // *** MARK: - IBActions
    // ******
    
    
    
    @IBAction func resetButton(_ sender: UIBarButtonItem) {
        
        wasResetClicked = true
        
        resetEverythingAlert(isTime: nil, isTransition: nil, isExercise: nil)
        
    }
    
    @IBAction func startStopButton(_ sender: UIButton) {
        
        if !timerIsStarted {
            
            timerIsStarted = true
            
            if !beganWorkout {
                
                beganWorkout = true
                
                if workout.exerciseArray[workout.currentExerciseIndex].reps == 0 {
                    
                    toggleTimers(runTimer: true)
                    
                } else {
                    
                    presentRepsAlert()
                    
                }
                
            } else {
                
                toggleTimers(runTimer: true)
            
            }
            
            toggleStartStopButton()
            
            toggleTimerViews()
            
            exerciseCollectionView.reloadData()
            
            setCollectionView.reloadData()
            
        } else {
            
            toggleTimers(runTimer: false)
            
            timerIsStarted = false
            
            toggleStartStopButton()
            
        }
        
    }
    
    
    
    // ******
    // *** MARK: - Segue
    // ******
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == keywords.mainToRoutinesSegue {
            
            let destinationVC = segue.destination as! RoutineViewController
            
            destinationVC.loadRoutineExercisesDelegate = self
            
            destinationVC.setSetsTransitionsAndRestDelegate = self
            
        } else if segue.identifier == keywords.mainToExerciseSegue {
            
            let destinationVC = segue.destination as! ExerciseViewController
            
            destinationVC.loadRoutineExercisesDelegate = self
            
        } else if segue.identifier == keywords.mainToSetsSegue {
            
            let destinationVC = segue.destination as! SetsTransitionAndRestViewController
            
            destinationVC.setSetsTransitionsAndRestDelegate = self
            
            destinationVC.isTime = isTime
            
            destinationVC.isTransition = isTransition
            
            if isTime {
                
                destinationVC.minutes = isTransition ? workout.setTransitionMinutes : workout.setRestMinutes
                
                destinationVC.seconds = isTransition ? workout.setTransitionSeconds : workout.setRestSeconds
                
            } else if !isTime {
                
                destinationVC.numberOfSets = workout.setNumberOfSets
                
            }
            
        }
        
    }
    
    
    
    // ******
    // *** MARK: - Loadables
    // ******
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionView.register(UINib(nibName: "SetsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "setCell")
        exerciseCollectionView.register(UINib(nibName: "ExerciseCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "exerciseCell")
        
        let routineTitleTapGesture = UITapGestureRecognizer(target: self, action: #selector(routineTitleTap))
        let setsTapGesture = UITapGestureRecognizer(target: self, action: #selector(setsTap))
        let exerciseTapGesture = UITapGestureRecognizer(target: self, action: #selector(exerciseTap))
        let workoutTimerTapGesture = UITapGestureRecognizer(target: self, action: #selector(workoutTimerTap))
        let transitionTapGesture = UITapGestureRecognizer(target: self, action: #selector(transitionTap))
        let restTapGesture = UITapGestureRecognizer(target: self, action: #selector(restTap))
        
        navBar.addGestureRecognizer(routineTitleTapGesture)
        workoutTimerView.addGestureRecognizer(workoutTimerTapGesture)
        setsView.addGestureRecognizer(setsTapGesture)
        exerciseCollectionView.addGestureRecognizer(exerciseTapGesture)
        transitionView.addGestureRecognizer(transitionTapGesture)
        restView.addGestureRecognizer(restTapGesture)
        
        updateTotalWorkoutTimeAndLabels()
        
        transitionLabel.text = workout.setLabelTextForTimer(forTimer: .transition, isRemaining: false)
        restLabel.text = workout.setLabelTextForTimer(forTimer: .rest, isRemaining: false)
        
        timerProgress.progress = 0.0
        
        toggleStartStopButton()
        toggleNavBarTitle()
        
    }

    
    
    // ******
    // *** MARK: - Timers
    // ******
    
    
    
    @objc func runTimer() {
        
        if currentTimer == .interval {

            intervalTimer()

        } else if currentTimer == .transition {

            transitionTimer()

        } else if currentTimer == .rest {

            restTimer()

        }
        
    }
    
    @objc func runWorkoutTimer() {
        
        workout.updateRemainingTimerMinutesAndSeconds(typeOfTimer: .workout)
        
        if workout.remainingWorkoutMinutes == 0  && workout.remainingWorkoutSeconds == 0 {
            
            // Reset amounts
            
            workout.remainingWorkoutMinutes = workout.setWorkoutMinutes
            
            workout.remainingWorkoutSeconds = workout.setWorkoutSeconds
            
        }
        
        totalTimeLeft.text = workout.setLabelTextForTimer(forTimer: .workout, isRemaining: true)
        
    }
    
    @objc func animateProgress() {
        
        let increment: Float = (1 / (Float(workout.totalSecondsForProgress) * 10))
        
        timerProgress.setProgress(timerProgress.progress + increment, animated: true)
        
    }
    
    func intervalTimer() {
        
        // The first time it is called, it resets the labels of the others.

        if Int(workout.exerciseArray[workout.currentExerciseIndex].intervalMinutes) == workout.remainingIntervalMinutes && Int(workout.exerciseArray[workout.currentExerciseIndex].intervalSeconds) == workout.remainingIntervalSeconds {

            workout.setRemainingToSetAmounts(forTimer: .transition)
            
            workout.setRemainingToSetAmounts(forTimer: .rest)
            
            transitionLabel.text = workout.setLabelTextForTimer(forTimer: .transition, isRemaining: false)
            
            restLabel.text = workout.setLabelTextForTimer(forTimer: .rest, isRemaining: false)
            
        }
        
        workout.updateRemainingTimerMinutesAndSeconds(typeOfTimer: .interval)
        
        // End of Exercise Interval
        
        if workout.remainingIntervalMinutes == 0 && workout.remainingIntervalSeconds == 0 && workout.exerciseArray[workout.currentExerciseIndex].reps == 0 {
            
            workout.currentExerciseIndex += 1
            
            timerProgress.progress = 0.0
            
            setCollectionView.reloadData()
            
            AudioServicesPlaySystemSound(1256)
            
            // More exercises.
            
            if workout.currentExerciseIndex < workout.exerciseArray.count {
                
//                if workout.setTotalTransitionSeconds > 0 {
//
//                    currentTimer = .transition
//
//                    toggleTimerViews()
//
//                    workout.totalSecondsForProgress = workout.setTotalTransitionSeconds
//
//                } else if workout.setTotalTransitionSeconds == 0 {
//
//                    workout.totalSecondsForProgress = workout.setTotalSecondsForProgressForExercise(index: workout.currentExerciseIndex)
//
//                }
                
                toggleGoToTransitionOrRest(goToTransition: true)
                
            // End of Set
                
            } else if workout.exerciseArray.count == workout.currentExerciseIndex {
                
                workout.currentSet += 1
                
                workout.currentExerciseIndex = 0
                
                // More sets
                
                if workout.currentSet <= workout.setNumberOfSets {
                    
//                    if workout.setTotalRestSeconds > 0 {
//
//                        currentTimer = .rest
//
//                        toggleTimerViews()
//
//                        workout.totalSecondsForProgress = workout.setTotalRestSeconds
//
//                    } else if workout.setTotalRestSeconds == 0 {
//
//                        workout.totalSecondsForProgress = workout.setTotalSecondsForProgressForExercise(index: workout.currentExerciseIndex)
//
//                    }
                    
                    toggleGoToTransitionOrRest(goToTransition: false)
                 
                // End of Workout
                    
                } else if workout.currentSet > workout.setNumberOfSets {
                    
                    toggleTimers(runTimer: false)
                    
                    workout.remainingWorkoutSeconds = 0
                    
                    totalTimeLeft.text = workout.setLabelTextForTimer(forTimer: .workout, isRemaining: true)
                    
                    finishedWorkoutAlert()
                    
                }
                
            }
            
        }
        
        exerciseCollectionView.reloadData()
        
        if currentTimer != .interval {
            
            workout.setRemainingToSetAmounts(forTimer: .interval, withIndex: workout.currentExerciseIndex)
            
        }
        
    }
    
    func transitionTimer() {
        
        if workout.setTransitionMinutes == workout.remainingTransitionMinutes && workout.setTransitionSeconds == workout.remainingTransitionSeconds {
            
            workout.setRemainingToSetAmounts(forTimer: .rest)
            
            restLabel.text = workout.setLabelTextForTimer(forTimer: .rest, isRemaining: false)
        }
        
        workout.updateRemainingTimerMinutesAndSeconds(typeOfTimer: .transition)
        
        // End of Transition
        
        if workout.remainingTransitionMinutes == 0 && workout.remainingTransitionSeconds == 0 {
            
            endTransitionOrRest(withCurrentExercise: workout.currentExerciseIndex)
            
        }
        
        transitionLabel.text = workout.setLabelTextForTimer(forTimer: .transition, isRemaining: true)
        
        if currentTimer != .transition {
            
            workout.setRemainingToSetAmounts(forTimer: .transition)
            
        }
        
    }
    
    func restTimer() {
        
        if workout.setRestMinutes == workout.remainingRestMinutes && workout.setRestSeconds == workout.remainingRestSeconds {
            
            workout.setRemainingToSetAmounts(forTimer: .interval, withIndex: 0)
            
            workout.setRemainingToSetAmounts(forTimer: .transition)
            
            // ******
            // *** MARK: - UPDATE CELL HERE
            // ******
            
            // intervalLabel.text = workout.setLabelTextForTimer(forTimer: .interval, withIndex: 0, isRemaining: false)
            
            transitionLabel.text = workout.setLabelTextForTimer(forTimer: .transition, isRemaining: false)
            
        }
        
        workout.updateRemainingTimerMinutesAndSeconds(typeOfTimer: .rest)
        
        // End of rest
        
        if workout.remainingRestMinutes == 0 && workout.remainingRestSeconds == 0 {
            
            endTransitionOrRest(withCurrentExercise: 0)
            
        }
        
        restLabel.text = workout.setLabelTextForTimer(forTimer: .rest, isRemaining: true)
        
        if currentTimer != .rest {
            
            workout.setRemainingToSetAmounts(forTimer: .rest)
            
        }
        
    }
    
    
    
    // ******
    // *** MARK: - Functions - Present Reps Alert, Alert, Reset, Interval Label, and Toggle Button Colors
    // ******
    
    
    
    func endTransitionOrRest(withCurrentExercise index: Int) {
        
        currentTimer = .interval
        
        if workout.exerciseArray[workout.currentExerciseIndex].reps == 0 {
            
            workout.totalSecondsForProgress = workout.setTotalSecondsForProgressForExercise(index: index)
            
        } else {
            
            isCurrentlyDoingReps = true
            
            toggleTimers(runTimer: false)
            
            presentRepsAlert()
            
        }
        
        timerProgress.progress = 0.0
        
        exerciseCollectionView.reloadData()
        
        toggleTimerViews()
        
        AudioServicesPlaySystemSound(1255)
        
    }
    
    func presentRepsAlert() {
        
        let alert = UIAlertController(title: "\(workout.exerciseArray[workout.currentExerciseIndex].name!)", message: "\(Int(workout.exerciseArray[workout.currentExerciseIndex].reps)) reps.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            
            self.workout.currentExerciseIndex += 1
            
            if self.workout.currentExerciseIndex < self.workout.exerciseArray.count {
                
                if self.workout.setTotalTransitionSeconds > 0 {
                    
                    self.currentTimer = .transition
                    
                    self.workout.totalSecondsForProgress = self.workout.setTotalTransitionSeconds
                    
                } else if self.workout.setTotalTransitionSeconds == 0 {
                    
                    self.workout.totalSecondsForProgress = self.workout.setTotalSecondsForProgressForExercise(index: self.workout.currentExerciseIndex)
                    
                }
                
                self.workout.setRemainingToSetAmounts(forTimer: .transition)
                
                self.transitionLabel.text = self.workout.setLabelTextForTimer(forTimer: .transition, isRemaining: true)
              
            } else if self.workout.exerciseArray.count == self.workout.currentExerciseIndex {
                
                self.workout.currentSet += 1
                
                self.workout.currentExerciseIndex = 0
                
                if self.workout.setTotalRestSeconds > 0 && self.workout.currentSet <= self.workout.setNumberOfSets {
                    
                    self.currentTimer = .rest
                    
                    self.toggleTimerViews()
                    
                    self.workout.totalSecondsForProgress = self.workout.setTotalRestSeconds
                    
                    self.workout.setRemainingToSetAmounts(forTimer: .rest)
                    
                    self.restLabel.text = self.workout.setLabelTextForTimer(forTimer: .rest, isRemaining: true)
                    
                } else if self.workout.setTotalRestSeconds == 0 && self.workout.currentSet <= self.workout.setNumberOfSets {
                    
                    self.workout.totalSecondsForProgress = self.workout.setTotalSecondsForProgressForExercise(index: self.workout.currentExerciseIndex)
                    
                    
                    
                    // End of Workout
                    
                } else if self.workout.currentSet > self.workout.setNumberOfSets {
                    
                    self.toggleTimers(runTimer: false)
                    
                    self.workout.remainingWorkoutSeconds = 0
                    
                    self.totalTimeLeft.text = self.workout.setLabelTextForTimer(forTimer: .workout, isRemaining: true)
                    
                    self.finishedWorkoutAlert()
                    
                }
                
                self.setCollectionView.reloadData()
                
            }
            
            if self.workout.currentSet <= self.workout.setNumberOfSets {
           
                self.workout.setRemainingToSetAmounts(forTimer: .interval, withIndex: self.workout.currentExerciseIndex)
                
                self.toggleTimers(runTimer: true)
                
                self.isCurrentlyDoingReps = false
                
                self.toggleTimerViews()
                
                self.exerciseCollectionView.reloadData()
                
                AudioServicesPlaySystemSound(1256)
                
            }
            
            if self.currentTimer != .interval {
                
                self.workout.setRemainingToSetAmounts(forTimer: .interval, withIndex: self.workout.currentExerciseIndex)
                
            }
            
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func finishedWorkoutAlert() {
        
        AudioServicesPlaySystemSound(1330)
        
        let alert = UIAlertController(title: "Finished!", message: "You did it!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "I feel great!", style: .default, handler: { (action) in
            
            self.timerIsStarted = false
            
            self.beganWorkout = false
            
            self.resetInfoToStartingSetAmounts()
            
            self.toggleTimerViews()
        
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func resetEverythingAlert(isTime: Bool?, isTransition: Bool?, isExercise: Bool?) {
        
        let alert = UIAlertController(title: "Reset?", message: "This will start the workout over.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { (action) in
            
            if self.beganWorkout {
                
                if let time = isTime, let transition = isTransition, let exercise = isExercise {
                    
                    self.setAndTimeTapSegue(isTime: time, isTransition: transition, isExercise: exercise)
                    
                } else {
                    
                    if !self.wasResetClicked {
                        
                        self.performSegue(withIdentifier: self.keywords.mainToRoutinesSegue, sender: self)
                        
                    }
                    
                }
                
            }
            
            self.timerIsStarted = false
            
            self.beganWorkout = false
            
            self.toggleTimers(runTimer: false)
            
            self.resetInfoToStartingSetAmounts()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func resetInfoToStartingSetAmounts() {
        
        workout.currentSet = 1
        
        workout.currentExerciseIndex = 0
        
        currentTimer = .interval
        
        setCollectionView.reloadData()
        
        exerciseCollectionView.reloadData()
        
        timerProgress.progress = 0.0
        
        workout.setRemainingToSetAmounts(forTimer: .interval, withIndex: 0)
        
        transitionLabel.text = workout.setLabelTextForTimer(forTimer: .transition, isRemaining: false)
        
        restLabel.text = workout.setLabelTextForTimer(forTimer: .rest, isRemaining: false)
        
        updateTotalWorkoutTimeAndLabels()
        
        toggleTimerViews()
        
        toggleStartStopButton()
        
    }
    
    func setAndTimeTapSegue(isTime: Bool, isTransition: Bool, isExercise: Bool) {
        
        self.isTime = isTime
        self.isTransition = isTransition
        self.isExercise = isExercise
        
        if isExercise {
            
            performSegue(withIdentifier: keywords.mainToExerciseSegue, sender: self)
            
        } else {
            
            performSegue(withIdentifier: keywords.mainToSetsSegue, sender: self)
            
        }
        
    }
    
    func toggleNavBarTitle() {
        
        navBar.topItem?.title = workout.lastUsedRoutine
        
    }
    
    func toggleStartStopButton() {
        
        if timerIsStarted {
    
            startStopButtonOutlet.setTitle("Stop", for: .normal)
            startStopButtonOutlet.layer.backgroundColor = keywords.stopColor.cgColor
            
        } else {
            
            startStopButtonOutlet.setTitle("Start", for: .normal)
            startStopButtonOutlet.layer.backgroundColor = keywords.startColor.cgColor
            
        }
        
    }
    
    func toggleTimerViews() {
        
        if timerIsStarted {
            
            if currentTimer == .transition {
                
                transitionTitle.isEnabled = true
                transitionLabel.isEnabled = true
                
                restTitle.isEnabled = false
                restLabel.isEnabled = false
                
            } else if currentTimer == .rest {
                
                transitionTitle.isEnabled = false
                transitionLabel.isEnabled = false
                
                restTitle.isEnabled = true
                restLabel.isEnabled = true
                
            } else {
                
                transitionTitle.isEnabled = false
                transitionLabel.isEnabled = false
                
                restTitle.isEnabled = false
                restLabel.isEnabled = false
                
            }
            
        } else {
            
            transitionTitle.isEnabled = true
            transitionLabel.isEnabled = true
            
            restTitle.isEnabled = true
            restLabel.isEnabled = true
            
        }
        
    }
    
    func toggleTimers(runTimer: Bool) {
        
        if runTimer {
            
            mainTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.runTimer), userInfo: nil, repeats: true)
            
            timerForProgress = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.animateProgress), userInfo: nil, repeats: true)
            
            timerForTotalWorkout = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.runWorkoutTimer), userInfo: nil, repeats: true)
            
        } else {
            
            mainTimer.invalidate()
            
            timerForProgress.invalidate()
            
            timerForTotalWorkout.invalidate()
            
        }
        
    }
    
    func toggleGoToTransitionOrRest(goToTransition: Bool) {
        
        if goToTransition {
            
            if workout.setTotalTransitionSeconds > 0 {
                
                currentTimer = .transition
                
                workout.totalSecondsForProgress = workout.setTotalTransitionSeconds
                
            } else {
                
                workout.totalSecondsForProgress = workout.setTotalSecondsForProgressForExercise(index: workout.currentExerciseIndex)
                
            }
            
        } else {
            
            if workout.setTotalRestSeconds > 0 {
                
                currentTimer = .rest
                
                workout.totalSecondsForProgress = workout.setTotalRestSeconds
                
            } else {
                
                workout.totalSecondsForProgress = workout.setTotalSecondsForProgressForExercise(index: workout.currentExerciseIndex)
                
            }
            
        }
        
        toggleTimerViews()
        
    }
    
    func updateTotalWorkoutTimeAndLabels() {
        
        workout.setTotalWorkoutSeconds()
        
        workout.setMinutesAndSecondsFromTotalWorkoutSeconds()
        
        totalTimeInWorkout.text = workout.setLabelTextForTimer(forTimer: .workout, isRemaining: false)
        
        totalTimeLeft.text = workout.setLabelTextForTimer(forTimer: .workout, isRemaining: true)
        
    }
 
    
    
    // ******
    // *** MARK: - Tap Functions
    // ******
    
    
    
    @objc func routineTitleTap() {
        
        if !timerIsStarted {
            
            if beganWorkout {
                
                resetEverythingAlert(isTime: nil, isTransition: nil, isExercise: nil)
                
            } else {
                
                performSegue(withIdentifier: keywords.mainToRoutinesSegue, sender: self)
                
            }
            
        }
        
    }
    
    

    @objc func setsTap() {
        
        if !timerIsStarted {
            
            if beganWorkout {
                
                resetEverythingAlert(isTime: false, isTransition: false, isExercise: false)
                
            } else {
                
                setAndTimeTapSegue(isTime: false, isTransition: false, isExercise: false)
                
            }
           
        }
        
    }
    
    @objc func exerciseTap() {
        
        if !timerIsStarted {
            
            if beganWorkout {
                
                resetEverythingAlert(isTime: false, isTransition: false, isExercise: true)
                
            } else {
                
                setAndTimeTapSegue(isTime: false, isTransition: false, isExercise: true)
                
            }
            
        }
        
    }
    
    @objc func workoutTimerTap() {

        if !timerIsStarted {
            
            if beganWorkout {
                
                resetEverythingAlert(isTime: false, isTransition: false, isExercise: true)
                
            } else {
                
                setAndTimeTapSegue(isTime: false, isTransition: false, isExercise: true)
                
            }
            
        }
        
    }

    @objc func transitionTap() {
        
        if !timerIsStarted {
            
            if beganWorkout {
                
                resetEverythingAlert(isTime: true, isTransition: true, isExercise: false)
                
            } else {
                
                setAndTimeTapSegue(isTime: true, isTransition: true, isExercise: false)
                
            }
            
        }
        
    }
    
    @objc func restTap() {
        
        if !timerIsStarted {
            
            if beganWorkout {
                
                resetEverythingAlert(isTime: true, isTransition: false, isExercise: false)
                
            } else {
                
                setAndTimeTapSegue(isTime: true, isTransition: false, isExercise: false)
                
            }
            
        }
        
    }

}



// ***********************************************************************************

// ******
// *** MARK: - Delegates
// ******

extension MainViewController: SetSetsTransitionsAndRestDelegate, LoadRoutineExercisesDelegate {
    
    func setSets(numberOfSets: Int) {
        
        workout.saveSets(routine: workout.lastUsedRoutine, sets: numberOfSets)
        
        timerProgress.progress = 0.0
        
        setCollectionView.reloadData()
        
        updateTotalWorkoutTimeAndLabels()
        
    }
    
    func setTransition(minutes: Int, seconds: Int) {
        
        workout.saveTransitionTime(routine: workout.lastUsedRoutine, minutes: minutes, seconds: seconds)
        
        transitionLabel.text = workout.setLabelTextForTimer(forTimer: .transition, isRemaining: false)
        
        updateTotalWorkoutTimeAndLabels()
        
    }
    
    func setRest(minutes: Int, seconds: Int) {
        
        workout.saveRestTime(routine: workout.lastUsedRoutine, minutes: minutes, seconds: seconds)
        
        restLabel.text = workout.setLabelTextForTimer(forTimer: .rest, isRemaining: false)
        
        updateTotalWorkoutTimeAndLabels()
        
    }
    
    func reloadExercisesPerRoutine() {
        
        workout.loadLastUsedRoutine()
        
        workout.loadExercisesPerRoutine(routine: workout.lastUsedRoutine)
        
        exerciseCollectionView.reloadData()
        
        updateTotalWorkoutTimeAndLabels()
        
        toggleNavBarTitle()
        
        workout.setRemainingToSetAmounts(forTimer: .interval, withIndex: 0)
        
        workout.totalSecondsForProgress = workout.setTotalSecondsForProgressForExercise(index: 0)
        
    }

}



// ***********************************************************************************

// ******
// *** MARK: - Collection View
// ******

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.setCollectionView {
            
            return workout.setNumberOfSets
            
        } else {
            
            return workout.exerciseArray.count
            
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        // Sets Collection
        
        if collectionView == self.setCollectionView {
            
            let cell = setCollectionView.dequeueReusableCell(withReuseIdentifier: "setCell", for: indexPath) as! SetsCollectionViewCell
            
            cell.setNumberLabel.text = "\(indexPath.row + 1)"
            
            if beganWorkout {
                
                if workout.currentSet == (indexPath.row + 1) {
                    
                    cell.backgroundColor = UIColor.clear
                    cell.setNumberLabel.isEnabled = true
                    cell.setNumberLabel.textColor = UIColor.white
                    
                
                } else if workout.currentSet > (indexPath.row + 1) {
                    
                    cell.backgroundColor = UIColor.white
                    cell.setNumberLabel.isEnabled = true
                    cell.setNumberLabel.textColor = keywords.darkBluishColor
                    
                } else {
                    
                    cell.backgroundColor = UIColor.clear
                    cell.setNumberLabel.isEnabled = false
                    cell.setNumberLabel.textColor = UIColor.white
                    
                }
                
            } else {
                
                cell.backgroundColor = UIColor.clear
                cell.setNumberLabel.isEnabled = true
                cell.setNumberLabel.textColor = UIColor.white
                
            }
            
            return cell
            
            
            
        // Exercise Collection
            
        } else {
            
            let cell = exerciseCollectionView.dequeueReusableCell(withReuseIdentifier: "exerciseCell", for: indexPath) as! ExerciseCollectionViewCell
            
            let currentExercise = workout.exerciseArray[indexPath.row]
            
            cell.exerciseNameLabel.text = "\(currentExercise.name!)"
            
            if currentExercise.reps == 0 {

                // This one resets the starting times.
                cell.exerciseTimeLabel.text = workout.setLabelTextForTimer(forTimer: .interval, withIndex: indexPath.row, isRemaining: false)
                
                if timerIsStarted && workout.currentExerciseIndex == indexPath.row {
                    
                    cell.exerciseTimeLabel.text = workout.setLabelTextForTimer(forTimer: .interval, isRemaining: true)
                    
                }

            } else {

                cell.exerciseTimeLabel.text = "\(Int(currentExercise.reps)) reps"

            }
            
            if beganWorkout {
                
                if workout.currentExerciseIndex == indexPath.row {
                    
                    cell.backgroundColor = UIColor.clear
                    cell.exerciseNameLabel.textColor = UIColor.white
                    cell.exerciseTimeLabel.textColor = UIColor.white
                    
                    cell.exerciseNameLabel.isEnabled = true
                    cell.exerciseTimeLabel.isEnabled = true
                   
                } else if workout.currentExerciseIndex > indexPath.row {
                    
                    cell.backgroundColor = UIColor.white
                    cell.exerciseNameLabel.textColor = keywords.darkBluishColor
                    cell.exerciseTimeLabel.textColor = keywords.darkBluishColor
                    
                    cell.exerciseNameLabel.isEnabled = true
                    cell.exerciseTimeLabel.isEnabled = true
                    
                } else {
                    
                    cell.backgroundColor = UIColor.clear
                    cell.exerciseNameLabel.textColor = UIColor.white
                    cell.exerciseTimeLabel.textColor = UIColor.white
                    
                    cell.exerciseNameLabel.isEnabled = false
                    cell.exerciseTimeLabel.isEnabled = false
                    
                }
                
            } else {
                
                cell.backgroundColor = UIColor.clear
                cell.exerciseNameLabel.textColor = UIColor.white
                cell.exerciseTimeLabel.textColor = UIColor.white
                
                cell.exerciseNameLabel.isEnabled = true
                cell.exerciseTimeLabel.isEnabled = true
                
            }
            
            
            
            // Size of font
            
            if workout.exerciseArray.count < 6 {
                
                cell.exerciseNameLabel.font = cell.exerciseNameLabel.font.withSize(21)
                cell.exerciseTimeLabel.font = cell.exerciseTimeLabel.font.withSize(21)
                
            } else {
                
                cell.exerciseNameLabel.font = cell.exerciseNameLabel.font.withSize(18)
                cell.exerciseTimeLabel.font = cell.exerciseTimeLabel.font.withSize(18)
                
            }
            
            return cell
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Sets Collection
        
        if collectionView == self.setCollectionView {
            
            let width = viewWidth / CGFloat(workout.setNumberOfSets)
            
            return CGSize(width: width, height: 36)
            
        // Exercise Collection
        } else {
            
            var width = CGFloat()
            
            var height = CGFloat()
            
            let exerciseCount = workout.exerciseArray.count
            
            if exerciseCount <= 6 {
                
                width = viewWidth / CGFloat(1)
                
                if exerciseCount <= 3 {
                    
                    height = 60
                    
                } else if exerciseCount == 4 {
                    
                    height = 48
                    
                } else {
                    
                    height = 42
                  
                }
                
                exerciseCollectionViewHeight.constant = CGFloat(exerciseCount) * height
                
            } else {
                
                width = viewWidth / CGFloat(2)
                
                if exerciseCount == 7 || exerciseCount == 8 {
                    
                    height = 48
                    
                    exerciseCollectionViewHeight.constant = 4 * height
                    
                } else if exerciseCount == 9 || exerciseCount == 10 {
                    
                    height = 36
                    
                    exerciseCollectionViewHeight.constant = 5 * height
                    
                } else {
                    
                    height = 36
                    
                    exerciseCollectionViewHeight.constant = 6 * height
                    
                }
                
            }
            
            collectionView.reloadData()
            
            return CGSize(width: width, height: height)
            
        }

    }
    
}









