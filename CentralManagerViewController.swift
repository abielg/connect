//
//  CentralManagerViewController.swift
//  Connect
//
//  Created by Abiel Gutierrez on 12/6/15.
//  Copyright © 2015 Abiel Gutierrez. All rights reserved.
//

import UIKit
import CoreBluetooth
import Parse

class CentralManagerViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var discoveredPeripheral: CBPeripheral?
    var centralManager = CBCentralManager()
    
    let SERVICE_UUID = CBUUID(string: "BC585695-CB18-4AEF-98E3-54CF0A2D08A9") 
    let CHARACTERISTIC_UUID = CBUUID(string:"DDB11B18-029E-4431-BA2B-3C6C32E44FA5")
    
    let user = PFUser.currentUser()
    let PARSE_OBJECT_ID = "ukx0xvH6vt"
    
    @IBOutlet weak var seekingLabel: UILabel!
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.navigationItem.title = "Seek Connection"
        centralManager.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        centralManager.stopScan()
        seekingLabel.hidden = true
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch(central.state){
        case .Unknown:
            return
        case .Resetting:
            return
        case .Unsupported:
            let alert = UIAlertController.createAlert("Error", withMessage: "Bluetooth is not supported by your device.")
            presentViewController(alert, animated: true, completion: nil)
        case .Unauthorized:
            let alert = UIAlertController.createAlert("Error", withMessage: "Please authorize the use of Bluetooth in this application.")
            presentViewController(alert, animated: true, completion: nil)
        case .PoweredOff:
            let alert = UIAlertController.createAlert("Error", withMessage: "Please turn Bluetooth on.")
            presentViewController(alert, animated: true, completion: nil)
        case .PoweredOn:
            centralManager.scanForPeripheralsWithServices([SERVICE_UUID], options: nil)
            seekingLabel.hidden = false
            print("scanning started")
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("peripheral discovered: \(peripheral.name)")
        retrieveNameFromParse(peripheral.name!)
        discoveredPeripheral = peripheral
        centralManager.connectPeripheral(peripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("peripheral connected")
        centralManager.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let service = peripheral.services?.first{
            print("got service")
            peripheral.discoverCharacteristics(nil, forService: service)
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        discoveredPeripheral = nil
    }
    
    func removeConnections(){
        if let peri = discoveredPeripheral{
            centralManager.cancelPeripheralConnection(peri)
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        seekingLabel.hidden = true
        removeConnections()
        let alert = UIAlertController.createAlert("Error", withMessage: "Failed to connect to device.")
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func retrieveNameFromParse(device: String){
        let query = PFQuery(className: "BluetoothConnection")
        query.getObjectInBackgroundWithId(PARSE_OBJECT_ID){
            (connectObject: PFObject?, error: NSError?) -> Void in
            if let obj = connectObject {
                if obj["device"] as? String == device {
                    if let connectionUsername = obj["username"] as? String{
                        let query2 = PFUser.query()
                        query2!.whereKey("username", equalTo: connectionUsername)
                        query2!.findObjectsInBackgroundWithBlock{
                            (objects: [PFObject]?, error: NSError?) -> Void in
                            if let newContact = objects!.first as? PFUser {
                                if let arr = self.user!.objectForKey("contacts") as? Array<PFUser>{
                                    if arr.contains(newContact) {
                                        let alert = UIAlertController.createAlert("Error", withMessage:"This user is in your contact list already!")
                                        self.presentViewController(alert, animated: true, completion: nil)
                                        return
                                    }
                                }
                                
                                self.user!.addObject(newContact, forKey: "contacts")
                                self.user!.saveInBackgroundWithBlock{
                                    (success: Bool, error: NSError?) in
                                    if success{
                                        var newConnection = ""
                                        if let contactName = newContact["name"] as? String{
                                            newConnection = contactName
                                        } else {
                                            newConnection = newContact["username"] as! String
                                        }
                                        let alert = UIAlertController.createAlert("New Connection!", withMessage:"\(newConnection) is now in your contacts list.")
                                        self.presentViewController(alert, animated: true, completion: nil)
                                        self.seekingLabel.hidden = true
                                        return
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
       // let alert = UIAlertController.createAlert("Error", withMessage: "Connection request failed. Please retry.")
       // self.presentViewController(alert, animated: true, completion: nil)
    }
}
