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
    
    var minutes = Int()
    
    var seconds = Int()
    
    var isNew = Bool()
    
    var pickerMinutesAndSeconds = Array(0...59)
    
    
    
    // ******
    // *** MARK: - IBOutlets
    // ******
    
    
    
    @IBOutlet weak var exerciseNameView: UIView!
    
    @IBOutlet weak var exerciseNameTextField: UITextField!
    
    @IBOutlet weak var warningLabel: UILabel!
    
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
    
    @IBAction func setExercise(_ sender: UIButton) {
        
        if exerciseNameTextField.text == "" {
            
            return warningLabel.text = "You have to fill in a value for the exercise name."
            
//             return
            
        } else if workout.checkIfNameExists(isNew: isNew, oldExerciseName: exerciseName, newExerciseName: exerciseNameTextField.text!) {
            
            warningLabel.text = "An exercise already exists with this name."
            
            return
            
        } else if minutes == 0 && seconds == 0 {
            
            warningLabel.text = "The time cannot be set to 00:00."
            
            return
            
        }
        
        newExerciseName = exerciseNameTextField.text!
        
        setExerciseDelegate?.setExercise(oldName: exerciseName, newName: newExerciseName, minutes: minutes, seconds: seconds, isNew: isNew)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    // ******
    // *** MARK: - Tap Functions
    // ******
    
    
    
    @objc func exerciseTap() {
        
        exerciseNameTextField.becomeFirstResponder()
        
    }

    
    
    // ******
    // *** MARK: - Loadables
    // ******
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exerciseNameTextField.text = "\(exerciseName)"
        
        warningLabel.text = ""

        numberPicker.selectRow(minutes, inComponent: 0, animated: true)
        
        numberPicker.selectRow(seconds, inComponent: 1, animated: true)
        
        minLabel.text = "min"
        secLabel.text = "sec"
        
        chosenPickerInfoLabel.text = "\(timerForWorkout.zero(unit: minutes)):\(timerForWorkout.zero(unit: seconds))"
        
        exerciseNameTextField.delegate = self
        
        let exerciseViewTap = UITapGestureRecognizer(target: self, action: #selector(exerciseTap))
        exerciseNameView.addGestureRecognizer(exerciseViewTap)

    }
    
}



extension AddExerciseViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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

        chosenPickerInfoLabel.text = "\(timerForWorkout.zero(unit: minutes)):\(timerForWorkout.zero(unit: seconds))"
            
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











