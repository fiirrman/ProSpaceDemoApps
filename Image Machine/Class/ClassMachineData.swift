//
//  ClassMachineData.swift
//  Image Machine
//
//  Created by Firman Aminuddin on 06/11/20.
//  Copyright © 2020 Prospace. All rights reserved.
//

import UIKit

class ClassMachineData {
    var id: String
    var name: String
    var type: String
    var qrNumber: String
    var dateMaintenance: String
    
    init(id: String, name: String, type: String, qrNumber: String, dateMaintenance: String) {
        self.id = id
        self.name = name
        self.type = type
        self.qrNumber = qrNumber
        self.dateMaintenance = dateMaintenance
    }
}
 
