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

// Set the delegate to take on the collection view amount of cells based on the chosen number from the Time and Number VC.
// Set up the timer to run based on the minutes and seconds.
// Set up the progress bar to go across based on the amount of time left based on the number of seconds times the number of minutes, which means a new variable that totals the total interval seconds and total transition seconds.
// Alternate between the two, of interval and transition, for the progress bar.









import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SetNumberDelegate {
    
    let viewWidth = UIScreen.main.bounds.maxX
    
    let keywords = Keywords()
    
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
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBAction func resetButton(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: keywords.mainToPickerSegue, sender: self)
        
    }
    
    @IBOutlet weak var setCollectionView: UICollectionView!
    
    @IBOutlet weak var timerProgress: UIProgressView!
    
    @IBOutlet weak var intervalView: UIView!
    
    @IBOutlet weak var intervalLabel: UILabel!
    
    @IBOutlet weak var transitionView: UIView!
    
    @IBOutlet weak var transitionLabel: UILabel!
    
    @IBAction func startButton(_ sender: UIButton) {
        
        if !timerIsStarted {
        
            timerForProgress = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(animateProgress), userInfo: nil, repeats: true)
            
            timerForInterval = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(intervalTimer), userInfo: nil, repeats: true)
            
            timerForTransition = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(transitionTimer), userInfo: nil, repeats: true)
            
        }
        
        timerIsStarted = true
        
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        
        timerForProgress.invalidate()
        
        timerForInterval.invalidate()
        
        timerIsStarted = false
        
    }
    
    @objc func intervalTimer() {
        
        print("Dog")
        
    }
    
    @objc func transitionTimer() {
        
        print("Cat")
        
    }
    
    @objc func animateProgress() {
        
        timerProgress.setProgress(timerProgress.progress + 0.0005, animated: true)
        
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









