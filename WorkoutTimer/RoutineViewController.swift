//
//  RoutineViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/31/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class RoutineViewController: UIViewController, SetRoutineDelegate, InstructionsWereShownDelegate {
    
    
    
    // ******
    // *** MARK: - Variables
    // ******
    
    
    
    let workout = Workout()
    let typeOfViewController = TypeOfViewController.Routine
    var instructions = InstructionItem(type: .Routine)
    
    
    
    var routineName = String()
    
    var loadRoutineExercisesDelegate: LoadRoutineExercisesDelegate?
    
    var setSetsTransitionsAndRestDelegate: SetSetsTransitionsAndRestDelegate?
    
    
   
    var isNew = Bool()
    
    var newRoutineWasCanceled = false
    
    var editCells = false
    
    
    
    // ******
    // *** MARK: - IBOutlets
    // ******
    
    
    
    @IBOutlet weak var routineTable: UITableView!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    
    
    // ******
    // *** MARK: - IBActions
    // ******
    
    @IBAction func addRoutine(_ sender: UIBarButtonItem) {
        
        if UserDefaults.standard.object(forKey: Keywords.shared.isPurchasedKey) == nil {
            
            InAppPurchaseService.shared.getProducts()
            
            let alert = InAppPurchaseService.shared.inAppPurchaseAlert()
            
            present(alert, animated: true, completion: nil)
            
        } else {
            
            isNew = true
            
            toggleEditAndDoneFunction(edit: false)
            
            performSegue(withIdentifier: Keywords.shared.routineToAddRoutineSegue, sender: self)
            
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
        
        if segue.identifier == Keywords.shared.routinesToInstructionsSegue {
            
            let destinationVC = segue.destination as! InstructionViewController
            
            destinationVC.instructionsWereShownDelegate = self
            
            destinationVC.instructions = instructions.message
            
        } else if segue.identifier == Keywords.shared.routineToAddRoutineSegue {
            
            let destinationVC = segue.destination as! AddRoutineViewController
            
            destinationVC.setRoutineDelegate = self
            
            destinationVC.isNew = isNew
            
            if !isNew {
                
                destinationVC.routineName = routineName
                
            }
            
        }
        
    }
    
    
    
    // ******
    // *** MARK: - Loadables
    // ******
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
       routineTable.register(UINib(nibName: "RoutineTableViewCell", bundle: nil), forCellReuseIdentifier: "routineTableCell")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if isNew && !newRoutineWasCanceled {
            
            loadWorkoutInfoAndReturnToMain(routine: routineName)
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        instructions.presentInstructions {
            self.performSegue(withIdentifier: self.instructions.segueKey, sender: self)
        }
        
    }
    
    
    
    // ******
    // *** MARK: - Functions - Set Routine Variable
    // ******
    

    
    func toggleEditAndDoneFunction(edit: Bool) {
        
        editCells = edit
        
        editButton.title = edit ? "Done" : "Edit"
        
        routineTable.reloadData()
        
    }
    
    func setRoutineVariable(named: String) {
        
        routineName = named
        
    }
    
    func loadWorkoutInfoAndReturnToMain(routine: String) {
        
        workout.saveLastUsedRoutine(routine: routine)
        
        workout.loadExercisesPerRoutine(routine: workout.lastUsedRoutine)
        
        workout.loadWorkoutDataPerRoutine(routine: workout.lastUsedRoutine)
        
        loadRoutineExercisesDelegate?.reloadExercisesPerRoutine()
        
        let workoutArray = workout.getWorkoutInfo(routine: workout.lastUsedRoutine)
        
        setSetsTransitionsAndRestDelegate?.setRest(minutes: Int(workoutArray.restMinutes), seconds: Int(workoutArray.restSeconds))
        
        setSetsTransitionsAndRestDelegate?.setTransition(minutes: Int(workoutArray.transitionMinutes), seconds: Int(workoutArray.transitionSeconds))
        
        setSetsTransitionsAndRestDelegate?.setSets(numberOfSets: Int(workoutArray.sets))
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    // ******
    // *** MARK: - Delegates
    // ******
    
    
    
    func instructionsWereShown() {
        instructions.wereShown = true
        UserDefaults.standard.set(instructions.wereShown, forKey: typeOfViewController.rawValue)
    }
    
    func setRoutine(oldName: String, newName: String, isNew: Bool) {
        
        if !newRoutineWasCanceled {
            
            editCells = false
            
            editButton.title = editCells ? "Done" : "Edit"
            
            setRoutineVariable(named: newName)
            
            if isNew {
                
                workout.saveNewRoutine(routine: newName)
                
            } else {
                
                workout.updateRoutineName(oldName: oldName, newName: newName)
                
            }
            
            workout.loadRoutines()
            
            routineTable.reloadData()
            
        }
    
    }
    
    func settingRoutine(wasCanceled: Bool) {
        
        newRoutineWasCanceled = wasCanceled
        
    }
    
}

    
    
extension RoutineViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        
        routineName = workout.routineArray[indexPath.row]
        
        if editCells {
            
            isNew = false
            
            performSegue(withIdentifier: Keywords.shared.routineToAddRoutineSegue, sender: self)
            
        } else {
            
            loadWorkoutInfoAndReturnToMain(routine: routineName)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            if workout.routineArray.count > 1 {
                
                workout.deleteRoutine(routineToDelete: workout.routineArray[indexPath.row])
                
            } else {
                
                let alert = UIAlertController(title: "Nope!", message: "You have to have at least 1 routine.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
                
                present(alert, animated: true, completion: nil)
                
            }
            
        }
        
        tableView.reloadData()
        
    }
    
}











