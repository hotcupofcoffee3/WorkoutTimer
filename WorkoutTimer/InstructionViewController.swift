//
//  InstructionViewController.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 8/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class InstructionViewController: UIViewController {
    
    var instructions = "Instructions here."
    
    var instructionsWereShownDelegate: InstructionsWereShownDelegate?

    @IBOutlet weak var instructionView: UIView!
    
    @IBOutlet weak var instructionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        instructionLabel.text = instructions
        instructionView.layer.cornerRadius = 12
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        instructionsWereShownDelegate?.instructionsWereShown()
        dismiss(animated: true, completion: nil)
    }

}
