//
//  SetsTranstionAndRestViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

protocol SetSetsTransitionsAndRestDelegate {
    
    func setSets(numberOfSets: Int)
    func setTransition(minutes: Int, seconds: Int)
    func setRest(minutes: Int, seconds: Int)
    
}

class SetsTransitionAndRestViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
        
    var delegate: SetSetsTransitionsAndRestDelegate?
    
    var isTime = Bool()
    
    var isTransition = Bool()
    
    var numberOfSets = Int()
    
    var minutes = Int()
    
    var seconds = Int()
    
    var pickerMinutesAndSeconds = Array(0...59)
    
    @IBOutlet weak var chosenPickerInfoTitle: UILabel!
    
    @IBOutlet weak var chosenPickerInfoLabel: UILabel!
    
    @IBOutlet weak var numberPicker: UIPickerView!
    
    @IBOutlet weak var minLabel: UILabel!
    
    @IBOutlet weak var secLabel: UILabel!
    
    @IBAction func setNumberButton(_ sender: UIButton) {
        
        if isTime && isTransition {
            
            delegate?.setTransition(minutes: minutes, seconds: seconds)
            
        } else if isTime && !isTransition {
            
            delegate?.setRest(minutes: minutes, seconds: seconds)
            
        } else {
            
            delegate?.setSets(numberOfSets: numberOfSets)
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isTime {
            
            numberPicker.selectRow(minutes, inComponent: 0, animated: true)
            
            numberPicker.selectRow(seconds, inComponent: 1, animated: true)
            
            minLabel.text = "min"
            secLabel.text = "sec"
            
        } else {
            
            numberPicker.selectRow(numberOfSets - 1, inComponent: 0, animated: true)
            
            minLabel.text = ""
            secLabel.text = ""
            
        }
        
        chosenPickerInfoLabel.text = isTime ? "\(zero(unit: minutes))\(minutes):\(zero(unit: seconds))\(seconds)" : "\(numberOfSets)"
        
    }
    
    func zero(unit: Int) -> String {
        
        var zero = ""
        
        if unit <= 9 {
            
            zero = "0"
            
        }
        
        return zero
        
    }
    
}



extension SetsTransitionAndRestViewController {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return isTime ? 2 : 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return isTime ? pickerMinutesAndSeconds.count : 10
        
    }
    
    //    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    //
    //        return isTime ? "\(row)" : "\(row + 1)"
    //
    //    }
    
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
            
            chosenPickerInfoLabel.text = "\(zero(unit: minutes))\(minutes):\(zero(unit: seconds))\(seconds)"
            
        } else {
            
            numberOfSets = row + 1
            
            chosenPickerInfoLabel.text = "\(numberOfSets)"
            
        }
        
    }

}
