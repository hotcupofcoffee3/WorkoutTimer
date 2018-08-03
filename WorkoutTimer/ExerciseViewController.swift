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

class ExerciseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SetExerciseDelegate, LoadRoutineExercises {
    
    
    
    let keywords = Keywords()
    
    let workout = Workout()
    
    
    
    var exerciseName = String()
    
    var exerciseMinutes = Int()
    
    var exerciseSeconds = Int()
    
    var isNew = Bool()
    
    var isTenExercises = Bool()
    
    var editCells = false
    
    
    
    var delegate: UpdateFirstExerciseDelegate?
    
    var delegate2: LoadRoutineExercises?
    
    
    
    @IBOutlet weak var exerciseTable: UITableView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var goToRoutinesButton: UIButton!
    
    @IBAction func goToRoutines(_ sender: UIButton) {
        
        performSegue(withIdentifier: keywords.exerciseToRoutineSegue, sender: self)
        
    }
    
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
        
        delegate2?.reloadExercisesPerRoutine()
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        
        toggleEditAndDoneFunction(edit: true)
        
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
    
    func toggleEditAndDoneFunction(edit: Bool) {
        
        editCells = edit
        
        editButton.title = edit ? "Done" : "Edit"
        
        goToRoutinesButton.setTitle(edit ? "Edit Routines" : workout.exerciseArray[0].routine!, for: .normal)
        
        exerciseTable.setEditing(edit, animated: true)
        
        exerciseTable.reloadData()
        
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
            
        } else if segue.identifier == keywords.exerciseToRoutineSegue {
            
            let destinationVC = segue.destination as! RoutineViewController
            
            destinationVC.delegate = self
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        workout.loadExercisesPerRoutine(routine: workout.lastUsedRoutine)
        
        exerciseTable.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "exerciseTableCell")
        
        goToRoutinesButton.setTitle(editCells ? "Edit Routines" : workout.exerciseArray[0].routine!, for: .normal)
        
        toggleIsTenExercises()
        
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
        
        toggleEditAndDoneFunction(edit: false)
        
        setExerciseVariables(named: newName, minutes: minutes, seconds: seconds)
        
        if isNew {
            
            workout.saveNewExercise(named: newName, minutes: minutes, seconds: seconds, routine: workout.lastUsedRoutine)
            
        } else {
            
            workout.updateExercise(named: oldName, newName: newName, newMinutes: minutes, newSeconds: seconds)
            
        }
        
        workout.loadExercisesPerRoutine(routine: workout.lastUsedRoutine)
        
        toggleIsTenExercises()
        
        exerciseTable.reloadData()
        
    }
    
    func reloadExercisesPerRoutine() {
        
        workout.loadLastUsedRoutine()
        
        workout.loadExercisesPerRoutine(routine: workout.lastUsedRoutine)
        
        toggleEditAndDoneFunction(edit: false)
        
        goToRoutinesButton.setTitle(workout.lastUsedRoutine, for: .normal)
        
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
