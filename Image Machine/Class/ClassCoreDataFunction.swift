//
//  ClassCoreDataFunction.swift
//  Image Machine
//
//  Created by Firman Aminuddin on 07/11/20.
//  Copyright © 2020 Prospace. All rights reserved.
//

import CoreData
import UIKit

protocol CoreDataFunctionDelegate {
    func didLoadCoreData()
}

class ClassCoreDataFunction{
    var protCoreData : CoreDataFunctionDelegate?
    func loadData(sortBy : String, dbMachine : [NSManagedObject], vc : UIViewController){
        var machine = dbMachine
        let context = appDelegate!.persistentContainer.viewContext
        
        // load data
        let fetchData =
          NSFetchRequest<NSManagedObject>(entityName: "MachineData")
        let sortDescriptor = NSSortDescriptor(key: sortBy, ascending: true)
        fetchData.sortDescriptors = [sortDescriptor]

        do {
            machine = try context.fetch(fetchData)
            
            do {
                try context.save()
            } catch{
            }
            
            protCoreData?.didLoadCoreData()
        } catch let error as NSError {
            AlertShow.basicAlert(vc: vc, title: "", message: "Could not fetch. \(error.localizedDescription)", buttonText: "Close")
        }
    }
}
