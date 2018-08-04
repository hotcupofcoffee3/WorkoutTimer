//
//  RoutineViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/31/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit



// ******
// *** TODO:
// ******







protocol LoadRoutineExercises {
    
    func reloadExercisesPerRoutine()
    
}

class RoutineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SetRoutineDelegate {
    
    
    
    let keywords = Keywords()
    
    let workout = Workout()
    
    
    
    var routineName = String()
    
    var delegate: LoadRoutineExercises?
    
    
   
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
        
        delegate?.reloadExercisesPerRoutine()
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        
        editCells = !editCells
        
        editButton.title = editCells ? "Done" : "Edit"
        
        routineTable.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == keywords.routineToAddRoutineSegue {
            
            let destinationVC = segue.destination as! AddRoutineViewController
            
            destinationVC.delegate = self
            
            destinationVC.isNew = isNew
            
            if !isNew {
                
                destinationVC.routineName = routineName
                
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
    
    func setRoutine(oldName: String, newName: String, isNew: Bool) {
        
        setRoutineVariable(named: newName)
        
        if isNew {
            
            workout.saveNewExercise(named: "Exercise 1", minutes: 0, seconds: 30, routine: newName)
            
        } else {
            
            workout.updateRoutineName(oldName: oldName, newName: newName)
            
        }
        
        workout.loadRoutines()
        
        routineTable.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workout.routineArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routineTableCell") as! RoutineTableViewCell
        
        let currentRoutine = workout.routineArray[indexPath.row]
        
        cell.routineNameLabel.text = "\(currentRoutine)"
        
        cell.accessoryType = editCells ? .disclosureIndicator : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if editCells {
            
            isNew = false
            
            routineName = workout.routineArray[indexPath.row]
            
            performSegue(withIdentifier: keywords.routineToAddRoutineSegue, sender: self)
            
        } else {
            
            workout.saveLastUsedRoutine(routine: workout.routineArray[indexPath.row])

            delegate?.reloadExercisesPerRoutine()

            dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            if workout.routineArray.count > 1 {
                
                workout.deleteRoutine(routineToDelete: workout.routineArray[indexPath.row])
                
                workout.saveLastUsedRoutine(routine: workout.routineArray[0])
                
            } else {
                
                let alert = UIAlertController(title: "Nope!", message: "Cannot delete the last routine.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
                
                present(alert, animated: true, completion: nil)
                
            }
            
        }
        
        tableView.reloadData()
        
    }
    
}











