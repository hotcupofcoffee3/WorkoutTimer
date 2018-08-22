//
//  AddExerciseViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/23/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AddExerciseViewController: UIViewController {
    
    
    
    // ******
    // *** MARK: - Variables
    // ******
    
    
    
    let workout = Workout()
    
    let timerForWorkout = TimerForWorkout()
    
    var setExerciseDelegate: SetExerciseDelegate?
    
    var exerciseName = String()
    
    var newExerciseName = String()
    
    var isTime = Bool()
    
    var minutes = Int()
    
    var seconds = Int()
    
    var reps = Int()
    
    var isNew = Bool()
    
    let maxReps = 30
    
    let pickerMinutesAndSeconds = Array(0...59)
    
    
    
    // ******
    // *** MARK: - IBOutlets
    // ******
    
    
    
    @IBOutlet weak var exerciseNameView: UIView!
    
    @IBOutlet weak var exerciseNameTextField: UITextField!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var timeOrRepSegment: UISegmentedControl!
    
    @IBOutlet weak var chosenPickerInfoLabel: UILabel!
    
    @IBOutlet weak var numberPicker: UIPickerView!
    
    @IBOutlet weak var minLabel: UILabel!
    
    @IBOutlet weak var secLabel: UILabel!
    
    
    
    // ******
    // *** MARK: - IBActions
    // ******
    
    
    
    @IBAction func cancel(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func toggleTimeOrRepsSegment(_ sender: UISegmentedControl) {
        
        isTime = (sender.selectedSegmentIndex == 0)
        
        toggleMinAndSecLabels()
        
        chosenPickerInfoLabel.text = isTime ? "\(timerForWorkout.zero(unit: minutes)):\(timerForWorkout.zero(unit: seconds))" : "\(reps)"
        
        numberPicker.reloadAllComponents()
        
        if isTime {
            
            numberPicker.selectRow(minutes, inComponent: 0, animated: true)
            numberPicker.selectRow(seconds, inComponent: 1, animated: true)
            
        } else {
            
            numberPicker.selectRow(reps, inComponent: 0, animated: true)
            
        }
        
    }
    
    @IBAction func setExercise(_ sender: UIButton) {
        
        if exerciseNameTextField.text == "" {
            
            return warningLabel.text = "You have to fill in a value for the exercise name."
            
        } else if workout.checkIfNameExists(isNew: isNew, oldExerciseName: exerciseName, newExerciseName: exerciseNameTextField.text!) {
            
            return warningLabel.text = "An exercise already exists with this name."
            
        } else if isTime && minutes == 0 && seconds == 0 {
       
            return warningLabel.text = "The time cannot be set to 00:00."
            
        } else if !isTime && reps == 0 {
            
            return warningLabel.text = "Reps cannot be set to 0."
            
        }
        
        newExerciseName = exerciseNameTextField.text!
        
        if isTime {
            
            setExerciseDelegate?.setExercise(oldName: exerciseName, newName: newExerciseName, minutes: minutes, seconds: seconds, reps: 0, isNew: isNew)
            
        } else {
            
            setExerciseDelegate?.setExercise(oldName: exerciseName, newName: newExerciseName, minutes: 0, seconds: 0, reps: reps, isNew: isNew)
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    // ******
    // *** MARK: - Functions
    // ******
    
    
    
    @objc func exerciseTap() {

        exerciseNameTextField.becomeFirstResponder()

    }
    
    func toggleMinAndSecLabels() {
        
        if isTime {
            
            minLabel.text = "min"
            secLabel.text = "sec"
            
        } else {
            
            minLabel.text = ""
            secLabel.text = ""
            
        }
        
    }

    
    
    // ******
    // *** MARK: - Loadables
    // ******
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exerciseNameTextField.text = "\(exerciseName)"
        
        warningLabel.text = ""
        
        if isTime {
            
            timeOrRepSegment.selectedSegmentIndex = 0
            numberPicker.selectRow(minutes, inComponent: 0, animated: true)
            numberPicker.selectRow(seconds, inComponent: 1, animated: true)
            
        } else {
            
            timeOrRepSegment.selectedSegmentIndex = 1
            numberPicker.selectRow(reps, inComponent: 0, animated: true)
            
        }
        
        toggleMinAndSecLabels()
        
        chosenPickerInfoLabel.text = isTime ? "\(timerForWorkout.zero(unit: minutes)):\(timerForWorkout.zero(unit: seconds))" : "\(reps)"
        
        exerciseNameTextField.delegate = self
        
        let exerciseViewTap = UITapGestureRecognizer(target: self, action: #selector(exerciseTap))
        
        exerciseNameView.addGestureRecognizer(exerciseViewTap)

    }
    
}



extension AddExerciseViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return isTime ? 2 : 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return isTime ? pickerMinutesAndSeconds.count : maxReps
        
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleString = "\(row)"
        let title = NSAttributedString(string: titleString, attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if isTime {
            
            if component == 0 {
                
                minutes = row
                
            } else if component == 1 {
                
                seconds = row
                
            }
            
            chosenPickerInfoLabel.text = "\(timerForWorkout.zero(unit: minutes)):\(timerForWorkout.zero(unit: seconds))"
            
        } else {
            
            reps = row
            
            chosenPickerInfoLabel.text = "\(reps)"
            
        }
        
    }
    
}



extension AddExerciseViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        exerciseNameTextField.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        exerciseNameTextField.endEditing(true)
        
        return true
    }
    
}











