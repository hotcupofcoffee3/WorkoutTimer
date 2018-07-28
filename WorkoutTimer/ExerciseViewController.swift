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
    
    func zero(unit: Int) -> String {
        
        var zero = "\(unit)"
        
        if unit <= 9 {
            
            zero = "0\(unit)"
            
        }
        
        return zero
        
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
        
        exerciseTable.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "exerciseTableCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ExerciseViewController {
    
    func setExercise(named: String, minutes: Int, seconds: Int) {
        
        exerciseName = named
        exerciseMinutes = minutes
        exerciseSeconds = seconds
        
    }
    
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
        return workout.exerciseArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseTableCell") as! ExerciseTableViewCell
        
        let currentExercise = workout.exerciseArray[indexPath.row]
        
        cell.exerciseNameLabel.text = "\(currentExercise.name!)"
        
        cell.exerciseTimeLabel.text = "\(zero(unit: Int(currentExercise.intervalMinutes))):\(zero(unit: Int(currentExercise.intervalSeconds)))"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: keywords.exerciseToPickerSegue, sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            workout.deleteExercise(workout.exerciseArray[indexPath.row])
            
        }
        
    }
    
}