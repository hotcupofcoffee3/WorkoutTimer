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

// Convert the checks into functions of their own, such as 'endRepInterval' & 'endTimeInterval' & 'endSet' to reuse code throughout.

// Blue background for the exercises.

// No outline for the exercises.

// Continue organizing the timers and functionality of the timers.

// Change the timers to match the progress timer in .1 seconds.

// Update the timer labels at the end of the next timers, as we tried it for a bit, but it's kind of nice to have it say 0 at the end.

// Toggle the buttons and make them actually work with enabling and disabling.

// Make only the Transition and Rest labels at bottom.

// Make each label in the collection view be the main countdown.



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
    
    @IBOutlet weak var totalTimeInWorkout: UILabel!
    
    @IBOutlet weak var totalTimeLeft: UILabel!
    
    @IBOutlet weak var setsView: UIView!
    
    @IBOutlet weak var setCollectionView: UICollectionView!
    
    @IBOutlet weak var exerciseCollectionView: UICollectionView!
    
    @IBOutlet weak var timerProgress: UIProgressView!
    
    @IBOutlet weak var intervalView: UIView!
    
    @IBOutlet weak var intervalTitle: UILabel!
    
    @IBOutlet weak var intervalLabel: UILabel!
    
    @IBOutlet weak var transitionView: UIView!
    
    @IBOutlet weak var transitionTitle: UILabel!
    
    @IBOutlet weak var transitionLabel: UILabel!
    
    @IBOutlet weak var restView: UIView!
    
    @IBOutlet weak var restTitle: UILabel!
    
    @IBOutlet weak var restLabel: UILabel!
    
    @IBOutlet weak var startButtonOutlet: UIButton!
    
    @IBOutlet weak var stopButtonOutlet: UIButton!
    
    
    
    // ******
    // *** MARK: - IBActions
    // ******
    
    
    
    @IBAction func resetButton(_ sender: UIBarButtonItem) {
        
        wasResetClicked = true
        
        resetEverythingAlert(isTime: nil, isTransition: nil, isExercise: nil)
        
    }
    
    @IBAction func startButton(_ sender: UIButton) {
        
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
            
            toggleButtonColors(reset: false)
            
            toggleTimerViews()
            
            exerciseCollectionView.reloadData()
            
            setCollectionView.reloadData()
            
        }
        
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        
        if timerIsStarted {
            
            toggleTimers(runTimer: false)
            
            timerIsStarted = false
            
            toggleButtonColors(reset: false)
            
        }
        
    }
    
    
    
    // ******
    // *** MARK: - Segue
    // ******
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == keywords.mainToRoutinesSegue {
            
            let destinationVC = segue.destination as! RoutineViewController
            
            destinationVC.updateFirstExerciseDelegate = self
            
            destinationVC.loadRoutineExercisesDelegate = self
            
            destinationVC.setSetsTransitionsAndRestDelegate = self
            
        } else if segue.identifier == keywords.mainToExerciseSegue {
            
            let destinationVC = segue.destination as! ExerciseViewController
            
            destinationVC.updateFirstExerciseDelegate = self
            
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
        let intervalTapGesture = UITapGestureRecognizer(target: self, action: #selector(intervalTap))
        let transitionTapGesture = UITapGestureRecognizer(target: self, action: #selector(transitionTap))
        let restTapGesture = UITapGestureRecognizer(target: self, action: #selector(restTap))
        
        navBar.addGestureRecognizer(routineTitleTapGesture)
        setsView.addGestureRecognizer(setsTapGesture)
        exerciseCollectionView.addGestureRecognizer(exerciseTapGesture)
        intervalView.addGestureRecognizer(intervalTapGesture)
        transitionView.addGestureRecognizer(transitionTapGesture)
        restView.addGestureRecognizer(restTapGesture)
        
        updateIntervalLabelToFirstExercise()
        
        updateTotalWorkoutTimeAndLabels()
        
        transitionLabel.text = "\(timerForWorkout.zero(unit: workout.setTransitionMinutes)):\(timerForWorkout.zero(unit: workout.setTransitionSeconds))"
        
        restLabel.text = "\(timerForWorkout.zero(unit: workout.setRestMinutes)):\(timerForWorkout.zero(unit: workout.setRestSeconds))"
        
        timerProgress.progress = 0.0
        
        startButtonOutlet.layer.borderColor = UIColor.white.cgColor
        startButtonOutlet.layer.borderWidth = 2
        startButtonOutlet.layer.cornerRadius = 45
        
        stopButtonOutlet.layer.borderColor = UIColor.white.cgColor
        stopButtonOutlet.layer.borderWidth = 2
        stopButtonOutlet.layer.cornerRadius = 45
        
        toggleButtonColors(reset: true)
        
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
        
        if workout.remainingWorkoutMinutes > 0 {
            
            if workout.remainingWorkoutSeconds > 0 {
                
                workout.remainingWorkoutSeconds -= 1
                
            } else {
                
                workout.remainingWorkoutMinutes -= 1
                
                workout.remainingWorkoutSeconds = 59
                
            }
            
        } else if workout.remainingWorkoutMinutes == 0 {
            
            if workout.remainingWorkoutSeconds > 0 {
                
                workout.remainingWorkoutSeconds -= 1
                
            }
            
            if workout.remainingWorkoutSeconds == 0 {
                
                // Reset amounts
                
                workout.remainingWorkoutMinutes = workout.setWorkoutMinutes
                
                workout.remainingWorkoutSeconds = workout.setWorkoutSeconds
                
            }
            
        }
        
        totalTimeLeft.text = "\(timerForWorkout.zero(unit: workout.remainingWorkoutMinutes)):\(timerForWorkout.zero(unit: workout.remainingWorkoutSeconds))"
        
    }
    
    @objc func animateProgress() {
        
        let increment: Float = (1 / (Float(workout.totalSecondsForProgress) * 10))
        
        timerProgress.setProgress(timerProgress.progress + increment, animated: true)
        
    }
    
    func intervalTimer() {
        
        // The first time it is called, it resets the labels of the others.
        
        if Int(workout.exerciseArray[workout.currentExerciseIndex].intervalMinutes) == workout.remainingIntervalMinutes && Int(workout.exerciseArray[workout.currentExerciseIndex].intervalSeconds) == workout.remainingIntervalSeconds {
            
            transitionLabel.text = "\(timerForWorkout.zero(unit: workout.remainingTransitionMinutes)):\(timerForWorkout.zero(unit: workout.remainingTransitionSeconds))"
            
            restLabel.text = "\(timerForWorkout.zero(unit: workout.remainingRestMinutes)):\(timerForWorkout.zero(unit: workout.remainingRestSeconds))"
            
        }
        
        if workout.remainingIntervalMinutes > 0 {
            
            if workout.remainingIntervalSeconds > 0 {
                
                workout.remainingIntervalSeconds -= 1
                
            } else {
                
                workout.remainingIntervalMinutes -= 1
                
                workout.remainingIntervalSeconds = 59
                
            }
            
        } else if workout.remainingIntervalMinutes == 0 {
            
            if workout.remainingIntervalSeconds > 0 {
                
                workout.remainingIntervalSeconds -= 1
                
                if workout.remainingIntervalSeconds <= 5 && workout.remainingIntervalSeconds > 0 {
                    
                    AudioServicesPlaySystemSound(1057)
                    
                }
                
            }
            
            
            
            // End of Exercise Interval
            
            if workout.remainingIntervalSeconds == 0 && workout.exerciseArray[workout.currentExerciseIndex].reps == 0 {
                
                workout.currentExerciseIndex += 1
                
                setCollectionView.reloadData()
                
                AudioServicesPlaySystemSound(1256)
                
                
                
                // If there are more exercises.
                
                if workout.exerciseArray.count > workout.currentExerciseIndex {
                    
                    if workout.setTotalTransitionSeconds > 0 {
                        
                        currentTimer = .transition
                        
                        toggleTimerViews()
                        
                        workout.totalSecondsForProgress = workout.setTotalTransitionSeconds
                        
                    } else if workout.setTotalTransitionSeconds == 0 {
                        
                        workout.totalSecondsForProgress = workout.setTotalSecondsForProgressForExercise(index: workout.currentExerciseIndex)
                        
                    }
                
                // End of Set
                    
                } else if workout.exerciseArray.count == workout.currentExerciseIndex {
                    
                    workout.currentSet += 1
                    
                    workout.currentExerciseIndex = 0
                    
                    
                    
                    // If there are more sets.
                    
                    if workout.currentSet <= workout.setNumberOfSets {
                        
                        if workout.setTotalRestSeconds > 0 {
                            
                            currentTimer = .rest
                            
                            toggleTimerViews()
                            
                            workout.totalSecondsForProgress = workout.setTotalRestSeconds
                            
                        } else if workout.setTotalRestSeconds == 0 {
                            
                            workout.totalSecondsForProgress = workout.setTotalSecondsForProgressForExercise(index: workout.currentExerciseIndex)
                            
                        }
                    
                    // End of Workout
                        
                    } else if workout.currentSet > workout.setNumberOfSets {
                        
                        toggleTimers(runTimer: false)
                        
                        workout.remainingWorkoutSeconds = 0
                        
                        totalTimeLeft.text = "\(timerForWorkout.zero(unit: workout.remainingWorkoutMinutes)):\(timerForWorkout.zero(unit: workout.remainingWorkoutSeconds))"
                        
                        finishedWorkoutAlert()
                        
                    }
                    
                }
                
                exerciseCollectionView.reloadData()
                
                workout.setRemainingToSetAmounts(forTimer: .interval, withIndex: workout.currentExerciseIndex)
                
                timerProgress.progress = 0.0
                
            }
            
        }
        
        intervalLabel.text = "\(timerForWorkout.zero(unit: workout.remainingIntervalMinutes)):\(timerForWorkout.zero(unit: workout.remainingIntervalSeconds))"
        
        if currentTimer == .transition || currentTimer == .rest {
            
            workout.setRemainingToSetAmounts(forTimer: .interval, withIndex: workout.currentExerciseIndex)
            
        }
        
    }
    
    func transitionTimer() {
        
        if workout.setTransitionMinutes == workout.remainingTransitionMinutes && workout.setTransitionSeconds == workout.remainingTransitionSeconds {
            
            intervalLabel.text = "\(timerForWorkout.zero(unit: Int(workout.exerciseArray[workout.currentExerciseIndex].intervalMinutes))):\(timerForWorkout.zero(unit: Int(workout.exerciseArray[workout.currentExerciseIndex].intervalSeconds)))"
            
        }
        
        if workout.remainingTransitionMinutes > 0 {
            
            if workout.remainingTransitionSeconds > 0 {
                
                workout.remainingTransitionSeconds -= 1
                
            } else {
                
                workout.remainingTransitionMinutes -= 1
                
                workout.remainingTransitionSeconds = 59
                
            }
            
        } else if workout.remainingTransitionMinutes == 0 {
            
            if workout.remainingTransitionSeconds > 0 {
                
                workout.remainingTransitionSeconds -= 1
                
                if workout.remainingTransitionSeconds <= 5 && workout.remainingTransitionSeconds > 0 {
                    
                    AudioServicesPlaySystemSound(1057)
                    
                }
                
            }
            
            
            
            // End of Transition
            
            if workout.remainingTransitionSeconds == 0 {

                exerciseCollectionView.reloadData()
                
                timerProgress.progress = 0.0
                
                if workout.exerciseArray[workout.currentExerciseIndex].reps == 0 {
                    
                    currentTimer = .interval
                    
                    workout.totalSecondsForProgress = workout.setTotalSecondsForProgressForExercise(index: workout.currentExerciseIndex)
                    
                } else {
                    
                    isCurrentlyDoingReps = true
                    
                    toggleTimers(runTimer: false)
                    
                    exerciseCollectionView.reloadData()
                    
                    presentRepsAlert()
                    
                }
                
                workout.setRemainingToSetAmounts(forTimer: .transition)

                toggleTimerViews()
                
                AudioServicesPlaySystemSound(1255)

            }
            
        }
        
        transitionLabel.text = "\(timerForWorkout.zero(unit: workout.remainingTransitionMinutes)):\(timerForWorkout.zero(unit: workout.remainingTransitionSeconds))"
        
        if currentTimer == .interval {
            
            workout.setRemainingToSetAmounts(forTimer: .transition)
            
        }
        
    }
    
    func restTimer() {
        
        if workout.setRestMinutes == workout.remainingRestMinutes && workout.setRestSeconds == workout.remainingRestSeconds {
            
            intervalLabel.text = "\(timerForWorkout.zero(unit: Int(workout.exerciseArray[workout.currentExerciseIndex].intervalMinutes))):\(timerForWorkout.zero(unit: Int(workout.exerciseArray[workout.currentExerciseIndex].intervalSeconds)))"
            
        }
        
        if workout.remainingRestMinutes > 0 {
            
            if workout.remainingRestSeconds > 0 {
                
                workout.remainingRestSeconds -= 1
                
            } else {
                
                workout.remainingRestMinutes -= 1
                
                workout.remainingRestSeconds = 59
                
            }
            
        } else if workout.remainingRestMinutes == 0 {
            
            if workout.remainingRestSeconds > 0 {
                
                workout.remainingRestSeconds -= 1
                
                if workout.remainingRestSeconds <= 5 && workout.remainingRestSeconds > 0 {
                    
                    AudioServicesPlaySystemSound(1057)
                    
                }
                
            }
            
            
            
            // End of rest
            
            if workout.remainingRestSeconds == 0 {
                
                exerciseCollectionView.reloadData()
                
                timerProgress.progress = 0.0
                
                if workout.exerciseArray[workout.currentExerciseIndex].reps == 0 {
                    
                    currentTimer = .interval
                    
                    workout.totalSecondsForProgress = workout.setTotalSecondsForProgressForExercise(index: 0)
                    
                } else {
                    
                    isCurrentlyDoingReps = true
                    
                    toggleTimers(runTimer: false)
                    
                    exerciseCollectionView.reloadData()
                    
                    presentRepsAlert()
                    
                }
                
                workout.setRemainingToSetAmounts(forTimer: .rest)
                
                toggleTimerViews()
                
                AudioServicesPlaySystemSound(1255)
                
            }
            
        }
        
        restLabel.text = "\(timerForWorkout.zero(unit: workout.remainingRestMinutes)):\(timerForWorkout.zero(unit: workout.remainingRestSeconds))"
        
        if currentTimer == .interval {
            
            workout.setRemainingToSetAmounts(forTimer: .rest)
            
        }
        
    }
    
    
    
    // ******
    // *** MARK: - Functions - Alert, Reset, Interval Label, and Toggle Button Colors
    // ******
    
    
    
    func presentRepsAlert() {
        
        let alert = UIAlertController(title: "\(workout.exerciseArray[workout.currentExerciseIndex].name!)", message: "\(Int(workout.exerciseArray[workout.currentExerciseIndex].reps))", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { (action) in
            
            self.workout.currentExerciseIndex += 1
            
            if self.workout.currentExerciseIndex < self.workout.exerciseArray.count {
                
                self.currentTimer = .transition
                
                self.workout.totalSecondsForProgress = self.workout.setTotalTransitionSeconds
                
                self.workout.setRemainingToSetAmounts(forTimer: .transition)
                
                self.transitionLabel.text = "\(self.timerForWorkout.zero(unit: self.workout.remainingTransitionMinutes)):\(self.timerForWorkout.zero(unit: self.workout.remainingTransitionSeconds))"
              
            } else if self.workout.exerciseArray.count == self.workout.currentExerciseIndex {
                
                self.workout.currentSet += 1
                
                self.workout.currentExerciseIndex = 0
                
                if self.workout.setTotalRestSeconds > 0 && self.workout.currentSet <= self.workout.setNumberOfSets {
                    
                    self.currentTimer = .rest
                    
                    self.toggleTimerViews()
                    
                    self.workout.totalSecondsForProgress = self.workout.setTotalRestSeconds
                    
                    self.workout.setRemainingToSetAmounts(forTimer: .rest)
                    
                    self.restLabel.text = "\(self.timerForWorkout.zero(unit: self.workout.remainingRestMinutes)):\(self.timerForWorkout.zero(unit: self.workout.remainingRestSeconds))"
                    
                } else if self.workout.setTotalRestSeconds == 0 && self.workout.currentSet <= self.workout.setNumberOfSets {
                    
                    self.workout.totalSecondsForProgress = self.workout.setTotalSecondsForProgressForExercise(index: self.workout.currentExerciseIndex)
                    
                    
                    
                    // End of Workout
                    
                } else if self.workout.currentSet > self.workout.setNumberOfSets {
                    
                    self.toggleTimers(runTimer: false)
                    
                    self.workout.remainingWorkoutSeconds = 0
                    
                    self.totalTimeLeft.text = "\(self.timerForWorkout.zero(unit: self.workout.remainingWorkoutMinutes)):\(self.timerForWorkout.zero(unit: self.workout.remainingWorkoutSeconds))"
                    
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
    
    func updateIntervalLabelToFirstExercise() {
        
        let firstExercise = workout.exerciseArray[0]
        
        intervalLabel.text = "\(timerForWorkout.zero(unit: Int(firstExercise.intervalMinutes))):\(timerForWorkout.zero(unit: Int(firstExercise.intervalSeconds)))"
        
    }
    
    func resetInfoToStartingSetAmounts() {
        
        workout.currentSet = 1
        
        workout.currentExerciseIndex = 0
        
        currentTimer = .interval
        
        setCollectionView.reloadData()
        
        exerciseCollectionView.reloadData()
        
        timerProgress.progress = 0.0
        
        updateIntervalLabelToFirstExercise()
        
        workout.setRemainingToSetAmounts(forTimer: .interval, withIndex: 0)
        
        transitionLabel.text = "\(timerForWorkout.zero(unit: workout.setTransitionMinutes)):\(timerForWorkout.zero(unit: workout.setTransitionSeconds))"
        
        restLabel.text = "\(timerForWorkout.zero(unit: workout.setRestMinutes)):\(timerForWorkout.zero(unit: workout.setRestSeconds))"
        
        updateTotalWorkoutTimeAndLabels()
        
        toggleTimerViews()
        
        toggleButtonColors(reset: true)
        
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
    
    func toggleButtonColors(reset: Bool) {
        
        if reset {
            
            startButtonOutlet.isEnabled = true

            stopButtonOutlet.isEnabled = false
            
        } else {
            
            if beganWorkout && timerIsStarted {
                
                startButtonOutlet.isEnabled = false
                
                stopButtonOutlet.isEnabled = true
                
            } else if beganWorkout && !timerIsStarted {
                
                startButtonOutlet.isEnabled = true
                
                stopButtonOutlet.isEnabled = false
                
            }
            
        }
        
    }
    
    func toggleTimerViews() {
        
        if timerIsStarted {
            
            if currentTimer == .interval {
                
                intervalTitle.isEnabled = true
                intervalLabel.isEnabled = true
                
                transitionTitle.isEnabled = false
                transitionLabel.isEnabled = false
                
                restTitle.isEnabled = false
                restLabel.isEnabled = false
                
            } else if currentTimer == .transition {
                
                intervalTitle.isEnabled = false
                intervalLabel.isEnabled = false
                
                transitionTitle.isEnabled = true
                transitionLabel.isEnabled = true
                
                restTitle.isEnabled = false
                restLabel.isEnabled = false
                
            } else if currentTimer == .rest {
                
                intervalTitle.isEnabled = false
                intervalLabel.isEnabled = false
                
                transitionTitle.isEnabled = false
                transitionLabel.isEnabled = false
                
                restTitle.isEnabled = true
                restLabel.isEnabled = true
                
            }
            
        } else {
            
            intervalTitle.isEnabled = true
            intervalLabel.isEnabled = true
            
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
    
    func updateTotalWorkoutTimeAndLabels() {
        
        workout.setTotalWorkoutSeconds()
        
        workout.setMinutesAndSecondsFromTotalWorkoutSeconds()
        
        totalTimeInWorkout.text = "\(timerForWorkout.zero(unit: workout.setWorkoutMinutes)):\(timerForWorkout.zero(unit: workout.setWorkoutSeconds))"
        
        totalTimeLeft.text = "\(timerForWorkout.zero(unit: workout.remainingWorkoutMinutes)):\(timerForWorkout.zero(unit: workout.remainingWorkoutSeconds))"
        
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

    @objc func intervalTap() {
        
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



extension MainViewController: SetSetsTransitionsAndRestDelegate, UpdateFirstExerciseDelegate, LoadRoutineExercisesDelegate {
    
    func setSets(numberOfSets: Int) {
        
        workout.saveSets(routine: workout.lastUsedRoutine, sets: numberOfSets)
        
        timerProgress.progress = 0.0
        
        setCollectionView.reloadData()
        
        updateTotalWorkoutTimeAndLabels()
        
    }
    
    func setReps(numberOfReps: Int) {
        
        
        
    }
    
    func setTransition(minutes: Int, seconds: Int) {
        
        workout.saveTransitionTime(routine: workout.lastUsedRoutine, minutes: minutes, seconds: seconds)
        
        transitionLabel.text = "\(timerForWorkout.zero(unit: workout.setTransitionMinutes)):\(timerForWorkout.zero(unit: workout.setTransitionSeconds))"
        
        updateTotalWorkoutTimeAndLabels()
        
    }
    
    func setRest(minutes: Int, seconds: Int) {
        
        workout.saveRestTime(routine: workout.lastUsedRoutine, minutes: minutes, seconds: seconds)
        
        restLabel.text = "\(timerForWorkout.zero(unit: workout.setRestMinutes)):\(timerForWorkout.zero(unit: workout.setRestSeconds))"
        
        updateTotalWorkoutTimeAndLabels()
        
    }
    
    func updateFirstExercise() {
        
        workout.loadLastUsedRoutine()
        
        workout.loadExercisesPerRoutine(routine: workout.lastUsedRoutine)
        
        intervalLabel.text = "\(timerForWorkout.zero(unit: Int(workout.exerciseArray[0].intervalMinutes))):\(timerForWorkout.zero(unit: Int(workout.exerciseArray[0].intervalSeconds)))"
        
        workout.setRemainingToSetAmounts(forTimer: .interval)
        
        exerciseCollectionView.reloadData()
        
        updateTotalWorkoutTimeAndLabels()
        
        toggleNavBarTitle()
        
        workout.totalSecondsForProgress = workout.setTotalSecondsForProgressForExercise(index: 0)
        
    }
    
    func reloadExercisesPerRoutine() {
        
        workout.loadLastUsedRoutine()
        
        workout.loadExercisesPerRoutine(routine: workout.lastUsedRoutine)
        
        exerciseCollectionView.reloadData()
        
        updateTotalWorkoutTimeAndLabels()
        
        toggleNavBarTitle()
        
        workout.totalSecondsForProgress = workout.setTotalSecondsForProgressForExercise(index: 0)
        
    }

}



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
                
                // Current Set
                if workout.currentSet == (indexPath.row + 1) {
                    
                    cell.backgroundColor = UIColor.clear
                    cell.setNumberLabel.isEnabled = true
                    cell.setNumberLabel.textColor = UIColor.white
                    
                
                } else if workout.currentSet > (indexPath.row + 1) {
                    
                    cell.backgroundColor = UIColor.white
                    cell.setNumberLabel.isEnabled = true
                    cell.setNumberLabel.textColor = keywords.mainBackgroundColor
                    
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

                cell.exerciseTimeLabel.text = "\(timerForWorkout.zero(unit: Int(currentExercise.intervalMinutes))):\(timerForWorkout.zero(unit: Int(currentExercise.intervalSeconds)))"

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
                    cell.exerciseNameLabel.textColor = keywords.mainBackgroundColor
                    cell.exerciseTimeLabel.textColor = keywords.mainBackgroundColor
                    
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
                
                cell.exerciseNameLabel.font = cell.exerciseNameLabel.font.withSize(24)
                cell.exerciseTimeLabel.font = cell.exerciseTimeLabel.font.withSize(24)
                
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
            
            let size = viewWidth / CGFloat(workout.setNumberOfSets)
            
            return CGSize(width: size, height: 48)
            
        // Exercise Collection
        } else {
            
            var size = CGFloat()
            
            var height = CGFloat()
            
            if workout.exerciseArray.count < 6 {
                
                size = viewWidth / CGFloat(1)
                
                height = 48
                
            } else {
                
                size = viewWidth / CGFloat(2)
                
                height = 36
                
            }
            
            return CGSize(width: size, height: height)
            
        }

    }
    
}









