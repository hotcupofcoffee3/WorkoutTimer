//
//  ProtocolModel.swift
//  WorkoutTimer
//
//  Created by Adam Moore on 8/21/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation

protocol LoadRoutineExercisesDelegate {
    
    func reloadExercisesPerRoutine()
    
}

protocol SetRoutineDelegate {
    
    func setRoutine(oldName: String, newName: String, isNew: Bool)
    func settingRoutine(wasCanceled: Bool)
    
}

protocol SetExerciseDelegate {
    
    func setExercise(oldName: String, newName: String, minutes: Int, seconds: Int, reps: Int, isNew: Bool)
    
}

protocol SetSetsTransitionsAndRestDelegate {
    
    func setSets(numberOfSets: Int)
    func setTransition(minutes: Int, seconds: Int)
    func setRest(minutes: Int, seconds: Int)
    
}

protocol InstructionsWereShownDelegate {
    
    func instructionsWereShown()
    
}
