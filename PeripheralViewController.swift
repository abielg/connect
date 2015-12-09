//
//  PeripheralViewController.swift
//  Connect
//
//  Created by Abiel Gutierrez on 12/6/15.
//  Copyright © 2015 Abiel Gutierrez. All rights reserved.
//
import UIKit
import CoreBluetooth
import Parse

class PeripheralViewController: UIViewController, CBPeripheralManagerDelegate {
    var peripheralManager: CBPeripheralManager?
    
    let SERVICE_UUID = CBUUID(string: "BC585695-CB18-4AEF-98E3-54CF0A2D08A9")
    let CHARACTERISTIC_UUID = CBUUID(string:"DDB11B18-029E-4431-BA2B-3C6C32E44FA5")
    
    let user = PFUser.currentUser()
    let PARSE_OBJECT_ID = "ukx0xvH6vt"
    
    @IBOutlet weak var transmittingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Create Connection"
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        peripheralManager?.stopAdvertising()
        transmittingLabel.hidden = true
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        print("got here")
        if peripheral.state != CBPeripheralManagerState.PoweredOn{
            let error = UIAlertController.createAlert("Error", withMessage: "Please turn on and enable Bluetooth for this device.")
            presentViewController(error, animated: true, completion: nil)
            return
        }
        
        if peripheral.state == CBPeripheralManagerState.PoweredOn{
            let service = CBMutableService(type: SERVICE_UUID, primary: true)
            let characteristic = CBMutableCharacteristic(type: CHARACTERISTIC_UUID, properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
            service.characteristics = [characteristic]
            peripheralManager!.addService(service)
            peripheralManager!.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[SERVICE_UUID]])
            postNameToParse()
            print("service advertised")
            transmittingLabel.hidden = false
        }
    }

    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        if error != nil {
            print(error?.description)
        } else {
            print("Added service: \(service.description)")
        }
    }
    
    //The "create connection" device posts its current user's username to Parse so that the "seek connection"
    //device can retrieve it upon pairing and connect with that user.
    func postNameToParse(){
        let query = PFQuery(className: "BluetoothConnection")
        query.getObjectInBackgroundWithId(PARSE_OBJECT_ID){
            (connectObject: PFObject?, error: NSError?) -> Void in
            if let obj = connectObject {
                obj["device"] = UIDevice.currentDevice().name
                obj["username"] = self.user!["username"]
                
                obj.saveInBackgroundWithBlock{
                    (success: Bool, error: NSError?) in
                    if error != nil {
                        self.sendError()
                    }
                    if success{
                        print("New device saved in Parse")
                    }
                }
            } else if error != nil {
                self.sendError()
            }
        }
    }
    
    func sendError() {
        let alert = UIAlertController.createAlert("Error", withMessage: "Connection request failed. Please retry.")
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
