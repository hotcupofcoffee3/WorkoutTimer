//
//  AddRoutineViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/31/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

protocol SetRoutineDelegate {
    
    func setRoutine(oldName: String, newName: String, isNew: Bool)
    
}

class AddRoutineViewController: UIViewController, UITextFieldDelegate {
    
    
    
    // ******
    // *** MARK: - Variables
    // ******
    
    
    
    let workout = Workout()
    
    var delegate: SetRoutineDelegate?
    
    var routineName = String()
    
    var newRoutineName = String()
    
    var isNew = Bool()
    
    
    
    // ******
    // *** MARK: - IBOutlets
    // ******
    
    
    
    @IBOutlet weak var routineNameView: UIView!
    
    @IBOutlet weak var routineNameTextField: UITextField!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    
    
    // ******
    // *** MARK: - IBActions
    // ******
    
    
    
    @IBAction func cancel(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func setRoutine(_ sender: UIButton) {
        
        if routineNameTextField.text == "" {
            
            return warningLabel.text = "You have to fill in a value for the exercise name."
            
            //             return
            
        } else if checkIfNameExists(newRoutineName: routineNameTextField.text!) {
            
            warningLabel.text = "An exercise already exists with this name."
            
            return
            
        }
        
        newRoutineName = routineNameTextField.text!
        
        delegate?.setRoutine(oldName: routineName, newName: newRoutineName, isNew: isNew)
        
        dismiss(animated: true, completion: nil)
        
    }
    

    
    // ******
    // *** MARK: - Loadables
    // ******
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        routineNameTextField.text = "\(routineName)"
        
        warningLabel.text = ""
        
        routineNameTextField.delegate = self
        
        let routineViewTap = UITapGestureRecognizer(target: self, action: #selector(routineTap))
        routineNameView.addGestureRecognizer(routineViewTap)
        
    }
    
}



extension AddRoutineViewController {
    
    
    
    // ******
    // *** MARK: - Functions - Check if Routine Already Exists
    // ******
    
    
    
    func checkIfNameExists(newRoutineName: String) -> Bool {
        
        var isSame = false
        
        for routine in workout.routineArray {
            
            if !isNew && routine.lowercased() == routineName.lowercased() {
                
                continue
                
            } else {
                
                if routine.lowercased() == newRoutineName.lowercased() {
                    
                    warningLabel.text = "A routine already has this name."
                    
                    isSame = true
                    
                }
                
            }
            
        }
        
        return isSame
        
    }
    
    
    
    // ******
    // *** MARK: - Tap Functions
    // ******
    
    
    
    @objc func routineTap() {
        
        routineNameTextField.becomeFirstResponder()
        
    }
    
    
    
    // ******
    // *** MARK: - TextField Delegates
    // ******
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        routineNameTextField.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        routineNameTextField.endEditing(true)
        
        return true
    }
    
}
