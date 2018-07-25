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



// Convert everything to the CoreData workout model.



// 1306 - Tock clicking sound (Keyboard click)
// 1072 - Kinda like a busy tone
// 1013 - Sounds kind of like a symbol or chime.
// 1057 - Sounds like a Dark-eyed Junco chirp.
// 1255 - Double beep for starting.
// 1256 - Low to high quick beeps for starting.
// 1330 - Sherwood Forest

// let systemSoundID: SystemSoundID = 1330

// AudioServicesPlaySystemSound(systemSoundID)



import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SetNumberDelegate {
    
    
    
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
    var isInterval = Bool()
    
    var timerIsStarted = false
    var beganWorkout = false
    
    var setNumberOfSets = 10
    var currentSet = 1
    
    var setIntervalMinutes = 0
    var setIntervalSeconds = 0
    var setTransitionMinutes = 0
    var setTransitionSeconds = 0
    
    var setTotalIntervalSeconds = 0
    var setTotalTransitionSeconds = 0
    
    var remainingIntervalMinutes = 0
    var remainingIntervalSeconds = 0
    var remainingTransitionMinutes = 0
    var remainingTransitionSeconds = 0
    
    var totalSecondsForProgress = 10
    
    
    
    // ******
    // *** MARK: - IBOutlets
    // ******
    
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var setCollectionView: UICollectionView!
    
    @IBOutlet weak var timerProgress: UIProgressView!
    
    @IBOutlet weak var intervalView: UIView!
    
    @IBOutlet weak var intervalLabel: UILabel!
    
    @IBOutlet weak var transitionView: UIView!
    
    @IBOutlet weak var transitionLabel: UILabel!
    
    @IBOutlet weak var startButtonOutlet: UIButton!
    
    @IBOutlet weak var stopButtonOutlet: UIButton!
    
    
    
    // ******
    // *** MARK: - IBActions
    // ******
    
    
    
    @IBAction func resetButton(_ sender: UIBarButtonItem) {
        
        resetEverythingAlert(isTime: nil, isInterval: nil)
        
    }
    
    @IBAction func startButton(_ sender: UIButton) {
        
        if !timerIsStarted {
            
            if setTotalIntervalSeconds > 0 {
                
                beganWorkout = true
                
                totalSecondsForProgress = (currentTimer == .interval) ? setTotalIntervalSeconds : setTotalTransitionSeconds
                
                mainTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
                
                timerForProgress = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(animateProgress), userInfo: nil, repeats: true)
                
            }
            
        }
        
        timerIsStarted = true
        
        toggleButtonColors()
        
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        
        mainTimer.invalidate()
        
        timerForProgress.invalidate()
        
        timerIsStarted = false
        
        toggleButtonColors()
        
    }
    
    
    
    // ******
    // *** MARK: - Segue
    // ******
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == keywords.mainToPickerSegue {
            
            let destinationVC = segue.destination as! TimeAndNumberViewController
            
            destinationVC.isTime = isTime
            
            destinationVC.isInterval = isInterval
            
            destinationVC.delegate = self
            
            if isTime {
                
                if isInterval {
                    
                    destinationVC.minutes = setIntervalMinutes
                    
                    destinationVC.seconds = setIntervalSeconds
                    
                } else if !isInterval {
                    
                    destinationVC.minutes = setTransitionMinutes
                    
                    destinationVC.seconds = setTransitionSeconds
                    
                }
                
            } else if !isTime {
                
                destinationVC.numberOfSets = setNumberOfSets
                
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
        
        let increment: Float = (1 / (Float(totalSecondsForProgress) * 10))
        
        timerProgress.setProgress(timerProgress.progress + increment, animated: true)
        
    }
    
    func intervalTimer() {
        
        if setIntervalMinutes == remainingIntervalMinutes && setIntervalSeconds == remainingIntervalSeconds {
            
            transitionLabel.text = "\(zero(unit: remainingTransitionMinutes)):\(zero(unit: remainingTransitionSeconds))"
            
        }
        
        if remainingIntervalMinutes > 0 {
            
            if remainingIntervalSeconds > 0 {
                
                remainingIntervalSeconds -= 1
                
            } else {
                
                remainingIntervalMinutes -= 1
                
                remainingIntervalSeconds = 59
                
            }
            
        } else if remainingIntervalMinutes == 0 {
            
            if remainingIntervalSeconds > 0 {
                
                remainingIntervalSeconds -= 1
                
                if remainingIntervalSeconds <= 3 && remainingIntervalSeconds > 0 {
                    
                    AudioServicesPlaySystemSound(1057)
                    
                }
                
            }
            
            if remainingIntervalSeconds == 0 {
                
                currentSet += 1
                
                if currentSet <= setNumberOfSets {
                    
                    AudioServicesPlaySystemSound(1256)
                    
                    setCollectionView.reloadData()
                    
                    if setTotalTransitionSeconds > 0 {
                        
                        currentTimer = .transition
                        
                        totalSecondsForProgress = setTotalTransitionSeconds
                        
                    } else {
                        
                        totalSecondsForProgress = setTotalIntervalSeconds
                        
                        remainingIntervalMinutes = setIntervalMinutes
                        
                        remainingIntervalSeconds = setIntervalSeconds
                        
                    }
                    
                    timerProgress.progress = 0.0
                    
                } else if currentSet > setNumberOfSets {
                    
                    mainTimer.invalidate()
                    
                    timerForProgress.invalidate()
                    
                    finishedWorkoutAlert()
                    
                }
                
            }
            
        }
        
        intervalLabel.text = "\(zero(unit: remainingIntervalMinutes)):\(zero(unit: remainingIntervalSeconds))"
        
        if currentTimer == .transition {
            
            remainingIntervalMinutes = setIntervalMinutes
            
            remainingIntervalSeconds = setIntervalSeconds
            
        }
        
    }
    
    func transitionTimer() {
        
        if setTransitionMinutes == remainingTransitionMinutes && setTransitionSeconds == remainingTransitionSeconds {
            
            intervalLabel.text = "\(zero(unit: remainingTransitionMinutes)):\(zero(unit: remainingIntervalSeconds))"
            
        }
        
        if remainingTransitionMinutes > 0 {
            
            if remainingTransitionSeconds > 0 {
                
                remainingTransitionSeconds -= 1
                
            } else {
                
                remainingTransitionMinutes -= 1
                
                remainingTransitionSeconds = 59
                
            }
            
        } else if remainingTransitionMinutes == 0 {
            
            if remainingTransitionSeconds > 0 {
                
                remainingTransitionSeconds -= 1
                
                if remainingTransitionSeconds <= 3 && remainingTransitionSeconds > 0 {
                    
                    AudioServicesPlaySystemSound(1057)
                    
                }
                
            }
            
            if remainingTransitionSeconds == 0 {
                
                currentTimer = .interval
                
                timerProgress.progress = 0.0
                
                totalSecondsForProgress = setTotalIntervalSeconds
                
                AudioServicesPlaySystemSound(1255)
                
            }
            
        }
        
        transitionLabel.text = "\(zero(unit: remainingTransitionMinutes)):\(zero(unit: remainingTransitionSeconds))"
        
        if currentTimer == .interval {
            
            remainingTransitionMinutes = setTransitionMinutes
            
            remainingTransitionSeconds = setTransitionSeconds
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        
        setCollectionView.register(UINib(nibName: "SetsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "setCell")
        
        let setsTapGesture = UITapGestureRecognizer(target: self, action: #selector(setsTap))
        let intervalTapGesture = UITapGestureRecognizer(target: self, action: #selector(intervalTap))
        let transitionTapGesture = UITapGestureRecognizer(target: self, action: #selector(transitionTap))
        
        setCollectionView.addGestureRecognizer(setsTapGesture)
        intervalView.addGestureRecognizer(intervalTapGesture)
        transitionView.addGestureRecognizer(transitionTapGesture)
        
        intervalLabel.text = "\(zero(unit: setIntervalMinutes)):\(zero(unit: setIntervalSeconds))"
        
        transitionLabel.text = "\(zero(unit: setTransitionMinutes)):\(zero(unit: setTransitionSeconds))"
        
        timerProgress.progress = 0.0
        
        startButtonOutlet.layer.borderColor = UIColor.white.cgColor
        startButtonOutlet.layer.borderWidth = 2
        startButtonOutlet.layer.cornerRadius = 45
        
        stopButtonOutlet.layer.borderColor = UIColor.white.cgColor
        stopButtonOutlet.layer.borderWidth = 2
        stopButtonOutlet.layer.cornerRadius = 45
        
        toggleButtonColors()
        
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
    
    func resetEverythingAlert(isTime: Bool?, isInterval: Bool?) {
        
        let alert = UIAlertController(title: "Reset?", message: "This will reset all values.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { (action) in
            
            if self.beganWorkout {
                
                if let time = isTime, let interval = isInterval {
                    
                    self.setAndTimeTapSegue(isTime: time, isInterval: interval)
                    
                }
                
                self.timerIsStarted = false
                
                self.beganWorkout = false
                
                self.resetInfoToStartingSetAmounts()
                
            } else {
                
                self.reset()
                
                self.timerIsStarted = false
                
                self.beganWorkout = false
                
            }
            
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
    
    func reset() {
        
        setInfoToNil()
        
        resetInfoToStartingSetAmounts()
        
    }
    
    func setInfoToNil() {
        
        setNumberOfSets = 10
        
        setIntervalMinutes = 0
        
        setIntervalSeconds = 0
        
        setTransitionMinutes = 0
        
        setTransitionSeconds = 0
        
    }
    
    func setRemainingToSet() {
        
        remainingIntervalMinutes = setIntervalMinutes
        
        remainingIntervalSeconds = setIntervalSeconds
        
        remainingTransitionMinutes = setTransitionMinutes
        
        remainingTransitionSeconds = setTransitionSeconds
        
    }
    
    func resetInfoToStartingSetAmounts() {
        
        currentSet = 1
        
        currentTimer = .interval
        
        setCollectionView.reloadData()
        
        timerProgress.progress = 0.0
        
        intervalLabel.text = "\(zero(unit: setIntervalMinutes)):\(zero(unit: setIntervalSeconds))"
        
        transitionLabel.text = "\(zero(unit: setTransitionMinutes)):\(zero(unit: setTransitionSeconds))"
        
        setRemainingToSet()
        
        toggleButtonColors()
        
    }
    
    func setAndTimeTapSegue(isTime: Bool, isInterval: Bool) {
        
        self.isTime = isTime
        self.isInterval = isInterval
        
        performSegue(withIdentifier: keywords.mainToPickerSegue, sender: self)
        
    }
    
    func toggleButtonColors() {
        
        if !beganWorkout {
            
            startButtonOutlet.layer.backgroundColor = keywords.mainBackgroundColor.cgColor
            startButtonOutlet.setTitleColor(UIColor.white, for: .normal)
            
            stopButtonOutlet.layer.backgroundColor = keywords.mainBackgroundColor.cgColor
            stopButtonOutlet.setTitleColor(UIColor.white, for: .normal)
            
        } else {
            
            if timerIsStarted {
                
                startButtonOutlet.layer.backgroundColor = UIColor.white.cgColor
                startButtonOutlet.setTitleColor(keywords.mainBackgroundColor, for: .normal)
                
                stopButtonOutlet.layer.backgroundColor = keywords.mainBackgroundColor.cgColor
                stopButtonOutlet.setTitleColor(UIColor.white, for: .normal)
                
            } else {
                
                startButtonOutlet.layer.backgroundColor = keywords.mainBackgroundColor.cgColor
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
                
                resetEverythingAlert(isTime: false, isInterval: false)
                
            } else {
                
                setAndTimeTapSegue(isTime: false, isInterval: false)
                
            }
           
        }
        
    }

    @objc func intervalTap() {
        
        if !timerIsStarted {
            
            if beganWorkout {
                
                resetEverythingAlert(isTime: true, isInterval: true)
                
            } else {
                
                setAndTimeTapSegue(isTime: true, isInterval: true)
                
            }
            
        }
        
    }

    @objc func transitionTap() {
        
        if !timerIsStarted {
            
            if beganWorkout {
                
                resetEverythingAlert(isTime: true, isInterval: false)
                
            } else {
                
                setAndTimeTapSegue(isTime: true, isInterval: false)
                
            }
            
        }
        
    }

    
    
    // ******
    // *** MARK: - Delegates
    // ******

    
    
    func setSets(numberOfSets: Int) {
        
        setNumberOfSets = numberOfSets
        
        timerProgress.progress = 0.0
        
        setCollectionView.reloadData()
        
    }
    
    func setTime(minutes: Int, seconds: Int) {
        
        timerProgress.progress = 0.0
        
        setCollectionView.reloadData()
        
        if isInterval {
            
            setIntervalMinutes = minutes
            
            setIntervalSeconds = seconds
            
            remainingIntervalMinutes = minutes
            
            remainingIntervalSeconds = seconds
            
            setTotalIntervalSeconds = (minutes * 60) + seconds
            
        } else if !isInterval {
            
            setTransitionMinutes = minutes
            
            setTransitionSeconds = seconds
            
            remainingTransitionMinutes = minutes
            
            remainingTransitionSeconds = seconds
            
            setTotalTransitionSeconds = (minutes * 60) + seconds
            
        }
        
        intervalLabel.text = "\(zero(unit: setIntervalMinutes)):\(zero(unit: setIntervalSeconds))"
        
        transitionLabel.text = "\(zero(unit: setTransitionMinutes)):\(zero(unit: setTransitionSeconds))"
        
    }
 
    

    // ******
    // *** MARK: - Collection View
    // ******

    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return setNumberOfSets
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "setCell", for: indexPath) as! SetsCollectionViewCell
        
        cell.setNumberLabel.text = "\(indexPath.row + 1)"
        
        if currentSet > 1 && indexPath.row < (currentSet - 1) {
            
            cell.backgroundColor = UIColor.white
            cell.setNumberLabel.textColor = keywords.mainBackgroundColor

        } else {
            
            cell.backgroundColor = UIColor.clear
            cell.setNumberLabel.textColor = UIColor.white
            
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = viewWidth / CGFloat(setNumberOfSets)
        
        return CGSize(width: size, height: 50)
        
    }
    
}









