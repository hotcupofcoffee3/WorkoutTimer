//
//  ExerciseViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

protocol UpdateFirstExerciseDelegate {
    
    func updateFirstExercise(withExercise: Exercise)
    
}

class ExerciseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SetExerciseDelegate {
    
    let keywords = Keywords()
    
    let workout = Workout()
    
    var exerciseName = String()
    
    var exerciseMinutes = Int()
    
    var exerciseSeconds = Int()
    
    var delegate: UpdateFirstExerciseDelegate?
    
    @IBOutlet weak var exerciseTable: UITableView!
    
    @IBAction func addExercise(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: keywords.exerciseToPickerSegue, sender: self)
        
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        
        delegate?.updateFirstExercise(withExercise: workout.exerciseArray[0])
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func setExercise(named: String, minutes: Int, seconds: Int) {
        
        exerciseName = named
        exerciseMinutes = minutes
        exerciseSeconds = seconds
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if segue.identifier == keywords.exerciseToPickerSegue {
//            
//            let destinationVC = segue.destination as! AddExerciseViewController
//            
//            destinationVC.isTime = isTime
//            
//            destinationVC.isInterval = isInterval
//            
//            destinationVC.delegate = self
//            
//            if isTime {
//                
//                if isInterval {
//                    
//                    destinationVC.minutes = workout.setIntervalMinutes
//                    
//                    destinationVC.seconds = workout.setIntervalSeconds
//                    
//                } else if !isInterval {
//                    
//                    destinationVC.minutes = workout.setTransitionMinutes
//                    
//                    destinationVC.seconds = workout.setTransitionSeconds
//                    
//                }
//                
//            } else if !isTime {
//                
//                destinationVC.numberOfSets = workout.setNumberOfSets
//                
//            }
//            
//        } else if segue.identifier == keywords.mainToSetsSegue {
//            
//            
//            
//        }
//        
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ExerciseViewController {
    
    func setTime(minutes: Int, seconds: Int) {
        
//        workout.setIntervalMinutes = minutes
//
//        workout.setIntervalSeconds = seconds
       
        workout.remainingIntervalMinutes = minutes
        
        workout.remainingIntervalSeconds = seconds
        
        workout.setTotalIntervalSeconds = (minutes * 60) + seconds
        
//        intervalLabel.text = "\(zero(unit: workout.setIntervalMinutes)):\(zero(unit: workout.setIntervalSeconds))"
//
//        transitionLabel.text = "\(zero(unit: workout.setTransitionMinutes)):\(zero(unit: workout.setTransitionSeconds))"
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
}
