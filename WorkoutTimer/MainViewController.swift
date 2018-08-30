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



// LAST: Screenshot of InApp Purchase screen.
// LAST: Record Gif of app use for screenshots.
// LAST: Make sure the other updated screenshots match what you seen on the current version of the app.



import UIKit
import AVFoundation

class MainViewController: UIViewController {
    
    // ******
    // *** MARK: - Variables
    // ******
    
    
    
    let viewWidth = UIScreen.main.bounds.maxX
    
    let workout = Workout()
    let timerForWorkout = TimerForWorkout()
    let typeOfViewController = TypeOfViewController.Main
    var instructions = InstructionItem(type: .Main)
    
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
        
        if segue.identifier == Keywords.shared.mainToInstructionsSegue {
            
            let destinationVC = segue.destination as! InstructionViewController
            
            destinationVC.instructionsWereShownDelegate = self
            
            destinationVC.instructions = instructions.message
            
        } else if segue.identifier == Keywords.shared.mainToRoutinesSegue {
            
            let destinationVC = segue.destination as! RoutineViewController
            
            destinationVC.loadRoutineExercisesDelegate = self
            
            destinationVC.setSetsTransitionsAndRestDelegate = self
            
        } else if segue.identifier == Keywords.shared.mainToExerciseSegue {
            
            let destinationVC = segue.destination as! ExerciseViewController
            
            destinationVC.loadRoutineExercisesDelegate = self
            
        } else if segue.identifier == Keywords.shared.mainToSetsSegue {
            
            let destinationVC = segue.destination as! SetsTransitionAndRestViewController
            
            destinationVC.setSetsTransitionsAndRestDelegate = self
            
            destinationVC.isTime = isTime
            
            destinationVC.isTransition = isTransition
            
            if isTime {
                
                destinationVC.minutes = isTransition ? workout.setTransitionMinutes : workout.setRestMinutes
                
                destinationVC.seconds = isTransition ? Int(workout.setTransitionSeconds) : Int(workout.setRestSeconds)
                
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
    
    override func viewDidAppear(_ animated: Bool) {
        
        instructions.presentInstructions {
            self.performSegue(withIdentifier: self.instructions.segueKey, sender: self)
        }
        
//        if UserDefaults.standard.object(forKey: typeOfViewController.rawValue) == nil {
//            DispatchQueue.main.asyncAfter(deadline: .now() + instructions.timeBeforeShowing) {
//                self.performSegue(withIdentifier: self.instructions.segueKey, sender: self)
//            }
//        } else {
//            //            UserDefaults.standard.set(nil, forKey: typeOfViewController.rawValue)
//        }
        
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
        
        if workout.checkIfSecondsAreEven(seconds: workout.remainingWorkoutSeconds) {
            
            totalTimeLeft.text = workout.setLabelTextForTimer(forTimer: .workout, isRemaining: true)
            
        }
        
    }
    
    @objc func animateProgress() {
        
        let increment: Float = (1 / (Float(workout.totalSecondsForProgress) * 10))
        
        timerProgress.setProgress(timerProgress.progress + increment, animated: true)
        
    }
    
    func intervalTimer() {
        
        // The first time it is called, it resets the labels of the others.

        if Int(workout.exerciseArray[workout.currentExerciseIndex].intervalMinutes) == workout.remainingIntervalMinutes && Double(workout.exerciseArray[workout.currentExerciseIndex].intervalSeconds) == workout.remainingIntervalSeconds {

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
            
            AudioServicesPlaySystemSound(1256)
            
            // More exercises.
            
            if workout.currentExerciseIndex < workout.exerciseArray.count {
                
                toggleGoToTransitionOrRest(goToTransition: true, isReps: false)
                
            // End of Set
                
            } else if workout.exerciseArray.count == workout.currentExerciseIndex {
                
                workout.currentSet += 1
                
                workout.currentExerciseIndex = 0
                
                setCollectionView.reloadData()
                
                // More Sets
                
                if workout.currentSet <= workout.setNumberOfSets {
                    
                    toggleGoToTransitionOrRest(goToTransition: false, isReps: false)
                 
                // End of Workout
                    
                } else if workout.currentSet > workout.setNumberOfSets {
                    
                    toggleTimers(runTimer: false)
                    
                    workout.remainingWorkoutSeconds = 0
                    
                    totalTimeLeft.text = workout.setLabelTextForTimer(forTimer: .workout, isRemaining: true)
                    
                    finishedWorkoutAlert()
                    
                }
                
            }
            
        }
        
        if workout.checkIfSecondsAreEven(seconds: workout.remainingIntervalSeconds) {
            
            exerciseCollectionView.reloadData()
            
        }
        
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
        
        if workout.checkIfSecondsAreEven(seconds: workout.remainingTransitionSeconds) {
        
            transitionLabel.text = workout.setLabelTextForTimer(forTimer: .transition, isRemaining: true)
            
        }
        
        if currentTimer != .transition {
            
            workout.setRemainingToSetAmounts(forTimer: .transition)
            
        }
        
    }
    
    func restTimer() {
        
        if workout.setRestMinutes == workout.remainingRestMinutes && workout.setRestSeconds == workout.remainingRestSeconds {
            
            workout.setRemainingToSetAmounts(forTimer: .interval, withIndex: 0)
            
            workout.setRemainingToSetAmounts(forTimer: .transition)
            
            transitionLabel.text = workout.setLabelTextForTimer(forTimer: .transition, isRemaining: false)
            
        }
        
        workout.updateRemainingTimerMinutesAndSeconds(typeOfTimer: .rest)
        
        // End of rest
        
        if workout.remainingRestMinutes == 0 && workout.remainingRestSeconds == 0 {
            
            endTransitionOrRest(withCurrentExercise: 0)
            
        }
        
        if workout.checkIfSecondsAreEven(seconds: workout.remainingRestSeconds) {
        
            restLabel.text = workout.setLabelTextForTimer(forTimer: .rest, isRemaining: true)
            
        }
        
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
        
        let exercise = workout.exerciseArray[workout.currentExerciseIndex].name!
        
        let reps = "\(workout.exerciseArray[workout.currentExerciseIndex].reps) reps"
        
        let alert = UIAlertController(title: "\(exercise)", message: "\(reps)", preferredStyle: .alert)
        
        let title = NSAttributedString(string: "\(exercise)", attributes: [NSAttributedStringKey.foregroundColor:Keywords.shared.darkBluishColor, NSAttributedStringKey.font:UIFont(name: "Helvetica", size: 24)!])
        
        let message = NSAttributedString(string: "\n\(reps)", attributes: [NSAttributedStringKey.foregroundColor:Keywords.shared.mainBackgroundColor, NSAttributedStringKey.font:UIFont(name: "Helvetica", size: 21)!])
        
        alert.setValue(title, forKey: "attributedTitle")
        
        alert.setValue(message, forKey: "attributedMessage")
        
        let action = UIAlertAction(title: "Done", style: .default, handler: { (action) in
            
            AudioServicesPlaySystemSound(1256)
            
            // Transition.
            
            if self.workout.currentExerciseIndex < self.workout.exerciseArray.count {
                
                self.toggleTimers(runTimer: true)
                
            // Rest.
                
            } else if self.workout.exerciseArray.count == self.workout.currentExerciseIndex {
                
                self.workout.currentSet += 1
                
                self.workout.currentExerciseIndex = 0
                
                self.setCollectionView.reloadData()
                
                // More Sets
                
                if self.workout.currentSet <= self.workout.setNumberOfSets {
                    
                    self.toggleTimers(runTimer: true)
                    
                // End of Workout
                    
                } else if self.workout.currentSet > self.workout.setNumberOfSets {
                    
                    self.toggleTimers(runTimer: false)
                    
                    self.workout.remainingWorkoutSeconds = 0
                    
                    self.totalTimeLeft.text = self.workout.setLabelTextForTimer(forTimer: .workout, isRemaining: true)
                    
                    self.finishedWorkoutAlert()
                    
                }
                
            }
            
            self.exerciseCollectionView.reloadData()
            
            if self.currentTimer != .interval {
                
                self.workout.setRemainingToSetAmounts(forTimer: .interval, withIndex: self.workout.currentExerciseIndex)
                
            }
            
            self.toggleTimerViews()
            
        })
        
        action.setValue(Keywords.shared.lighterTealishColor, forKey: "titleTextColor")
        
        alert.addAction(action)
        
        present(alert, animated: true) {
            
            if self.workout.currentExerciseIndex == 0 {
                
                self.toggleGoToTransitionOrRest(goToTransition: false, isReps: true)
                
            }
            
            self.workout.currentExerciseIndex += 1
            
            self.timerProgress.progress = 0.0
            
            // More Exercises.
            
            if self.workout.currentExerciseIndex < self.workout.exerciseArray.count {
                
                self.workout.convertWorkoutSecondsUpWhenTimersPaused()
                
                self.totalTimeLeft.text = self.workout.setLabelTextForTimer(forTimer: .workout, isRemaining: true)
                
                self.workout.setRemainingToSetAmounts(forTimer: .transition)
                
                self.toggleGoToTransitionOrRest(goToTransition: true, isReps: true)
                
            // Sets
                
            } else if self.workout.exerciseArray.count == self.workout.currentExerciseIndex {
                
                if self.workout.currentSet <= self.workout.setNumberOfSets {
                    
                    self.workout.convertWorkoutSecondsUpWhenTimersPaused()
                    
                    self.totalTimeLeft.text = self.workout.setLabelTextForTimer(forTimer: .workout, isRemaining: true)
                    
                    self.workout.setRemainingToSetAmounts(forTimer: .rest)
                        
                    self.toggleGoToTransitionOrRest(goToTransition: false, isReps: true)
                    
                }
                
            }
            
        }
        
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
                        
                        self.performSegue(withIdentifier: Keywords.shared.mainToRoutinesSegue, sender: self)
                        
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
            
            performSegue(withIdentifier: Keywords.shared.mainToExerciseSegue, sender: self)
            
        } else {
            
            performSegue(withIdentifier: Keywords.shared.mainToSetsSegue, sender: self)
            
        }
        
    }
    
    func toggleNavBarTitle() {
        
        navBar.topItem?.title = workout.lastUsedRoutine
        
    }
    
    func toggleStartStopButton() {
        
        if timerIsStarted {
    
            startStopButtonOutlet.setTitle("Stop", for: .normal)
            startStopButtonOutlet.layer.backgroundColor = Keywords.shared.stopColor.cgColor
            
        } else {
            
            startStopButtonOutlet.setTitle("Start", for: .normal)
            startStopButtonOutlet.layer.backgroundColor = Keywords.shared.startColor.cgColor
            
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
            
            mainTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.runTimer), userInfo: nil, repeats: true)
            
            timerForProgress = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.animateProgress), userInfo: nil, repeats: true)
            
            timerForTotalWorkout = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.runWorkoutTimer), userInfo: nil, repeats: true)
            
        } else {
            
            mainTimer.invalidate()
            
            timerForProgress.invalidate()
            
            timerForTotalWorkout.invalidate()
            
        }
        
    }
    
    func toggleGoToTransitionOrRest(goToTransition: Bool, isReps: Bool) {
        
        if goToTransition {
            
            if workout.setTotalTransitionSeconds > 0 {
                
                currentTimer = .transition
                
                workout.totalSecondsForProgress = workout.setTotalTransitionSeconds
                
                transitionLabel.text = workout.setLabelTextForTimer(forTimer: .transition, isRemaining: false)
                
            } else {
                
                workout.totalSecondsForProgress = workout.setTotalSecondsForProgressForExercise(index: workout.currentExerciseIndex)
                
            }
            
        } else {
            
            if workout.setTotalRestSeconds > 0 {
                
                currentTimer = .rest
                
                workout.totalSecondsForProgress = workout.setTotalRestSeconds
                
                restLabel.text = workout.setLabelTextForTimer(forTimer: .rest, isRemaining: false)
                
            } else {
                
                workout.totalSecondsForProgress = workout.setTotalSecondsForProgressForExercise(index: workout.currentExerciseIndex)
                
            }
            
        }
        
        if !isReps {
            
            toggleTimerViews()
            
        }
        
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
                
                performSegue(withIdentifier: Keywords.shared.mainToRoutinesSegue, sender: self)
                
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

extension MainViewController: SetSetsTransitionsAndRestDelegate, LoadRoutineExercisesDelegate, InstructionsWereShownDelegate {
    
    func instructionsWereShown() {
        instructions.wereShown = true
        UserDefaults.standard.set(instructions.wereShown, forKey: typeOfViewController.rawValue)
    }
    
    
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
                    cell.setNumberLabel.textColor = Keywords.shared.darkBluishColor
                    
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
                
                if workout.currentExerciseIndex == indexPath.row && currentTimer == .interval {
                    
                    cell.backgroundColor = UIColor.clear
                    cell.exerciseNameLabel.textColor = UIColor.white
                    cell.exerciseTimeLabel.textColor = UIColor.white
                    
                    cell.exerciseNameLabel.isEnabled = true
                    cell.exerciseTimeLabel.isEnabled = true
                   
                } else if workout.currentExerciseIndex > indexPath.row {
                    
                    cell.backgroundColor = UIColor.white
                    cell.exerciseNameLabel.textColor = Keywords.shared.darkBluishColor
                    cell.exerciseTimeLabel.textColor = Keywords.shared.darkBluishColor
                    
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
            
            return CGSize(width: width, height: 48)
            
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









