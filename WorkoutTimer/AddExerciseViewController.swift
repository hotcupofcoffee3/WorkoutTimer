//
//  AddExerciseViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/23/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

protocol SetExerciseDelegate {

    func setExercise(named: String, minutes: Int, seconds: Int)
    
}

class AddExerciseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var delegate: SetExerciseDelegate?
    
    var exerciseName = String()
    
    var minutes = Int()
    
    var seconds = Int()
    
    var pickerMinutesAndSeconds = Array(0...59)
    
    @IBOutlet weak var exerciseNameView: UIView!
    
    @IBOutlet weak var exerciseNameTextField: UITextField!
    
    @IBOutlet weak var chosenPickerInfoLabel: UILabel!
    
    @IBOutlet weak var numberPicker: UIPickerView!
    
    @IBOutlet weak var minLabel: UILabel!
    
    @IBOutlet weak var secLabel: UILabel!
    
    @IBAction func setNumberButton(_ sender: UIButton) {
        
        delegate?.setExercise(named: exerciseName, minutes: minutes, seconds: seconds)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
}











