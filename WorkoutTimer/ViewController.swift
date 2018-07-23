//
//  ViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/23/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SetNumberDelegate {
    
    let keywords = Keywords()
    
    let timer = Timer()
    
    var isTime = Bool()
    
    var isInterval = Bool()
    
    var setNumberOfSets = 1
    
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
        
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
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
            
            print(isTime)
            
            destinationVC.isTime = isTime
            
            destinationVC.isInterval = isInterval
            
            destinationVC.delegate = self
            
            if isTime {
                
                if isInterval {
                    
                    destinationVC.minutes = setIntervalMinutes
                    
                    destinationVC.seconds = setTransitionSeconds
                    
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}



// Delegates

extension ViewController {
    
    func setSets(numberOfSets: Int) {
        
        setNumberOfSets = numberOfSets
        
    }
    
    func setTime(minutes: Int, seconds: Int) {
        
        if isInterval {
            
            setIntervalMinutes = minutes
            
            setIntervalSeconds = seconds
            
        } else if !isInterval {
            
            setTransitionMinutes = minutes
            
            setTransitionSeconds = seconds
            
        }
        
    }
    
}



// Collection View

extension ViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "setCell", for: indexPath) as! SetsCollectionViewCell
        
        cell.setNumberLabel.text = "\(indexPath.row + 1)"
        
        return cell
    }
    
}

