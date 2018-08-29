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
    
    private var keywords = Keywords()
    
    var segueKey: String
    
    var message: String
    
    var wereShown = false
    
    let timeBeforeShowing = 0.3
    
    var typeOfViewController: TypeOfViewController
    
    init(type: TypeOfViewController) {
        
        switch type {
            
        case .Main:
            segueKey = keywords.mainToInstructionsSegue
            message = "Click any item on the screen to edit its settings."
            
        case .Exercise:
            segueKey = keywords.exercisesToInstructionsSegue
            message = "Add up to 10 Exercises for each Routine, or edit old ones."
            
        case .Routine:
            segueKey = keywords.routinesToInstructionsSegue
            message = "Add some new Routines, or edit old ones."
            
        case .AddExercise:
            segueKey = keywords.addExerciseToInstructionsSegue
            message = "Choose either Time or Reps for each Exercise."
           
        case .SetsTransitionAndRest:
            segueKey = keywords.setsTransitionAndRestToInstructionsSegue
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





