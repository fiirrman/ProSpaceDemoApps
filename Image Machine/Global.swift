//
//  Global.swift
//  Image Machine
//
//  Created by Firman Aminuddin on 06/11/20.
//  Copyright © 2020 Prospace. All rights reserved.
//

import UIKit


// MARK: VAR GLOB
let screenSize = UIScreen.main.bounds
let screenWidth = screenSize.width
var screenHeight = screenSize.height
var mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
let appDelegate = UIApplication.shared.delegate as? AppDelegate

// MARK: ALERT
struct AlertShow {
    static func basicAlert(vc:UIViewController, title:String,message:String,buttonText:String) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: buttonText, style: .default) { _ in })
        vc.present(alert, animated: true){}
    }
    
    // SHOW ALERT ===========
    static func alertToSetting(vc:UIViewController, errorMsg : String, title : String){
        let msg = title
        let ac = UIAlertController(title: msg, message: errorMsg, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Go to Setting", style: UIAlertAction.Style.default) {
            UIAlertAction in
            vc.goToSetting()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        ac.addAction(okAction)
        ac.addAction(cancelAction)
        
        vc.present(ac, animated:  true)
    }
}

// CONVERT ANY
struct Convert {
    static func toString(value:Any?) -> String {
        var string:String="";
        if let y = value as? String {
            string = y;
        }
        else if let y = value as? Int {
            string = String(y);
        }
        return string;
    }
}

// MARK: EXTENSION
extension UIViewController{
    // GO TO SETTING APPS =========
    func goToSetting(){
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
    }
    
    // BACK NAVIGATION ===========
    @objc func backPageCall() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // CREATE VIEW ===========
    func createView(bgColour : UIColor, position : CGRect) -> UIView{
        let buttonCreate = UIView.init()
        buttonCreate.frame = position
        buttonCreate.backgroundColor = bgColour
        return buttonCreate
    }
}

