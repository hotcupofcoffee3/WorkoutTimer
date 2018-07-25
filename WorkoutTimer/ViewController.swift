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



import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SetNumberDelegate {
    
    
    
    // ******
    // *** MARK: - Variables
    // ******
    
    
    
    let viewWidth = UIScreen.main.bounds.maxX
    
    let keywords = Keywords()
    let workoutModel = Workout()
    
    var currentTimer = Workout.CurrentTimer.interval
    
    var mainTimer = Timer()
    var timerForInterval = Timer()
    var timerForTransition = Timer()
    var timerForProgress = Timer()
    
    var timerIsStarted = false
    
    var isTime = Bool()
    var isInterval = Bool()
    
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
    
    
    
    // ******
    // *** MARK: - IBActions
    // ******
    
    
    
    @IBAction func resetButton(_ sender: UIBarButtonItem) {
        
        resetEverythingAlert()
        
    }
    
    @IBAction func startButton(_ sender: UIButton) {
        
        if !timerIsStarted {
            
            totalSecondsForProgress = (currentTimer == .interval) ? setTotalIntervalSeconds : setTotalTransitionSeconds
            
            mainTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
            
            timerForProgress = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(animateProgress), userInfo: nil, repeats: true)
            
        }
        
        timerIsStarted = true
        
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        
        mainTimer.invalidate()
        
        timerForProgress.invalidate()
        
        timerIsStarted = false
        
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
                
            }
            
            if remainingIntervalSeconds == 0 {
                
                currentTimer = .transition
                
                timerProgress.progress = 0.0
                
                totalSecondsForProgress = setTotalTransitionSeconds
                
                if currentSet == setNumberOfSets {
                    
                    mainTimer.invalidate()
                    
                    timerForProgress.invalidate()
                    
                    resetInfoToStartingSetAmounts()
                    
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
                
            }
            
            if remainingTransitionSeconds == 0 {
                
                currentTimer = .interval
                
                timerProgress.progress = 0.0
                
                totalSecondsForProgress = setTotalIntervalSeconds
                
                currentSet += 1
                
                setCollectionView.reloadData()
                
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
        
    }
    
}



// --------------------------------------------------------------------------------------

extension ViewController {
    
    
    // ******
    // *** MARK: - Alert, Zero, and Reset Functions
    // ******
    
    
    func resetEverythingAlert() {
        
        let alert = UIAlertController(title: "Reset?", message: "This will reset all values.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { (action) in
            
            self.reset()
            
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
        
        setNumberOfSets = 1
        
        setIntervalMinutes = 0
        
        setIntervalSeconds = 0
        
        setTransitionMinutes = 0
        
        setTransitionSeconds = 0
        
        timerProgress.progress = 0.0
        
        resetInfoToStartingSetAmounts()
        
    }
    
    func resetInfoToStartingSetAmounts() {
        
        currentSet = 1
        
        setCollectionView.reloadData()
        
        intervalLabel.text = "\(zero(unit: setIntervalMinutes)):\(zero(unit: setIntervalSeconds))"
        
        transitionLabel.text = "\(zero(unit: setTransitionMinutes)):\(zero(unit: setTransitionSeconds))"
        
        remainingIntervalMinutes = setIntervalMinutes
        
        remainingIntervalSeconds = setIntervalSeconds
        
        remainingTransitionMinutes = setTransitionMinutes
        
        remainingTransitionSeconds = setIntervalSeconds
        
    }
 
    
    
    // ******
    // *** MARK: - Tap Functions
    // ******
    
    

    @objc func setsTap() {
        
        if !timerIsStarted {
            
            isTime = false
            
            performSegue(withIdentifier: keywords.mainToPickerSegue, sender: self)
            
        }
        
    }

    @objc func intervalTap() {
        
        if !timerIsStarted {
            
            isTime = true
            isInterval = true
            
            performSegue(withIdentifier: keywords.mainToPickerSegue, sender: self)
            
        }
        
    }

    @objc func transitionTap() {
        
        if !timerIsStarted {
            
            isTime = true
            isInterval = false
            
            performSegue(withIdentifier: keywords.mainToPickerSegue, sender: self)
            
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
        
        if indexPath.row <= (currentSet - 1) {
            
            cell.backgroundColor = UIColor.green
            cell.setNumberLabel.textColor = UIColor.black

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









