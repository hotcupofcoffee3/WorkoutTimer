//
//  AddRoutineViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/31/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AddRoutineViewController: UIViewController {
    
    
    
    // ******
    // *** MARK: - Variables
    // ******
    
    
    
    let workout = Workout()
    let typeOfViewController = TypeOfViewController.AddRoutine
    var instructions = InstructionItem(type: .AddRoutine)
    
    let keywords = Keywords()
    
    var setRoutineDelegate: SetRoutineDelegate?
    
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
        
        setRoutineDelegate?.settingRoutine(wasCanceled: true)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func setRoutine(_ sender: UIButton) {
        
        if routineNameTextField.text == "" {
            
            return warningLabel.text = "You have to fill in a value for the exercise name."
            
        } else if workout.checkIfNameExists(isNew: isNew, oldRoutineName: routineName, newRoutineName: routineNameTextField.text!) {
            
            warningLabel.text = "A routine already has this name."
            
            return
            
        }
        
        newRoutineName = routineNameTextField.text!
        
        setRoutineDelegate?.settingRoutine(wasCanceled: false)
        
        setRoutineDelegate?.setRoutine(oldName: routineName, newName: newRoutineName, isNew: isNew)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    // ******
    // *** MARK: - Tap Functions
    // ******
    
    
    
    @objc func routineTap() {
        
        routineNameTextField.becomeFirstResponder()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == keywords.addRoutineToInstructionsSegue {
            
            let destinationVC = segue.destination as! InstructionViewController
            
            destinationVC.instructionsWereShownDelegate = self
            
            destinationVC.instructions = instructions.message
            
        }
        
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
    
}



extension AddRoutineViewController: UITextFieldDelegate, InstructionsWereShownDelegate {
    
    func instructionsWereShown() {
        instructions.wereShown = true
        UserDefaults.standard.set(instructions.wereShown, forKey: typeOfViewController.rawValue)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        routineNameTextField.resignFirstResponder()
        self.view.endEditing(true)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        routineNameTextField.endEditing(true)
        
        return true
    }
    
}
