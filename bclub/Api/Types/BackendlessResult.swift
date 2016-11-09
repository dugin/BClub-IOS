//
//  BackendlessResult.swift
//  BackendlessApiControllerAdventures
//
//  Created by Bruno Gama on 12/06/16.
//  Copyright © 2016 Bruno Gama. All rights reserved.
//

enum BackendlessResult<T> {
    case Success(T)
    case Failure(Fault)
}
