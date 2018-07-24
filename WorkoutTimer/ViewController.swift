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

// Set up the timer to run based on the minutes and seconds.
// Set up the progress bar to go across based on the amount of time left based on the number of seconds times the number of minutes, which means a new variable that totals the total interval seconds and total transition seconds.
// Alternate between the two, of interval and transition, for the progress bar.









import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SetNumberDelegate {
    
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
    
    var totalSecondsForProgress = 10
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBAction func resetButton(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Reset everything?", message: "This will reset all values.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { (action) in
            
            self.reset()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    func reset() {
        
        setNumberOfSets = 1
        
        currentSet = 1
        
        setIntervalMinutes = 0
        
        setIntervalSeconds = 0
        
        setTransitionMinutes = 0
        
        setTransitionSeconds = 0
        
    }
    
    @objc func runTimer() {
        
        if currentTimer == .interval {
            
            intervalTimer()
            
        } else if currentTimer == .transition {
            
            transitionTimer()
            
        }
        
    }
    
    @IBOutlet weak var setCollectionView: UICollectionView!
    
    @IBOutlet weak var timerProgress: UIProgressView!
    
    @IBOutlet weak var intervalView: UIView!
    
    @IBOutlet weak var intervalLabel: UILabel!
    
    @IBOutlet weak var transitionView: UIView!
    
    @IBOutlet weak var transitionLabel: UILabel!
    
    @IBAction func startButton(_ sender: UIButton) {
        
        if !timerIsStarted {
            
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
    
    func intervalTimer() {
        
        if setIntervalMinutes > 0 {
            
            if setIntervalSeconds > 0 {
                
                setIntervalSeconds -= 1
                
            } else {
                
                setIntervalMinutes -= 1
                
                setIntervalSeconds = 59
                
            }
            
        } else if setIntervalMinutes == 0 {
            
            if setIntervalSeconds > 0 {
                
                setIntervalSeconds -= 1
                
            } else {
                
                timerForInterval.invalidate()
                
                currentTimer = .transition
                
            }
            
        }
        
    }
    
    func transitionTimer() {
        
        if setTransitionMinutes > 0 {
            
            if setTransitionSeconds > 0 {
                
                setTransitionSeconds -= 1
                
            } else {
                
                setTransitionMinutes -= 1
                
                setTransitionSeconds = 59
                
            }
            
        } else if setTransitionMinutes == 0 {
            
            if setTransitionSeconds > 0 {
                
                setTransitionSeconds -= 1
                
            } else {
                
                timerForTransition.invalidate()
                
                currentTimer = .interval
                
            }
            
        }
        
    }
    
    @objc func animateProgress() {
        
        let increment: Float = (1 / (Float(totalSecondsForProgress) * 10))
        
        timerProgress.setProgress(timerProgress.progress + increment, animated: true)
        
    }
    
    @objc func setsTap() {
        
        isTime = false
        
        performSegue(withIdentifier: keywords.mainToPickerSegue, sender: self)
        
    }
    
    @objc func intervalTap() {
        
        isTime = true
        isInterval = true
        
        performSegue(withIdentifier: keywords.mainToPickerSegue, sender: self)
        
    }
    
    @objc func transitionTap() {
        
        isTime = true
        isInterval = false
        
        performSegue(withIdentifier: keywords.mainToPickerSegue, sender: self)
        
    }
    
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
        
        intervalLabel.text = "\(zero(unit: setIntervalMinutes))\(setIntervalMinutes):\(zero(unit: setIntervalSeconds))\(setIntervalSeconds)"
        
        transitionLabel.text = "\(zero(unit: setTransitionMinutes))\(setTransitionMinutes):\(zero(unit: setTransitionSeconds))\(setTransitionSeconds)"
        
        timerProgress.progress = 0.0
        
    }
    
    func zero(unit: Int) -> String {
        
        var zero = ""
        
        if unit <= 9 {
            
            zero = "0"
            
        }
        
        return zero
        
    }

}



// Delegates

extension ViewController {
    
    func setSets(numberOfSets: Int) {
        
        setNumberOfSets = numberOfSets
        
        setCollectionView.reloadData()
        
    }
    
    func setTime(minutes: Int, seconds: Int) {
        
        if isInterval {
            
            setIntervalMinutes = minutes
            
            setIntervalSeconds = seconds
            
        } else if !isInterval {
            
            setTransitionMinutes = minutes
            
            setTransitionSeconds = seconds
            
        }
        
        intervalLabel.text = "\(zero(unit: setIntervalMinutes))\(setIntervalMinutes):\(zero(unit: setIntervalSeconds))\(setIntervalSeconds)"
        
        transitionLabel.text = "\(zero(unit: setTransitionMinutes))\(setTransitionMinutes):\(zero(unit: setTransitionSeconds))\(setTransitionSeconds)"
        
    }
    
}



// Collection View

extension ViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return setNumberOfSets
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "setCell", for: indexPath) as! SetsCollectionViewCell
        
        cell.setNumberLabel.text = "\(indexPath.row + 1)"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = viewWidth / CGFloat(setNumberOfSets)
        
        return CGSize(width: size, height: 50)
        
    }
    
}









