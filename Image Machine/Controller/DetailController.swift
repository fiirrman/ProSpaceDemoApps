//
//  DetailController.swift
//  Image Machine
//
//  Created by Firman Aminuddin on 07/11/20.
//  Copyright © 2020 Prospace. All rights reserved.
//

import UIKit
import TLPhotoPicker
import CoreData
import SKPhotoBrowser

class DetailController: UIViewController, SKPhotoBrowserDelegate{
    
    var dbMachineDetail : [NSManagedObject] = []
    var arrMachineData : ClassMachineData?
    var selectedAssets = [TLPHAsset]() // FOR TEMP SELECTED ASSET CHOOSE IMAGE
    var indexCellColl = 0
    @IBOutlet weak var tableViewDetailMachine: UITableView!
    @IBOutlet weak var imageTest: UIImageView!
    @IBOutlet weak var collectionViewDetailMachine: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewDetailMachine.delegate = self
        tableViewDetailMachine.dataSource = self
        tableViewDetailMachine.tableFooterView = UIView()  // it's just 1 line, awesome!'
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadDetailImage()
    }
    
    // MARK: UI SETUP
    func setupUI(){
        collectionViewDetailMachine.layer.borderWidth = 1
        collectionViewDetailMachine.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    // MARK: UI ACTION
    @IBAction func actionFetchImage(_ sender: UIButton) {
        let viewController = TLPhotosPickerViewController(withTLPHAssets: { [weak self] (assets) in // TLAssets
            self!.selectedAssets = assets // SAVE IMAGE ASSET
            self?.navigationController?.popViewController(animated: true)
            self?.saveDataDetailImage()
            }, didCancel: ({
                self.navigationController?.popViewController(animated: true)
            }))
        
        var configureTL = TLPhotosPickerConfigure()
        configureTL.maxSelectedAssets = 10
        configureTL.selectedColor = .red
        configureTL.allowedLivePhotos = false
        configureTL.autoPlay = false
        configureTL.usedCameraButton = false
        viewController.configure = configureTL
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            AlertShow.basicAlert(vc: self!, title: "", message: "Max File is 10", buttonText: "Close")
            //exceed max selection
        }
        viewController.handleNoAlbumPermissions = { [weak self] (picker) in
            AlertShow.alertToSetting(vc: self!, errorMsg: "Please allow album access to access the photos", title: "")
            // handle denied albums permissions case
        }
        viewController.handleNoCameraPermissions = { [weak self] (picker) in
            print("no permission camera")
            // handle denied camera permissions case
        }
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
}

// MARK: CORE DATA
extension DetailController{
    func saveDataDetailImage(){
        let totalCountImage = dbMachineDetail.count + selectedAssets.count
        let finalCount = 10 - dbMachineDetail.count
        if(totalCountImage > 10){
            AlertShow.basicAlert(vc: self, title: "", message: "Image has reached the limit of 10, only \(finalCount) images remaining can be selected", buttonText: "OK")
        }else{
            for i in 0 ..< selectedAssets.count{
                let dataImage = selectedAssets[i].fullResolutionImage?.jpegData(compressionQuality: 0.2)
                let dataImageFull = selectedAssets[i].fullResolutionImage?.jpegData(compressionQuality: 1)
                let nameImage = selectedAssets[i].phAsset?.localIdentifier
                // set context
                let context = appDelegate!.persistentContainer.viewContext
                
                // set entity
                let entitiyDetailMachine = NSEntityDescription.entity(forEntityName: "DetailMachineData", in: context)
                
                // set managedObject
                let detailObject = NSManagedObject(entity: entitiyDetailMachine!, insertInto: context)
                detailObject.setValue(arrMachineData?.id, forKey: "id")
                detailObject.setValue(nameImage, forKey: "name")
                detailObject.setValue(dataImage, forKey: "image")
                detailObject.setValue(dataImageFull, forKey: "imageFull")
                
                // submit data
                do {
                    try context.save()
                    print("Save Success")
                } catch let error as NSError {
                    AlertShow.basicAlert(vc: self, title: "", message: "Could not save. \(error.localizedDescription)", buttonText: "Close")
                }
            }
        }
    }
    
    func loadDetailImage(){
        // set context
        let context = appDelegate!.persistentContainer.viewContext
        
        // load data
        let fetchData =
            NSFetchRequest<NSManagedObject>(entityName: "DetailMachineData")
        let predicate = NSPredicate(format: "id = " + arrMachineData!.id)
        fetchData.predicate = predicate
        
        do {
            dbMachineDetail = try context.fetch(fetchData)
            print(dbMachineDetail.count)
            print("sukses fetch")
            collectionViewDetailMachine.reloadData()
        } catch let error as NSError {
            AlertShow.basicAlert(vc: self, title: "", message: "Could not fetch. \(error.localizedDescription)", buttonText: "Close")
        }
    }
    
    func actionSheetImageOption(){
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        sheet.addAction(UIAlertAction(title: "View Image", style: .default, handler: { action in
            self.viewImageOption()
        }))
        
        sheet.addAction(UIAlertAction(title: "Delete Image", style: .default, handler: { action in
            self.deleteImageOption()
        }))
        
        sheet.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        
        present(sheet, animated: true, completion: nil)
    }
    
    func viewImageOption(){
        var images = [SKPhoto]()
        let objDB = dbMachineDetail[indexCellColl]
        let dataImage = objDB.value(forKeyPath: "imageFull") as! Data
        let photo = SKPhoto.photoWithImage(UIImage.init(data: dataImage)!)
        photo.shouldCachePhotoURLImage = false // you can use image cache by true(NSCache)
        images.append(photo)

        var browser = SKPhotoBrowser()
        browser = SKPhotoBrowser(photos: images)
        browser.delegate = self
        present(browser, animated: true, completion: {})
    }
    
    func deleteImageOption(){
        let objDB = dbMachineDetail[indexCellColl]
        let dataName = Convert.toString(value: objDB.value(forKeyPath: "name"))
        let dataId = Convert.toString(value: objDB.value(forKeyPath: "id"))
        
        // set context
        let context = appDelegate!.persistentContainer.viewContext
        
        // delete image
        let fetchData = NSFetchRequest<NSManagedObject>(entityName: "DetailMachineData")
        fetchData.predicate = NSPredicate(format: "name == %@ && id == %@",dataName,dataId)
        
        do {
            dbMachineDetail = try context.fetch(fetchData)
            print(dbMachineDetail.count)
            let objToDel = dbMachineDetail[0]
            context.delete(objToDel)
            
            do {
                try context.save()
            } catch{
            }
            
            AlertShow.basicAlert(vc: self, title: "", message: "1 Item Deleted Successfully", buttonText: "Close")
            loadDetailImage()
        } catch let error as NSError {
            AlertShow.basicAlert(vc: self, title: "", message: "Could not fetch. \(error.localizedDescription)", buttonText: "Close")
        }
    }
}

// MARK: TABLEVIEW DELEGATE
extension DetailController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewCellDetailMachine") as! ViewCellDetailMachine
        
        let indexing = indexPath.row
        if(indexing == 0){
            cell.titleLeft.text = "Machine Id"
            cell.titleRight.text = arrMachineData?.id
        }else if(indexing == 1){
            cell.titleLeft.text = "Machine Name"
            cell.titleRight.text = arrMachineData?.name
        }else if(indexing == 2){
            cell.titleLeft.text = "Machine Type"
            cell.titleRight.text = arrMachineData?.type
        }else if(indexing == 3){
            cell.titleLeft.text = "Machine QR Code Number"
            cell.titleRight.text = arrMachineData?.qrNumber
        }else if(indexing == 4){
            cell.titleLeft.text = "Last Maintenance Date"
            cell.titleRight.text = arrMachineData?.dateMaintenance
        }
        return cell
    }
}

// MARK: COLLECTION VIEW DELEGATE
extension DetailController : UICollectionViewDataSource, UICollectionViewDelegate{
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dbMachineDetail.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MachineDetailCollectionCell", for: indexPath as IndexPath) as! MachineDetailCollectionCell
        
        let objDB = dbMachineDetail[indexPath.row]
        let dataImage = objDB.value(forKeyPath: "image") as! Data
        cell.imageCell.image = UIImage.init(data: dataImage)
        cell.backgroundColor = .white // make cell more visible in our example project
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        indexCellColl = indexPath.item
        actionSheetImageOption()
    }
}
