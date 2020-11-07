//
//  ViewCellMachineData.swift
//  Image Machine
//
//  Created by Firman Aminuddin on 06/11/20.
//  Copyright © 2020 Prospace. All rights reserved.
//

import UIKit

class ViewCellMachineData: UITableViewCell {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelType: UILabel!
    
    func setData(machineData : ClassMachineData){
        self.labelName.text = machineData.name
        self.labelType.text = machineData.type
    }
}
