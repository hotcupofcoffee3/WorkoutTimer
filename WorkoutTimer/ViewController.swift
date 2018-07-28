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



// 1306 - Tock clicking sound (Keyboard click)
// 1072 - Kinda like a busy tone
// 1013 - Sounds kind of like a symbol or chime.
// 1057 - Sounds like a Dark-eyed Junco chirp.
// 1255 - Double beep for starting.
// 1256 - Low to high quick beeps for starting.
// 1330 - Sherwood Forest



import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SetSetsTransitionsAndRestDelegate {
    
    
    
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
    
    var isTime = Bool()
    var isTransition = Bool()
    var isExercise = Bool()
    
    var timerIsStarted = false
    var beganWorkout = false
    
    
    
    // ******
    // *** MARK: - IBOutlets
    // ******
    
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var setCollectionView: UICollectionView!
    
    @IBOutlet weak var exerciseCollectionView: UICollectionView!
    
    @IBOutlet weak var timerProgress: UIProgressView!
    
    @IBOutlet weak var intervalView: UIView!
    
    @IBOutlet weak var intervalLabel: UILabel!
    
    @IBOutlet weak var transitionView: UIView!
    
    @IBOutlet weak var transitionLabel: UILabel!
    
    @IBOutlet weak var restView: UIView!
    
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
                
            workout.totalSecondsForProgress = (currentTimer == .interval) ? workout.setTotalIntervalSeconds : workout.setTotalTransitionSeconds
            
            mainTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
            
            timerForProgress = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(animateProgress), userInfo: nil, repeats: true)
            
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
            
//            let destinationVC = segue.destination as! ExerciseViewController
            
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
            
        }
        
    }
    
    @objc func animateProgress() {
        
        let increment: Float = (1 / (Float(workout.totalSecondsForProgress) * 10))
        
        timerProgress.setProgress(timerProgress.progress + increment, animated: true)
        
    }
    
    func intervalTimer() {
        
//        if workout.setIntervalMinutes == workout.remainingIntervalMinutes && workout.setIntervalSeconds == workout.remainingIntervalSeconds {
//            
//            transitionLabel.text = "\(zero(unit: workout.remainingTransitionMinutes)):\(zero(unit: workout.remainingTransitionSeconds))"
//            
//        }
        
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
            
            if workout.remainingIntervalSeconds == 0 {
                
                workout.currentSet += 1
                
                setCollectionView.reloadData()
                
                if workout.currentSet <= workout.setNumberOfSets {
                    
                    AudioServicesPlaySystemSound(1256)
                    
                    if workout.setTotalTransitionSeconds > 0 {
                        
                        currentTimer = .transition
                        
                        workout.totalSecondsForProgress = workout.setTotalTransitionSeconds
                        
                    } else {
                        
                        workout.totalSecondsForProgress = workout.setTotalIntervalSeconds
                        
//                        workout.remainingIntervalMinutes = workout.setIntervalMinutes
//
//                        workout.remainingIntervalSeconds = workout.setIntervalSeconds
                        
                    }
                    
                    timerProgress.progress = 0.0
                    
                } else if workout.currentSet > workout.setNumberOfSets {
                    
                    mainTimer.invalidate()
                    
                    timerForProgress.invalidate()
                    
                    finishedWorkoutAlert()
                    
                }
                
            }
            
        }
        
        intervalLabel.text = "\(zero(unit: workout.remainingIntervalMinutes)):\(zero(unit: workout.remainingIntervalSeconds))"
        
        if currentTimer == .transition {
            
//            workout.remainingIntervalMinutes = workout.setIntervalMinutes
//
//            workout.remainingIntervalSeconds = workout.setIntervalSeconds
            
        }
        
    }
    
    func transitionTimer() {
        
        if workout.setTransitionMinutes == workout.remainingTransitionMinutes && workout.setTransitionSeconds == workout.remainingTransitionSeconds {
            
            intervalLabel.text = "\(zero(unit: workout.remainingTransitionMinutes)):\(zero(unit: workout.remainingIntervalSeconds))"
            
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
            
            if workout.remainingTransitionSeconds == 0 {
                
                currentTimer = .interval
                
                timerProgress.progress = 0.0
                
                workout.totalSecondsForProgress = workout.setTotalIntervalSeconds
                
                AudioServicesPlaySystemSound(1255)
                
            }
            
        }
        
        transitionLabel.text = "\(zero(unit: workout.remainingTransitionMinutes)):\(zero(unit: workout.remainingTransitionSeconds))"
        
        if currentTimer == .interval {
            
            workout.remainingTransitionMinutes = workout.setTransitionMinutes
            
            workout.remainingTransitionSeconds = workout.setTransitionSeconds
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        
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
        
//        intervalLabel.text = "\(zero(unit: workout.setIntervalMinutes)):\(zero(unit: workout.setIntervalSeconds))"
        
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
        
    }
    
}



// --------------------------------------------------------------------------------------

extension ViewController {
    
    
    
    // ******
    // *** MARK: - Alert, Zero, Reset, and Toggle Button Colors Functions
    // ******
    
    
    
    func finishedWorkoutAlert() {
        
        AudioServicesPlaySystemSound(1330)
        
        let alert = UIAlertController(title: "Finished!", message: "You did it!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "I feel great!", style: .default, handler: { (action) in
            
            self.timerIsStarted = false
            
            self.beganWorkout = false
            
            self.resetInfoToStartingSetAmounts()
        
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
                
                self.resetInfoToStartingSetAmounts()
                
            } else {
                
                self.resetInfoToStartingSetAmounts()
                
            }
            
            self.timerIsStarted = false
            
            self.beganWorkout = false
            
            self.mainTimer.invalidate()
            
            self.timerForProgress.invalidate()
            
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
    
    func resetInfoToStartingSetAmounts() {
        
        workout.currentSet = 1
        
        currentTimer = .interval
        
        setCollectionView.reloadData()
        
        timerProgress.progress = 0.0
        
//        intervalLabel.text = "\(zero(unit: workout.setIntervalMinutes)):\(zero(unit: workout.setIntervalSeconds))"
        
        transitionLabel.text = "\(zero(unit: workout.setTransitionMinutes)):\(zero(unit: workout.setTransitionSeconds))"
        
        workout.setRemainingToSetAmounts()
        
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
                
//                resetEverythingAlert(isTime: true, isTransition: true)
                
            } else {
                
//                setAndTimeTapSegue(isTime: true, isTransition: true)
                
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
        
        workout.setNumberOfSets = numberOfSets
        
        workout.saveSets(sets: numberOfSets)
        
        timerProgress.progress = 0.0
        
        setCollectionView.reloadData()
        
    }
    
    func setTransition(minutes: Int, seconds: Int) {
        
        workout.setTransitionMinutes = minutes
        
        workout.setTransitionSeconds = seconds
        
        workout.saveTransitionTime(minutes: minutes, seconds: seconds)
        
        transitionLabel.text = "\(zero(unit: workout.setTransitionMinutes)):\(zero(unit: workout.setTransitionSeconds))"
        
    }
    
    func setRest(minutes: Int, seconds: Int) {
        
        workout.setRestMinutes = minutes
        
        workout.setRestSeconds = seconds
        
        workout.saveRestTime(minutes: minutes, seconds: seconds)
        
        restLabel.text = "\(zero(unit: workout.setRestMinutes)):\(zero(unit: workout.setRestSeconds))"
        
    }
 
    

    // ******
    // *** MARK: - Collection View
    // ******

    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == self.setCollectionView {
            
            return workout.setNumberOfSets
            
        } else {
            
            return 3
            
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
            
            return cell
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Sets Collection
        
        if collectionView == self.setCollectionView {
            
            let size = viewWidth / CGFloat(workout.setNumberOfSets)
            
            return CGSize(width: size, height: 50)
            
        // Exercise Collection
        } else {
            
            let size = viewWidth / CGFloat(3)
            
            return CGSize(width: size, height: 50)
            
        }

    }
    
}









