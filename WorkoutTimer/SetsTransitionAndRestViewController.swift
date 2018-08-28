//
//  SetsTranstionAndRestViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class SetsTransitionAndRestViewController: UIViewController, InstructionsWereShownDelegate {
    
    
    
    // ******
    // *** MARK: - Variables
    // ******
    
    
    
    let timerForWorkout = TimerForWorkout()
    let typeOfViewController = TypeOfViewController.SetsTransitionAndRest
    var instructions = InstructionItem(type: .SetsTransitionAndRest)
    
    let keywords = Keywords()
    
    var setSetsTransitionsAndRestDelegate: SetSetsTransitionsAndRestDelegate?
    
    var isTime = Bool()
    
    var isTransition = Bool()
    
    let maxNumberOfSets = 10
    
    var numberOfSets = Int()
    
    var minutes = Int()
    
    var seconds = Int()
    
    let pickerMinutesAndSeconds = Array(0...59)
    
    
    
    // ******
    // *** MARK: - IBOutlets
    // ******
    
    
    
    @IBOutlet weak var chosenPickerInfoTitle: UILabel!
    
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
    
    @IBAction func setNumberButton(_ sender: UIButton) {
        
        if isTime && isTransition {
            
            setSetsTransitionsAndRestDelegate?.setTransition(minutes: minutes, seconds: seconds)
            
        } else if isTime && !isTransition {
            
            setSetsTransitionsAndRestDelegate?.setRest(minutes: minutes, seconds: seconds)
            
        } else {
            
            setSetsTransitionsAndRestDelegate?.setSets(numberOfSets: numberOfSets)
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == keywords.setsTransitionAndRestToInstructionsSegue {
            
            let destinationVC = segue.destination as! InstructionViewController
            
            destinationVC.instructionsWereShownDelegate = self
            
            destinationVC.instructions = instructions.message
            
        }
        
    }
    
    func instructionsWereShown() {
        instructions.wereShown = true
        UserDefaults.standard.set(instructions.wereShown, forKey: typeOfViewController.rawValue)
    }
    
    
    
    // ******
    // *** MARK: - Loadables
    // ******
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isTime {
            
            numberPicker.selectRow(minutes, inComponent: 0, animated: true)
            
            numberPicker.selectRow(seconds, inComponent: 1, animated: true)
            
            minLabel.text = "min"
            secLabel.text = "sec"
            
            chosenPickerInfoTitle.text = isTransition ? "Transition Time" : "Rest Time"
            
        } else {
            
            numberPicker.selectRow(numberOfSets - 1, inComponent: 0, animated: true)
            
            minLabel.text = ""
            secLabel.text = ""
            
            chosenPickerInfoTitle.text = "Number of Sets"
            
        }
        
        chosenPickerInfoLabel.text = isTime ? "\(timerForWorkout.zero(unit: minutes)):\(timerForWorkout.zero(unit: seconds))" : "\(numberOfSets)"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if UserDefaults.standard.object(forKey: typeOfViewController.rawValue) == nil {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                self.performSegue(withIdentifier: self.instructions.segueKey, sender: self)
                
            }
            
        } else {
            
            //            UserDefaults.standard.set(nil, forKey: typeOfViewController.rawValue)
            
        }
        
    }
    
}



extension SetsTransitionAndRestViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return isTime ? 2 : 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return isTime ? pickerMinutesAndSeconds.count : maxNumberOfSets
        
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleString = isTime ? "\(row)" : "\(row + 1)"
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
            
            numberOfSets = row + 1
            
            chosenPickerInfoLabel.text = "\(numberOfSets)"
            
        }
        
    }

}








