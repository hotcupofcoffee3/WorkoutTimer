//
//  InstructionModel.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 8/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit

enum TypeOfViewController: String {
    
    case Main
    case Exercise
    case Routine
    case AddExercise
    case SetsTransitionAndRest
    
}
  

struct InstructionItem {
    
    var segueKey: String
    
    var message: String
    
    var wereShown = false
    
    let timeBeforeShowing = 0.3
    
    var typeOfViewController: TypeOfViewController
    
    init(type: TypeOfViewController) {
        
        switch type {
            
        case .Main:
            segueKey = Keywords.shared.mainToInstructionsSegue
            message = "Click any item on the screen to edit its settings."
            
        case .Exercise:
            segueKey = Keywords.shared.exercisesToInstructionsSegue
            message = "Add up to 12 Exercises for each Routine, or edit old ones."
            
        case .Routine:
            segueKey = Keywords.shared.routinesToInstructionsSegue
            message = "Add some new Routines, or edit old ones."
            
        case .AddExercise:
            segueKey = Keywords.shared.addExerciseToInstructionsSegue
            message = "Choose either Time or Reps for each Exercise."
           
        case .SetsTransitionAndRest:
            segueKey = Keywords.shared.setsTransitionAndRestToInstructionsSegue
            message = "For each Routine, you can set the Sets, Transitions between Exercises, and Rests between Sets."

        }
        
        self.typeOfViewController = type
        
    }
    
    func presentInstructions(segue: @escaping () -> Void) {
        
        if UserDefaults.standard.object(forKey: typeOfViewController.rawValue) == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + timeBeforeShowing) {
                segue()
            }
        } else {
            //            UserDefaults.standard.set(nil, forKey: typeOfViewController.rawValue)
        }
        
    }
    
}





