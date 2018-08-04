//
//  ViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/23/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

// ******
// *** TODO:
// ******



// Just set up two functions in the Workout Model to calculate the total time and the time left.
// Use these to update UI and to create a timer to count down the amount of time left in the workout, resetting when the workout gets reset, and updated when any information updates.











// 1306 - Tock clicking sound (Keyboard click)
// 1072 - Kinda like a busy tone
// 1013 - Sounds kind of like a symbol or chime.
// 1057 - Sounds like a Dark-eyed Junco chirp.
// 1255 - Double beep for starting.
// 1256 - Low to high quick beeps for starting.
// 1330 - Sherwood Forest



import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SetSetsTransitionsAndRestDelegate, UpdateFirstExerciseDelegate, LoadRoutineExercises {

    
    
    // ******
    // *** MARK: - Variables
    // ******
    
    
    
    let viewWidth = UIScreen.main.bounds.maxX
    
    let keywords = Keywords()
    let workout = Workout()
    
    var currentTimer = Workout.CurrentTimer.interval
    
    var mainTimer = Timer()
    var timerForInterval = Timer()
    var timerForTransition = Timer()
    var timerForProgress = Timer()
    var timerForWorkout = Timer()
    
    var isTime = Bool()
    var isTransition = Bool()
    var isExercise = Bool()
    
    var timerIsStarted = false
    var beganWorkout = false
    
    
    
    // ******
    // *** MARK: - IBOutlets
    // ******
    
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var totalTimeInWorkout: UILabel!
    
    @IBOutlet weak var totalTimeLeft: UILabel!
    
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
        
        resetEverythingAlert(isTime: nil, isTransition: nil, isExercise: nil)
        
    }
    
    @IBAction func startButton(_ sender: UIButton) {
        
        if !timerIsStarted && workout.setTotalIntervalSeconds > 0 {
                
            beganWorkout = true
            
            timerIsStarted = true
            
            toggleButtonColors(reset: false)
            
            toggleTimerViews()
            
            mainTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
            
            timerForProgress = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(animateProgress), userInfo: nil, repeats: true)
            
            timerForWorkout = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(runWorkoutTimer), userInfo: nil, repeats: true)
            
            exerciseCollectionView.reloadData()
            
        }
        
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        
        if timerIsStarted {
            
            mainTimer.invalidate()
            
            timerForProgress.invalidate()
            
            timerIsStarted = false
            
            toggleButtonColors(reset: false)
            
        }
        
    }
    
    
    
    // ******
    // *** MARK: - Segue
    // ******
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == keywords.mainToExerciseSegue {
            
            let destinationVC = segue.destination as! ExerciseViewController
            
            destinationVC.delegate = self
            
            destinationVC.delegate2 = self
            
        } else if segue.identifier == keywords.mainToSetsSegue {
            
            let destinationVC = segue.destination as! SetsTransitionAndRestViewController
            
            destinationVC.delegate = self
            
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
                
                print(workout.remainingWorkoutSeconds)
                
                // Reset amounts
                
                workout.remainingWorkoutMinutes = workout.setWorkoutMinutes
                
                workout.remainingWorkoutSeconds = workout.setWorkoutSeconds
                
            }
            
        }
        
        updateRemainingWorkoutTime()
        
    }
    
    @objc func animateProgress() {
        
        let increment: Float = (1 / (Float(workout.totalSecondsForProgress) * 10))
        
        timerProgress.setProgress(timerProgress.progress + increment, animated: true)
        
    }
    
    func intervalTimer() {
        
        // The first time it is called, it resets the labels of the others.
        
        if Int(workout.exerciseArray[workout.currentExerciseIndex].intervalMinutes) == workout.remainingIntervalMinutes && Int(workout.exerciseArray[workout.currentExerciseIndex].intervalSeconds) == workout.remainingIntervalSeconds {

            transitionLabel.text = "\(zero(unit: workout.remainingTransitionMinutes)):\(zero(unit: workout.remainingTransitionSeconds))"
            
            restLabel.text = "\(zero(unit: workout.remainingRestMinutes)):\(zero(unit: workout.remainingRestSeconds))"
            
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
                
                if workout.remainingIntervalSeconds <= 3 && workout.remainingIntervalSeconds > 0 {
                    
                    AudioServicesPlaySystemSound(1057)
                    
                }
                
            }
            
            
            // End of Exercise Interval
            
            if workout.remainingIntervalSeconds == 0 {
                
                workout.currentExerciseIndex += 1
                
                setCollectionView.reloadData()
                
                AudioServicesPlaySystemSound(1256)
                
                if workout.setTotalTransitionSeconds > 0 && workout.exerciseArray.count > workout.currentExerciseIndex {
                    
                    currentTimer = .transition
                    
                    toggleTimerViews()
                    
                    workout.totalSecondsForProgress = workout.setTotalTransitionSeconds
                    
                } else if workout.setTotalTransitionSeconds == 0 && workout.exerciseArray.count > workout.currentExerciseIndex {
                    
                    workout.totalSecondsForProgress = workout.setTotalSecondsForProgressForExercise(index: workout.currentExerciseIndex)
                    
                    
                // End of Set
                    
                } else if workout.exerciseArray.count == workout.currentExerciseIndex {
                    
                    workout.currentSet += 1
                    
                    workout.currentExerciseIndex = 0
                    
                    if workout.currentSet <= workout.setNumberOfSets {
                        
                        currentTimer = .rest
                        
                        toggleTimerViews()
                        
                        workout.totalSecondsForProgress = workout.setTotalRestSeconds
                        
                    } else if workout.currentSet > workout.setNumberOfSets {
                        
                        mainTimer.invalidate()
                        
                        timerForProgress.invalidate()
                        
                        timerForWorkout.invalidate()
                        
                        workout.remainingWorkoutSeconds = 0
                        
                        updateRemainingWorkoutTime()
                        
                        finishedWorkoutAlert()
                        
                    }

                }
                
                exerciseCollectionView.reloadData()
                
                workout.remainingIntervalMinutes = Int(workout.exerciseArray[workout.currentExerciseIndex].intervalMinutes)
                
                workout.remainingIntervalSeconds = Int(workout.exerciseArray[workout.currentExerciseIndex].intervalSeconds)
                
                timerProgress.progress = 0.0
                
            }
            
        }
        
        intervalLabel.text = "\(zero(unit: workout.remainingIntervalMinutes)):\(zero(unit: workout.remainingIntervalSeconds))"
        
        if currentTimer == .transition || currentTimer == .rest {
            
            workout.remainingIntervalMinutes = Int(workout.exerciseArray[workout.currentExerciseIndex].intervalMinutes)

            workout.remainingIntervalSeconds = Int(workout.exerciseArray[workout.currentExerciseIndex].intervalSeconds)
            
        }
        
    }
    
    func transitionTimer() {
        
        if workout.setTransitionMinutes == workout.remainingTransitionMinutes && workout.setTransitionSeconds == workout.remainingTransitionSeconds {
            
            intervalLabel.text = "\(zero(unit: Int(workout.exerciseArray[workout.currentExerciseIndex].intervalMinutes))):\(zero(unit: Int(workout.exerciseArray[workout.currentExerciseIndex].intervalSeconds)))"
            
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
                
                if workout.remainingTransitionSeconds <= 3 && workout.remainingTransitionSeconds > 0 {
                    
                    AudioServicesPlaySystemSound(1057)
                    
                }
                
            }
            
            
            // End of Transition
            
            if workout.remainingTransitionSeconds == 0 {
                
                if workout.exerciseArray.count > workout.currentExerciseIndex {
                    
                    currentTimer = .interval
                    
                    exerciseCollectionView.reloadData()
                    
                    toggleTimerViews()
                    
                    timerProgress.progress = 0.0
                    
                    workout.totalSecondsForProgress = workout.setTotalSecondsForProgressForExercise(index: workout.currentExerciseIndex)
                    
                    AudioServicesPlaySystemSound(1255)
                    
                }
                
            }
            
        }
        
        transitionLabel.text = "\(zero(unit: workout.remainingTransitionMinutes)):\(zero(unit: workout.remainingTransitionSeconds))"
        
        if currentTimer == .interval {
            
            workout.remainingTransitionMinutes = workout.setTransitionMinutes
            
            workout.remainingTransitionSeconds = workout.setTransitionSeconds
            
        }
        
    }
    
    func restTimer() {
        
        if workout.setRestMinutes == workout.remainingRestMinutes && workout.setRestSeconds == workout.remainingRestSeconds {
            
            intervalLabel.text = "\(zero(unit: Int(workout.exerciseArray[workout.currentExerciseIndex].intervalMinutes))):\(zero(unit: Int(workout.exerciseArray[workout.currentExerciseIndex].intervalSeconds)))"
            
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
                
                if workout.remainingRestSeconds <= 3 && workout.remainingRestSeconds > 0 {
                    
                    AudioServicesPlaySystemSound(1057)
                    
                }
                
            }
            
            if workout.remainingRestSeconds == 0 {
                
                currentTimer = .interval
                
                exerciseCollectionView.reloadData()
                
                toggleTimerViews()
                
                timerProgress.progress = 0.0
                
                workout.totalSecondsForProgress = workout.setTotalSecondsForProgressForExercise(index: 0)
                
                AudioServicesPlaySystemSound(1255)
                
            }
            
        }
        
        restLabel.text = "\(zero(unit: workout.remainingRestMinutes)):\(zero(unit: workout.remainingRestSeconds))"
        
        if currentTimer == .interval {
            
            workout.remainingRestMinutes = workout.setRestMinutes
            
            workout.remainingRestSeconds = workout.setRestSeconds
            
        }
        
    }
    
    
    
    // ******
    // *** Loadables
    // ******
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navBar.setBackgroundImage(UIImage(), for: .default)
//        navBar.shadowImage = UIImage()
        
        setCollectionView.register(UINib(nibName: "SetsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "setCell")
        
        exerciseCollectionView.register(UINib(nibName: "ExerciseCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "exerciseCell")
        
        let setsTapGesture = UITapGestureRecognizer(target: self, action: #selector(setsTap))
        let exerciseTapGesture = UITapGestureRecognizer(target: self, action: #selector(exerciseTap))
        let intervalTapGesture = UITapGestureRecognizer(target: self, action: #selector(intervalTap))
        let transitionTapGesture = UITapGestureRecognizer(target: self, action: #selector(transitionTap))
        let restTapGesture = UITapGestureRecognizer(target: self, action: #selector(restTap))
        
        setCollectionView.addGestureRecognizer(setsTapGesture)
        exerciseCollectionView.addGestureRecognizer(exerciseTapGesture)
        intervalView.addGestureRecognizer(intervalTapGesture)
        transitionView.addGestureRecognizer(transitionTapGesture)
        restView.addGestureRecognizer(restTapGesture)
        
        updateIntervalLabelToFirstExercise()
        
        updateTotalWorkoutTimeAndLabels()
        
        transitionLabel.text = "\(zero(unit: workout.setTransitionMinutes)):\(zero(unit: workout.setTransitionSeconds))"
        
        restLabel.text = "\(zero(unit: workout.setRestMinutes)):\(zero(unit: workout.setRestSeconds))"
        
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
    
}





















// --------------------------------------------------------------------------------------

extension ViewController {
    
    
    
    // ******
    // *** MARK: - Alert, Zero, Reset, Interval Label, and Toggle Button Colors Functions
    // ******
    
    
    
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
        
        let alert = UIAlertController(title: "Reset?", message: "This will reset all values.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { (action) in
            
            if self.beganWorkout {
                
                if let time = isTime, let transition = isTransition, let exercise = isExercise {
                    
                    self.setAndTimeTapSegue(isTime: time, isTransition: transition, isExercise: exercise)
                    
                }
                
            }
            
            self.timerIsStarted = false
            
            self.beganWorkout = false
            
            self.mainTimer.invalidate()
            
            self.timerForProgress.invalidate()
            
            self.timerForWorkout.invalidate()
            
            self.resetInfoToStartingSetAmounts()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func zero(unit: Int) -> String {
        
        var zero = "\(unit)"
        
        if unit <= 9 {
            
            zero = "0\(unit)"
            
        }
        
        return zero
        
    }
    
    func updateIntervalLabelToFirstExercise() {
        
        let firstExercise = workout.exerciseArray[0]
        
        intervalLabel.text = "\(zero(unit: Int(firstExercise.intervalMinutes))):\(zero(unit: Int(firstExercise.intervalSeconds)))"
        
    }
    
    func resetInfoToStartingSetAmounts() {
        
        workout.currentSet = 1
        
        workout.currentExerciseIndex = 0
        
        currentTimer = .interval
        
        setCollectionView.reloadData()
        
        exerciseCollectionView.reloadData()
        
        timerProgress.progress = 0.0
        
        updateIntervalLabelToFirstExercise()
        
        transitionLabel.text = "\(zero(unit: workout.setTransitionMinutes)):\(zero(unit: workout.setTransitionSeconds))"
        
        workout.setRemainingToSetAmounts()
        
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
            
            startButtonOutlet.layer.backgroundColor = UIColor.clear.cgColor
            startButtonOutlet.setTitleColor(UIColor.white, for: .normal)
            
            stopButtonOutlet.layer.backgroundColor = UIColor.clear.cgColor
            stopButtonOutlet.setTitleColor(UIColor.white, for: .normal)
            
        } else {
            
            if timerIsStarted {
                
                startButtonOutlet.layer.backgroundColor = UIColor.white.cgColor
                startButtonOutlet.setTitleColor(keywords.mainBackgroundColor, for: .normal)
                
                stopButtonOutlet.layer.backgroundColor = UIColor.clear.cgColor
                stopButtonOutlet.setTitleColor(UIColor.white, for: .normal)
                
            } else {
                
                startButtonOutlet.layer.backgroundColor = UIColor.clear.cgColor
                startButtonOutlet.setTitleColor(UIColor.white, for: .normal)
                
                stopButtonOutlet.layer.backgroundColor = UIColor.white.cgColor
                stopButtonOutlet.setTitleColor(keywords.mainBackgroundColor, for: .normal)
                
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
    
    func updateRemainingWorkoutTime() {
        
        totalTimeLeft.text = "\(zero(unit: workout.remainingWorkoutMinutes)):\(zero(unit: workout.remainingWorkoutSeconds))"
        
    }
    
    func updateTotalWorkoutTimeAndLabels() {
        
        workout.setTotalWorkoutSeconds()
        
        workout.setMinutesAndSecondsFromTotalWorkoutSeconds()
        
        totalTimeInWorkout.text = "\(zero(unit: workout.setWorkoutMinutes)):\(zero(unit: workout.setWorkoutSeconds))"
        
        updateRemainingWorkoutTime()
        
    }
 
    
    
    // ******
    // *** MARK: - Tap Functions
    // ******
    
    

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

    
    
    // ******
    // *** MARK: - Delegates
    // ******

    
    
    func setSets(numberOfSets: Int) {
        
        workout.saveSets(sets: numberOfSets)
        
        timerProgress.progress = 0.0
        
        setCollectionView.reloadData()
        
        updateTotalWorkoutTimeAndLabels()
        
    }
    
    func setTransition(minutes: Int, seconds: Int) {
        
        workout.saveTransitionTime(minutes: minutes, seconds: seconds)
        
        transitionLabel.text = "\(zero(unit: workout.setTransitionMinutes)):\(zero(unit: workout.setTransitionSeconds))"
        
        updateTotalWorkoutTimeAndLabels()
        
    }
    
    func setRest(minutes: Int, seconds: Int) {
        
        workout.saveRestTime(minutes: minutes, seconds: seconds)
        
        restLabel.text = "\(zero(unit: workout.setRestMinutes)):\(zero(unit: workout.setRestSeconds))"
        
        updateTotalWorkoutTimeAndLabels()
        
    }
    
    func updateFirstExercise(withExercise firstExercise: Exercise) {
        
        workout.loadLastUsedRoutine()
        print(workout.lastUsedRoutine)
        
        workout.loadExercisesPerRoutine(routine: workout.lastUsedRoutine)
        
        intervalLabel.text = "\(zero(unit: Int(firstExercise.intervalMinutes))):\(zero(unit: Int(firstExercise.intervalSeconds)))"
        
        workout.setTotalAndRemainingStartingIntervalAmounts()
        
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
 
    

    // ******
    // *** MARK: - Collection View
    // ******

    
    
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
            
            if workout.currentSet > 1 && indexPath.row < (workout.currentSet - 1) {
                
                cell.backgroundColor = UIColor.white
                cell.setNumberLabel.textColor = keywords.mainBackgroundColor
                
            } else {
                
                cell.backgroundColor = UIColor.clear
                cell.setNumberLabel.textColor = UIColor.white
                
            }
            
            return cell
            
            
            
        // Exercise Collection
            
        } else {
            
            let cell = exerciseCollectionView.dequeueReusableCell(withReuseIdentifier: "exerciseCell", for: indexPath) as! ExerciseCollectionViewCell
            
            let currentExercise = workout.exerciseArray[indexPath.row]
            
            cell.exerciseNameLabel.text = "\(currentExercise.name!)"
            cell.exerciseTimeLabel.text = "\(zero(unit: Int(currentExercise.intervalMinutes))):\(zero(unit: Int(currentExercise.intervalSeconds)))"
            
            if beganWorkout {
                
                if workout.currentExerciseIndex == indexPath.row {
                    
                    if currentTimer == .interval {
                        
                        cell.backgroundColor = keywords.currentExerciseColor
                        cell.exerciseNameLabel.textColor = UIColor.white
                        cell.exerciseTimeLabel.textColor = UIColor.white
                        
                    } else {
                        
                        cell.backgroundColor = UIColor.clear
                        cell.exerciseNameLabel.textColor = UIColor.white
                        cell.exerciseTimeLabel.textColor = UIColor.white
                        
                    }
                   
                } else if workout.currentExerciseIndex > indexPath.row {
                    
                    cell.backgroundColor = UIColor.white
                    cell.exerciseNameLabel.textColor = keywords.mainBackgroundColor
                    cell.exerciseTimeLabel.textColor = keywords.mainBackgroundColor
                    
                } else {
                    
                    cell.backgroundColor = UIColor.clear
                    cell.exerciseNameLabel.textColor = UIColor.white
                    cell.exerciseTimeLabel.textColor = UIColor.white
                    
                }
                
            } else {
                
                cell.backgroundColor = UIColor.clear
                cell.exerciseNameLabel.textColor = UIColor.white
                cell.exerciseTimeLabel.textColor = UIColor.white
                
            }
            
            
            
            // Size of font
            
            if workout.exerciseArray.count < 6 {
                
                cell.exerciseNameLabel.font = UIFont(name: "Helvetica Neue", size: 24)
                cell.exerciseTimeLabel.font = UIFont(name: "Helvetica Neue", size: 24)
                
            } else {
                
                cell.exerciseNameLabel.font = UIFont(name: "Helvetica Neue", size: 18)
                cell.exerciseTimeLabel.font = UIFont(name: "Helvetica Neue", size: 18)
                
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









