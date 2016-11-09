//
//  BackendlessConsumer.swift
//  BackendlessApiControllerAdventures
//
//  Created by Bruno Gama on 12/06/16.
//  Copyright © 2016 Bruno Gama. All rights reserved.
//

protocol BackendlessConsumer: BaaSConsumer {
}

extension BackendlessConsumer {
    var consumer:Backendless {
        get {
            return Backendless.sharedInstance()
        }
    }
}