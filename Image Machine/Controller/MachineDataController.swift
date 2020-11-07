//
//  MachineDataController.swift
//  Image Machine
//
//  Created by Firman Aminuddin on 06/11/20.
//  Copyright © 2020 Prospace. All rights reserved.
//

import UIKit
import CoreData

class MachineDataController: UIViewController{
    
    // MARK: VAR CORE DATA
    var dbMachine : [NSManagedObject] = []
    var machineData : [ClassMachineData] = []
    var indexNow = 0
    var sortText = "name"
    @IBOutlet weak var tableViewMachineData: UITableView!
    @IBOutlet weak var labelEmpty: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewMachineData.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupMachineData()
        
    }
    
    // MARK: UI ACTION
    @IBAction func actionChooseSort(_ sender: UIBarButtonItem) {
        actionSheetSort(arrString: ["Machine Name", "Machine Type"])
    }
    @IBAction func actionAddMachineData(_ sender: UIButton) {
        showFillData(mode: "add")
    }
    
    func showFillData(mode : String){
        var stringTitle = "New Machine Data"
        var stringName = ""
        var stringType = ""
        var stringQR = ""
        if(mode == "edit"){
            let objDB = dbMachine[indexNow]
            let dataName = Convert.toString(value: objDB.value(forKeyPath: "name"))
            let dataType = Convert.toString(value: objDB.value(forKeyPath: "type"))
            let dataQR = Convert.toString(value: objDB.value(forKeyPath: "qrNumber"))
            
            stringTitle = "Update Data"
            stringName = dataName
            stringType = dataType
            stringQR = dataQR
        }
        
        // set title
        let alert = UIAlertController(title: stringTitle,
                                      message: "",
                                      preferredStyle: .alert)
        
        // set textfield name
        alert.addTextField { textField in
            textField.placeholder = "Machine Name"
            textField.text = stringName
        }
        
        // set textfield type
        alert.addTextField { textField in
            textField.placeholder = "Machine Type"
            textField.text = stringType
        }
        
        // set textfield type
        alert.addTextField { textField in
            textField.placeholder = "Machine QR Code"
            textField.text = stringQR
        }
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) {
                                        [unowned self] action in
                                        
                                        guard let textField = alert.textFields?.first,
                                            let nameToSave = textField.text else {
                                                return
                                        }
                                        
                                        guard let textField2 = alert.textFields?[1],
                                            let nameToSave2 = textField2.text else {
                                                return
                                        }
                                        
                                        guard let textField3 = alert.textFields?[2],
                                            let nameToSave3 = textField3.text else {
                                                return
                                        }
                                        
                                        if(nameToSave == "" || nameToSave2 == "" || nameToSave3 == ""){
                                            AlertShow.basicAlert(vc: self, title: "", message: "Please input data", buttonText: "OK")
                                        }else{
                                            let objSave = ClassMachineData.init(id: "", name: nameToSave, type: nameToSave2, qrNumber: nameToSave3, dateMaintenance: "")
                                            if(mode == "edit"){
                                                self.editData(objectSave: objSave)
                                            }else{
                                                self.saveData(objectSave: objSave)
                                            }
                                        }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // MARK: CORE DATA
    func setupMachineData(){
        // set context
        let context = appDelegate!.persistentContainer.viewContext

        // load data
        let fetchData =
          NSFetchRequest<NSManagedObject>(entityName: "MachineData")
        let sortDescriptor = NSSortDescriptor(key: sortText, ascending: true)
        fetchData.sortDescriptors = [sortDescriptor]

        do {
            dbMachine = try context.fetch(fetchData)

            do {
                try context.save()
            } catch{
            }

            checkData()
        } catch let error as NSError {
            AlertShow.basicAlert(vc: self, title: "", message: "Could not fetch. \(error.localizedDescription)", buttonText: "Close")
        }
    }
    
    func saveData(objectSave : ClassMachineData){
        // set context
        let context = appDelegate!.persistentContainer.viewContext
        
        // set entity
        let entityMachine = NSEntityDescription.entity(forEntityName: "MachineData", in: context)
        
        let date = NSDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date as Date)
        
        let checkIncrement = dbMachine.count
        var idIncrement = 1
        if(checkIncrement == 0){
            idIncrement = 1
        }else{
            idIncrement = checkIncrement + 1
        }
        
        // set managedObject
        let machineDataObject = NSManagedObject(entity: entityMachine!, insertInto: context)
        machineDataObject.setValue("\(idIncrement)", forKey: "id")
        machineDataObject.setValue(objectSave.name, forKey: "name")
        machineDataObject.setValue(objectSave.type, forKey: "type")
        machineDataObject.setValue(objectSave.qrNumber, forKey: "qrNumber")
        machineDataObject.setValue(dateString, forKey: "maintenanceDate")
        
        // submit data
        do {
            try context.save()
            dbMachine.append(machineDataObject)
            checkData()
        } catch let error as NSError {
            AlertShow.basicAlert(vc: self, title: "", message: "Could not save. \(error.localizedDescription)", buttonText: "Close")
        }
    }
    
    func deleteData(){
        let objDB = dbMachine[indexNow]
        let dataId = Convert.toString(value: objDB.value(forKeyPath: "id"))
        
        // set context
        let context = appDelegate!.persistentContainer.viewContext
        
        // delete image
        let fetchData = NSFetchRequest<NSManagedObject>(entityName: "MachineData")
        fetchData.predicate = NSPredicate(format: "id == %@",dataId)
        
        
        // delete image
        let fetchData2 = NSFetchRequest<NSManagedObject>(entityName: "DetailMachineData")
        fetchData2.predicate = NSPredicate(format: "id == %@",dataId)
        
        do {
            dbMachine = try context.fetch(fetchData)
            let objToDel = dbMachine[0]
            context.delete(objToDel)
            
            do {
                try context.save()
            } catch{
            }
            
            AlertShow.basicAlert(vc: self, title: "", message: "1 Item Deleted Successfully", buttonText: "Close")
            setupMachineData()
        } catch let error as NSError {
            AlertShow.basicAlert(vc: self, title: "", message: "Could not fetch. \(error.localizedDescription)", buttonText: "Close")
        }
        
        do {
            dbMachine = try context.fetch(fetchData2)
            let objToDel = dbMachine[0]
            context.delete(objToDel)
            
            do {
                try context.save()
            } catch{
            }
            
            //AlertShow.basicAlert(vc: self, title: "", message: "1 Item Deleted Successfully", buttonText: "Close")
            setupMachineData()
        } catch let error as NSError {
            AlertShow.basicAlert(vc: self, title: "", message: "Could not fetch. \(error.localizedDescription)", buttonText: "Close")
        }
    }
    
    func editData(objectSave : ClassMachineData){
        let objDB = dbMachine[indexNow]
        let dataName = Convert.toString(value: objDB.value(forKeyPath: "id"))
        
        // set context
        let context = appDelegate!.persistentContainer.viewContext
        
        // delete image
        let fetchData = NSFetchRequest<NSManagedObject>(entityName: "MachineData")
        fetchData.predicate = NSPredicate(format: "id == %@",dataName)
        
        do {
            let test = try context.fetch(fetchData)
            let objToDel = test[0]
            objToDel.setValue(objectSave.name, forKey: "name")
            objToDel.setValue(objectSave.type, forKey: "type")
            objToDel.setValue(objectSave.qrNumber, forKey: "qrNumber")
            
            do {
                try context.save()
                
                AlertShow.basicAlert(vc: self, title: "", message: "Item Updated Successfully", buttonText: "Close")
                setupMachineData()
            } catch let error as NSError{
                AlertShow.basicAlert(vc: self, title: "", message: "Could not update the data. \(error.localizedDescription)", buttonText: "Close")
            }
        } catch let error as NSError {
            AlertShow.basicAlert(vc: self, title: "", message: "Could not fetch. \(error.localizedDescription)", buttonText: "Close")
        }
    }
    
    func checkData(){
        if(dbMachine.count > 0){
            tableViewMachineData.isHidden = false
            labelEmpty.isHidden = true
            tableViewMachineData.reloadData()
        }else{
            tableViewMachineData.isHidden = true
            labelEmpty.isHidden = false
        }
    }
}

// MARK: UI SETUP
extension MachineDataController{
    func actionSheetSort(arrString : [String]){
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Sort By: ", style: .default, handler: nil))
        
        for i in 0 ..< arrString.count{
            sheet.addAction(UIAlertAction(title: arrString[i], style: .default, handler: { action in
                self.sortBy(tag: i)
            }))
        }
        
        sheet.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        
        present(sheet, animated: true, completion: nil)
    }
    
    func sortBy(tag : Int){
        if(tag == 0){
            sortText = "name"
        }else{
            sortText = "type"
        }
        setupMachineData()
    }
}

// MARK: TABLEVIEW DELEGATE
extension MachineDataController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dbMachine.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewCellMachineData") as! ViewCellMachineData
        
        let objArrCoreDBMachine = dbMachine[indexPath.row]
        let name = objArrCoreDBMachine.value(forKeyPath: "name") as! String
        let type = objArrCoreDBMachine.value(forKeyPath: "type") as! String
        cell.setData(machineData: ClassMachineData.init(id: "", name: "Machine Name: " + name, type: "Machine Type: " + type, qrNumber: "", dateMaintenance: ""))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objArrCoreDBMachine = dbMachine[indexPath.row]
        let id = objArrCoreDBMachine.value(forKeyPath: "id") as! String
        let name = objArrCoreDBMachine.value(forKeyPath: "name") as! String
        let type = objArrCoreDBMachine.value(forKeyPath: "type") as! String
        let date = objArrCoreDBMachine.value(forKeyPath: "maintenanceDate") as! String
        let qr = objArrCoreDBMachine.value(forKeyPath: "qrNumber") as! String
        let objClassMachine = ClassMachineData.init(id: id, name: name, type: type, qrNumber: qr, dateMaintenance: date)
        
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "DetailController") as! DetailController
        vc.title = "Detail Machine"
        vc.arrMachineData = objClassMachine
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        indexNow = indexPath.row
        let contextItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            //Code I want to do here
            self.deleteData()
        }
        
        let contextItemEdit = UIContextualAction(style: .destructive, title: "Edit") {  (contextualAction, view, boolValue) in
            //Code I want to do here
            self.showFillData(mode: "edit")
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItemEdit,contextItem])

        return swipeActions
    }
}
