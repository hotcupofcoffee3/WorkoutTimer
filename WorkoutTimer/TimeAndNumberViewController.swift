//
//  TimeAndNumberViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 7/23/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

protocol SetNumberDelegate {
    
    func setSets(numberOfSets: Int)
    func setTime(minutes: Int, seconds: Int)
    
}

class TimeAndNumberViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var delegate: SetNumberDelegate?
    
    var isTime = Bool()
    
    var isInterval = Bool()
    
    var numberOfSets = Int()
    
    var minutes = Int()
    
    var seconds = Int()
    
    var pickerMinutesAndSeconds = Array(0...59)
    
    @IBOutlet weak var chosenPickerInfoLabel: UILabel!
    
    @IBOutlet weak var numberPicker: UIPickerView!
    
    @IBAction func setNumberButton(_ sender: UIButton) {
        
        delegate?.setSets(numberOfSets: numberOfSets)
        
        delegate?.setTime(minutes: minutes, seconds: seconds)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chosenPickerInfoLabel.text = isTime ? "--:--" : "\(numberOfSets)"

    }
    
}



extension TimeAndNumberViewController {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return isTime ? 2 : 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return isTime ? pickerMinutesAndSeconds.count : 10
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return isTime ? "\(row)" : "\(row + 1)"

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if isTime {
            
            if component == 0 {
                
                minutes = row
                
            } else if component == 1 {
                
                seconds = row
                
            }
            
            
            
            var minutesZero = ""
            
            var secondsZero = ""
            
            if minutes <= 9 {
                minutesZero = "0"
            }
            if seconds <= 9 {
                secondsZero = "0"
            }
            
            
            
            chosenPickerInfoLabel.text = "\(minutesZero)\(minutes):\(secondsZero)\(seconds)"
            
        } else {
            
            chosenPickerInfoLabel.text = "\(numberOfSets)"
            
        }
            
    }
    
}











