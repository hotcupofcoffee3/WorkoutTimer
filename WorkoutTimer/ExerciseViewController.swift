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
    
    var isNew = Bool()
    
    
    
    var delegate: UpdateFirstExerciseDelegate?
    
    
    
    @IBOutlet weak var exerciseTable: UITableView!
    
    @IBAction func addExercise(_ sender: UIBarButtonItem) {
        
        isNew = true
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == keywords.exerciseToPickerSegue {
            
            let destinationVC = segue.destination as! AddExerciseViewController
            
            destinationVC.delegate = self
            
            destinationVC.isNew = isNew
            
            if !isNew {
                
                destinationVC.exerciseName = exerciseName
                
                destinationVC.minutes = exerciseMinutes
                
                destinationVC.seconds = exerciseSeconds
                
            }
            
        }
        
    }
    
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
    
    func setExerciseVariables(named: String, minutes: Int, seconds: Int) {
        
        exerciseName = named
        exerciseMinutes = minutes
        exerciseSeconds = seconds
        
    }
    
    func setExercise(oldName: String, newName: String, minutes: Int, seconds: Int, isNew: Bool) {
        
        setExerciseVariables(named: newName, minutes: minutes, seconds: seconds)
        
        if isNew {
            
            workout.saveNewExercise(named: newName, minutes: minutes, seconds: seconds)
            
        } else {
            
            workout.updateExercise(named: oldName, newName: newName, newMinutes: minutes, newSeconds: seconds)
            
        }
        
        workout.loadExercises()
        
        exerciseTable.reloadData()
        
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
        
        let exercise = workout.exerciseArray[indexPath.row]
        
        setExerciseVariables(named: exercise.name!, minutes: Int(exercise.intervalMinutes), seconds: Int(exercise.intervalSeconds))
        
        isNew = false
        
        performSegue(withIdentifier: keywords.exerciseToPickerSegue, sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            workout.deleteExercise(workout.exerciseArray[indexPath.row])
            
        }
        
        tableView.reloadData()
        
    }
    
}
