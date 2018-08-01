//
//  RoutineViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/31/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class RoutineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SetRoutineDelegate {
    
    
    
    let keywords = Keywords()
    
    let workout = Workout()
    
    
    
    var routineName = String()
    
    
   
    var isNew = Bool()
    
    var editCells = false
    
    
    
    @IBOutlet weak var routineTable: UITableView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func addRoutine(_ sender: UIBarButtonItem) {
        
        isNew = true
        
        performSegue(withIdentifier: keywords.routineToAddRoutineSegue, sender: self)
        
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        
        editCells = !editCells
        
        editButton.title = editCells ? "Done" : "Edit"
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == keywords.routineToAddRoutineSegue {
            
            let destinationVC = segue.destination as! AddRoutineViewController
            
            destinationVC.isNew = isNew
            
            if !isNew {
                
                
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
       routineTable.register(UINib(nibName: "RoutineTableViewCell", bundle: nil), forCellReuseIdentifier: "routineTableCell")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



extension RoutineViewController {
    
    func setRoutineVariable(named: String) {
        
        routineName = named
        
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
        return workout.routineArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routineTableCell") as! RoutineTableViewCell
        
        let currentRoutine = workout.routineArray[indexPath.row]
        
        cell.routineNameLabel.text = "\(currentRoutine)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let routine = workout.routineArray[indexPath.row]
        
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
