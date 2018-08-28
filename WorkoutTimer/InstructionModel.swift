//
//  InstructionModel.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 8/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation

enum TypeOfViewController: String {
    
    case Main
    case Exercise
    case Routine
    case AddExercise
    case AddRoutine
    case SetsTransitionAndRest
    
}
  

struct InstructionItem {
    
    private var keywords = Keywords()
    
    var segueKey: String
    
    var message: String
    
    var wasShown: Bool
    
    init(type: TypeOfViewController) {
        
        switch type {
            
        case .Main:
            segueKey = keywords.mainToInstructionsSegue
            message = "Main"
            wasShown = UserDefaults.standard.object(forKey: type.rawValue) ?? false
            
        case .Exercise:
            segueKey = keywords.exercisesToInstructionsSegue
            message = "Exercise"
            
        case .Routine:
            segueKey = keywords.routinesToInstructionsSegue
            message = "Routine"
            
        case .AddExercise:
            segueKey = keywords.addExerciseToInstructionsSegue
            message = "Add Exercise"
            
        case .AddRoutine:
            segueKey = keywords.addRoutineToInstructionsSegue
            message = "Add Routine"
            
        case .SetsTransitionAndRest:
            segueKey = keywords.setsTransitionAndRestToInstructionsSegue
            message = "Sets, Transition, and Rest"

        }
        
    }
    
}





