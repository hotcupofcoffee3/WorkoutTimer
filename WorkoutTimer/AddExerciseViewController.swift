//
//  AddExerciseViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/23/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//






// Check to see if the "Add exercise" isn't new, and if it isn't, then the comparison to the name doesn't matter if it is the same one that is already set.

// Organize the main exercise page to display the cells, with the fonts and sizes changing based on the number of exercises added.

// Disable the 'Add' button when there are 10 exercises, and have an alert that pops up from the add button that lets you know that you can only add 10 exercises.



// Warning: 255/110/101
// Purple: 146/87/173
// Dark blue background: 44/62/80
// Lighter teal: 22/160/133







import UIKit

protocol SetExerciseDelegate {

    func setExercise(oldName: String, newName: String, minutes: Int, seconds: Int, isNew: Bool)
    
}

class AddExerciseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    let workout = Workout()
    
    var delegate: SetExerciseDelegate?
    
    var exerciseName = String()
    
    var newExerciseName = String()
    
    var minutes = Int()
    
    var seconds = Int()
    
    var isNew = Bool()
    
    var pickerMinutesAndSeconds = Array(0...59)
    
    @IBOutlet weak var exerciseNameView: UIView!
    
    @IBOutlet weak var exerciseNameTextField: UITextField!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var chosenPickerInfoLabel: UILabel!
    
    @IBOutlet weak var numberPicker: UIPickerView!
    
    @IBOutlet weak var minLabel: UILabel!
    
    @IBOutlet weak var secLabel: UILabel!
    
    @IBAction func cancel(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func setExercise(_ sender: UIButton) {
        
        if exerciseNameTextField.text == "" {
            
            return warningLabel.text = "You have to fill in a value for the exercise name."
            
//             return
            
        } else if checkIfNameExists(exerciseName: exerciseNameTextField.text!) {
            
            warningLabel.text = "An exercise already exists with this name."
            
            return
            
        }
        
        newExerciseName = exerciseNameTextField.text!
        
        delegate?.setExercise(oldName: exerciseName, newName: newExerciseName, minutes: minutes, seconds: seconds, isNew: isNew)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func checkIfNameExists(exerciseName: String) -> Bool {
        
        var isSame = false
        
        for exercise in workout.exerciseArray {
            
            if exercise.name!.lowercased() == exerciseName.lowercased() {
                
                warningLabel.text = "An exercise already has this name."
                
                isSame = true
                
            }
            
        }
        
        return isSame
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exerciseNameTextField.text = "\(exerciseName)"
        
        warningLabel.text = ""

        numberPicker.selectRow(minutes, inComponent: 0, animated: true)
        
        numberPicker.selectRow(seconds, inComponent: 1, animated: true)
        
        minLabel.text = "min"
        secLabel.text = "sec"
        
        chosenPickerInfoLabel.text = "\(zero(unit: minutes))\(minutes):\(zero(unit: seconds))\(seconds)"

    }
    
    func zero(unit: Int) -> String {
        
        var zero = ""
        
        if unit <= 9 {
            
            zero = "0"
            
        }
        
        return zero
        
    }
    
}



extension AddExerciseViewController {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 2
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerMinutesAndSeconds.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleString = "\(row)"
        let title = NSAttributedString(string: titleString, attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if component == 0 {

            minutes = row

        } else if component == 1 {

            seconds = row

        }

        chosenPickerInfoLabel.text = "\(zero(unit: minutes))\(minutes):\(zero(unit: seconds))\(seconds)"
            
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        exerciseNameTextField.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        exerciseNameTextField.endEditing(true)
        
        return true
    }
    
}











