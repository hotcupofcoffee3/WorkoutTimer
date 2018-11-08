//
//  ExerciseViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class ExerciseViewController: UIViewController, SetExerciseDelegate, LoadRoutineExercisesDelegate, InstructionsWereShownDelegate {
    
    
    
    // ******
    // *** MARK: - Variables
    // ******
    
    
    
    let workout = Workout()
    let timerForWorkout = TimerForWorkout()
    let typeOfViewController = TypeOfViewController.Exercise
    var instructions = InstructionItem(type: .Exercise)
    
    
    
    var exerciseName = String()
    
    var exerciseMinutes = Int()
    
    var exerciseSeconds = Int()
    
    var exerciseReps = Int()
    
    var isNew = Bool()
    
    var isTime = Bool()
    
    var isTwelveExercises = Bool()
    
    var editCells = false
    
    
    
    var loadRoutineExercisesDelegate: LoadRoutineExercisesDelegate?
    
    
    
    // ******
    // *** MARK: - IBOutlets
    // ******
    
    
    
    @IBOutlet weak var exerciseTable: UITableView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var goToRoutinesButton: UIButton!
    
    
    
    // ******
    // *** MARK: - IBActions
    // ******
    
    
    
    @IBAction func goToRoutines(_ sender: UIButton) {
        
        performSegue(withIdentifier: Keywords.shared.exerciseToRoutineSegue, sender: self)
        
    }
    
    @IBAction func addExercise(_ sender: UIBarButtonItem) {
        
        toggleEditAndDoneFunction(edit: false)
        
        if isTwelveExercises {
            
            let alert = UIAlertController(title: "Exercise Limit", message: "You can have a maximum of 12 exercises.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        } else {
            
            isNew = true
            
            performSegue(withIdentifier: Keywords.shared.exerciseToAddExerciseSegue, sender: self)
            
        }

    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        
        loadRoutineExercisesDelegate?.reloadExercisesPerRoutine()
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        
        editCells = !editCells
        
        toggleEditAndDoneFunction(edit: editCells)
        
    }
    
    
    
    // ******
    // *** MARK: - Segue
    // ******
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Keywords.shared.exercisesToInstructionsSegue {
            
            let destinationVC = segue.destination as! InstructionViewController
            
            destinationVC.instructionsWereShownDelegate = self
            
            destinationVC.instructions = instructions.message
            
        } else if segue.identifier == Keywords.shared.exerciseToAddExerciseSegue {
            
            let destinationVC = segue.destination as! AddExerciseViewController
            
            destinationVC.setExerciseDelegate = self
            
            destinationVC.isNew = isNew
            
            if !isNew {
                
                destinationVC.exerciseName = exerciseName
                
                destinationVC.minutes = exerciseMinutes
                
                destinationVC.seconds = exerciseSeconds
                
                destinationVC.reps = exerciseReps
                
                destinationVC.isTime = isTime
                
            } else {
                
                destinationVC.isTime = true
                
                destinationVC.seconds = 30
                
            }
            
        } else if segue.identifier == Keywords.shared.exerciseToRoutineSegue {
            
            let destinationVC = segue.destination as! RoutineViewController
            
            destinationVC.loadRoutineExercisesDelegate = self
            
        }
        
    }
    

    
    // ******
    // *** MARK: - Loadables
    // ******
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        exerciseTable.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "exerciseTableCell")
        
        goToRoutinesButton.setTitle(editCells ? "Edit Routines" : workout.exerciseArray[0].routine!, for: .normal)
        
        toggleIsTwelveExercises()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        instructions.presentInstructions {
            self.performSegue(withIdentifier: self.instructions.segueKey, sender: self)
        }

//        if UserDefaults.standard.object(forKey: typeOfViewController.rawValue) == nil {
//            DispatchQueue.main.asyncAfter(deadline: .now() + instructions.timeBeforeShowing) {
//                self.performSegue(withIdentifier: self.instructions.segueKey, sender: self)
//            }
//        } else {
//            //            UserDefaults.standard.set(nil, forKey: typeOfViewController.rawValue)
//        }
        
    }
    
    
    
    // ******
    // *** MARK: - Functions - Zero, Ten Exercises Check, Toggle Edit & Done, and Set Exercise Variables
    // ******
    
    
    
    func toggleIsTwelveExercises() {
        
        isTwelveExercises = (workout.exerciseArray.count == 12)
        
    }
    
    func toggleEditAndDoneFunction(edit: Bool) {
        
        editCells = edit
        
        editButton.title = edit ? "Done" : "Edit"
        
        exerciseTable.setEditing(edit, animated: true)
        
    }
    
    func setExerciseVariables(named: String, minutes: Int, seconds: Int, reps: Int) {
        
        exerciseName = named
        exerciseMinutes = minutes
        exerciseSeconds = seconds
        exerciseReps = reps
        
    }
    
    
    
    // ******
    // *** MARK: - Delegates
    // ******
    
    
    
    func instructionsWereShown() {
        instructions.wereShown = true
        UserDefaults.standard.set(instructions.wereShown, forKey: typeOfViewController.rawValue)
    }
    
    func setExercise(oldName: String, newName: String, minutes: Int, seconds: Int, reps: Int, isNew: Bool) {
        
        toggleEditAndDoneFunction(edit: false)
        
        setExerciseVariables(named: newName, minutes: minutes, seconds: seconds, reps: reps)
        
        if isNew {
            
            workout.saveNewExercise(named: newName, minutes: minutes, seconds: seconds, routine: workout.lastUsedRoutine, reps: reps)
            
        } else {
            
            workout.updateExercise(named: oldName, newName: newName, newMinutes: minutes, newSeconds: seconds, newReps: reps)
            
        }
        
        workout.loadExercisesPerRoutine(routine: workout.lastUsedRoutine)
        
        toggleIsTwelveExercises()
        
        exerciseTable.reloadData()
        
    }
    
    func reloadExercisesPerRoutine() {
        
        workout.loadLastUsedRoutine()
        
        workout.loadExercisesPerRoutine(routine: workout.lastUsedRoutine)
        
        toggleEditAndDoneFunction(edit: false)
        
        goToRoutinesButton.setTitle(workout.lastUsedRoutine, for: .normal)
        
        exerciseTable.reloadData()
        
    }
    
}
    
    
    
extension ExerciseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workout.exerciseArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseTableCell") as! ExerciseTableViewCell
        
        let currentExercise = workout.exerciseArray[indexPath.row]
        
        cell.exerciseNameLabel.text = "\(currentExercise.name!)"
        
        if currentExercise.reps != 0 {
            
            cell.exerciseTimeLabel.text = (Int(currentExercise.reps) == 1) ? "\(Int(currentExercise.reps)) rep" : "\(Int(currentExercise.reps)) reps"
            
        } else {
            
            cell.exerciseTimeLabel.text = "\(timerForWorkout.zero(unit: Int(currentExercise.intervalMinutes))):\(timerForWorkout.zero(unit: Int(currentExercise.intervalSeconds)))"
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let exercise = workout.exerciseArray[indexPath.row]
        
        setExerciseVariables(named: exercise.name!, minutes: Int(exercise.intervalMinutes), seconds: Int(exercise.intervalSeconds), reps: Int(exercise.reps))
        
        isNew = false
        
        isTime = (exercise.reps == 0)
        
        performSegue(withIdentifier: Keywords.shared.exerciseToAddExerciseSegue, sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            if workout.exerciseArray.count > 1 {
                
                workout.deleteExercise(workout.exerciseArray[indexPath.row])
                
                tableView.deleteRows(at: [indexPath], with: .left)
                
                toggleIsTwelveExercises()
                
            } else {
                
                let alert = UIAlertController(title: "Nope!", message: "You have to have at least 1 exercise.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
                
                present(alert, animated: true, completion: nil)
                
            }
            
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
