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
    let sentData = NSString(string: "hi").dataUsingEncoding(NSUTF8StringEncoding)
    let dataIndex = NSInteger()
    
    let SERVICE_UUID = CBUUID(string: "BC585695-CB18-4AEF-98E3-54CF0A2D08A9")
    let CHARACTERISTIC_UUID = CBUUID(string:"DDB11B18-029E-4431-BA2B-3C6C32E44FA5")
    
    let user = PFUser.currentUser()
    let PARSE_OBJECT_ID = "ukx0xvH6vt"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Create Connection"
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        //sentData = ("hi").dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    override func viewWillDisappear(animated: Bool) {
        peripheralManager?.stopAdvertising()
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        print("got here")
        if peripheral.state != CBPeripheralManagerState.PoweredOn{
            let error = UIAlertController.createAlert("Error", withMessage: "Please turn on and enable Bluetooth for this device.")
            presentViewController(error, animated: true, completion: nil)
            return
        }
        
        if peripheral.state == CBPeripheralManagerState.PoweredOn{
           // if let data = sentData{
                let service = CBMutableService(type: SERVICE_UUID, primary: true)
                let characteristic = CBMutableCharacteristic(type: CHARACTERISTIC_UUID, properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
                service.characteristics = [characteristic]
                peripheralManager!.addService(service)
                peripheralManager!.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[SERVICE_UUID]])
                postNameToParse()
                print("service advertised")
          //  }
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        print("subscribed bitch")
    }
    
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        if error != nil {
            print(error?.description)
        } else {
            print("Added service: \(service.description)")
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        print("read request")
    }
    
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
