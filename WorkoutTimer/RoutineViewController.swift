//
//  RoutineViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/31/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class RoutineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    let keywords = Keywords()
    
    let workout = Workout()
    
    
    
    var exerciseName = String()
    
    var exerciseMinutes = Int()
    
    var exerciseSeconds = Int()
    
    var isNew = Bool()
    
    var isTenExercises = Bool()
    
    var editCells = false
    
    
    
    var delegate: UpdateFirstExerciseDelegate?
    
    
    
    @IBOutlet weak var exerciseTable: UITableView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func addExercise(_ sender: UIBarButtonItem) {
        
        if isTenExercises {
            
            let alert = UIAlertController(title: "Exercise Limit", message: "You can have a maximum of 10 exercises.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        } else {
            
            isNew = true
            
            performSegue(withIdentifier: keywords.exerciseToPickerSegue, sender: self)
            
        }
        
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        
        delegate?.updateFirstExercise(withExercise: workout.exerciseArray[0])
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        
        editCells = !editCells
        
        editButton.title = editCells ? "Done" : "Edit"
        
        exerciseTable.setEditing(editCells, animated: true)
        
        exerciseTable.reloadData()
        
    }
    
    func zero(unit: Int) -> String {
        
        var zero = "\(unit)"
        
        if unit <= 9 {
            
            zero = "0\(unit)"
            
        }
        
        return zero
        
    }
    
    func toggleIsTenExercises() {
        
        isTenExercises = (workout.exerciseArray.count == 10)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == keywords.exerciseToPickerSegue {
            
            let destinationVC = segue.destination as! AddExerciseViewController
            
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
        
        toggleIsTenExercises()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension RoutineViewController {
    
    func setExerciseVariables(named: String, minutes: Int, seconds: Int) {
        
        exerciseName = named
        exerciseMinutes = minutes
        exerciseSeconds = seconds
        
    }
    
    func setExercise(oldName: String, newName: String, minutes: Int, seconds: Int, isNew: Bool) {
        
        setExerciseVariables(named: newName, minutes: minutes, seconds: seconds)
        
        if isNew {
            
            workout.saveNewExercise(named: newName, minutes: minutes, seconds: seconds, routine: "Default")
            
        } else {
            
            workout.updateExercise(named: oldName, newName: newName, newMinutes: minutes, newSeconds: seconds)
            
        }
        
        workout.loadExercisesPerRoutine(routine: "Default")
        
        toggleIsTenExercises()
        
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
        return 42
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
            
            toggleIsTenExercises()
            
        }
        
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return editCells
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let selectedExercise = workout.exerciseArray[sourceIndexPath.row]
        
        workout.exerciseArray.remove(at: sourceIndexPath.row)
        
        workout.exerciseArray.insert(selectedExercise, at: destinationIndexPath.row)
        
        workout.updateOrderNumbers()
        
        tableView.reloadData()
        
    }
    
}
