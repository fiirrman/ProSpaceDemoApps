//
//  QRScanController.swift
//  Image Machine
//
//  Created by Firman Aminuddin on 07/11/20.
//  Copyright © 2020 Prospace. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreData

class QRScanController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var timerAnimate = Timer()
    var lineRed = UIView()
    var tokenCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .qr]
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight) // edit position
        previewLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(previewLayer)
        
        createViewAnimation()
        
        captureSession.startRunning()
    }
    
    func createViewAnimation(){
        let heightMain = previewLayer.frame.height
        let heightItem = heightMain * 0.3
        let viewTop = createView(bgColour: .black, position: CGRect(x: 0, y: 0, width: screenWidth, height: heightItem))
        viewTop.alpha = 0.5
        view.addSubview(viewTop)
        let viewBottom = createView(bgColour: .black, position: CGRect(x: 0, y: heightMain - heightItem, width: screenWidth, height: heightMain))
        viewBottom.alpha = 0.5
        view.addSubview(viewBottom)
        let viewLeft = createView(bgColour: .black, position: CGRect(x: 0, y: viewTop.frame.height, width: screenWidth * 0.1, height: heightMain - (viewTop.frame.height * 2)))
        viewLeft.alpha = 0.5
        view.addSubview(viewLeft)
        let viewRight = createView(bgColour: .black, position: CGRect(x: screenWidth - (screenWidth * 0.1), y: viewTop.frame.height, width: screenWidth * 0.1, height: viewLeft.frame.height))
        viewRight.alpha = 0.5
        view.addSubview(viewRight)
        
        let heightLine = previewLayer.frame.height * 0.004 // FOR WIDTH LINE
        let heightAll = previewLayer.frame.height * 0.02 // FOR HEIGHT LINE
        for i in 0 ..< 8{
            var marginX : CGFloat = 0
            var marginY : CGFloat = viewTop.frame.height
            var marginWidth : CGFloat = 0
            var marginHeight : CGFloat = 0
            if(i == 0){
                marginX = viewLeft.frame.width
                marginWidth = heightLine
                marginHeight = heightAll
            }else if(i == 1){
                marginX = viewLeft.frame.width + heightLine
                marginWidth = heightAll
                marginHeight = heightLine
            }else if(i == 2){
                marginX = viewRight.frame.origin.x - (heightAll + heightLine)
                marginWidth = heightAll
                marginHeight = heightLine
            }else if(i == 3){
                marginX = viewRight.frame.origin.x - heightLine
                marginWidth = heightLine
                marginHeight = heightAll
            }else if(i == 4){ // BOTTOM GREEN START HERE
                marginX = viewLeft.frame.width
                marginY = viewBottom.frame.origin.y - heightAll
                marginWidth = heightLine
                marginHeight = heightAll
            }else if(i == 5){
                marginX = viewLeft.frame.width + heightLine
                marginY = viewBottom.frame.origin.y - heightLine
                marginWidth = heightAll
                marginHeight = heightLine
            }else if(i == 6){
                marginX = viewRight.frame.origin.x - (heightLine + heightAll)
                marginY = viewBottom.frame.origin.y - heightLine
                marginWidth = heightAll
                marginHeight = heightLine
            }else if(i == 7){
                marginX = viewRight.frame.origin.x - (heightLine)
                marginY = viewBottom.frame.origin.y - heightAll
                marginWidth = heightLine
                marginHeight = heightAll
            }
            let viewGreen = createView(bgColour: .green, position: CGRect(x: marginX, y: marginY, width: marginWidth, height: marginHeight))
            view.addSubview(viewGreen)
        }
        
        lineRed = createView(bgColour: .red, position: CGRect(x: viewLeft.frame.width, y: heightMain / 2 - (heightLine / 2), width: screenWidth - (viewLeft.frame.width * 2), height: heightLine))
        lineRed.alpha = 0.1
        view.addSubview(lineRed)
        
        timerAnimate = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.setAnimateRedLine), userInfo: .none, repeats: true)
    }
    
    @objc func setAnimateRedLine(){
        UIView.animate(withDuration: 0.7, animations: { () -> Void in
            if(self.lineRed.alpha == 1){
                self.lineRed.alpha = 0.1
            }else{
                self.lineRed.alpha = 1
            }
        })
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        dismiss(animated: true)
    }
    
    func found(code: String) {
        print(code)
        tokenCode = code
        fetchData()
//        backPageCall()
    }
    
    func fetchData(){
        // set context
        let context = appDelegate!.persistentContainer.viewContext
        
        // load data
        let fetchData = NSFetchRequest<NSManagedObject>(entityName: "MachineData")
        fetchData.predicate = NSPredicate(format: "qrNumber == %@",tokenCode)
        print("qrNumber : \(tokenCode)")


        do {
            let dbMachine = try context.fetch(fetchData)
            if(dbMachine.count == 0){
                backPageCall()
                let viewController = UIApplication.shared.windows.first!.rootViewController
                AlertShow.basicAlert(vc: viewController!, title: "", message: "Data not found", buttonText: "Close")
            }else{
                backPageCall()
                goToDetailPage(obj: dbMachine[0])
                
//                AlertShow.basicAlert(vc: self, title: "", message: "Data found", buttonText: "Close")
            }
        } catch let error as NSError {
            AlertShow.basicAlert(vc: self, title: "", message: "Could not fetch. \(error.localizedDescription)", buttonText: "Close")
        }
    }
    
    func goToDetailPage(obj : NSManagedObject){
       let id = obj.value(forKeyPath: "id") as! String
       let name = obj.value(forKeyPath: "name") as! String
       let type = obj.value(forKeyPath: "type") as! String
       let qr = obj.value(forKeyPath: "qrNumber") as! String
       let date = obj.value(forKeyPath: "maintenanceDate") as! String
       let objClassMachine = ClassMachineData.init(id: id, name: name, type: type, qrNumber: qr, dateMaintenance: date)
       
       let vc = mainStoryboard.instantiateViewController(withIdentifier: "DetailController") as! DetailController
       vc.title = "Detail Machine"
       vc.arrMachineData = objClassMachine
       self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    override var prefersStatusBarHidden: Bool {
//        return false
//    }
//
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .portrait
//    }
}

