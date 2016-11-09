//
//  BaaSConsumer.swift
//  BackendlessApiControllerAdventures
//
//  Created by Bruno Gama on 12/06/16.
//  Copyright © 2016 Bruno Gama. All rights reserved.
//

protocol BaaSConsumer {
    associatedtype BaaSObject
    var consumer:BaaSObject { get }
}