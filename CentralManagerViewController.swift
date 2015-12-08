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
    
    let SERVICE_UUID = CBUUID(string: "BC585695-CB18-4AEF-98E3-54CF0A2D08A8") //changed 9 to 8
    let CHARACTERISTIC_UUID = CBUUID(string:"DDB11B18-029E-4431-BA2B-3C6C32E44FA5")
    
    let user = PFUser.currentUser()
    var newConnection: String?{
        didSet{
            let alert = UIAlertController.createAlert("Connected with \(newConnection!)")
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.navigationItem.title = "Seek Connection"
        centralManager.delegate = self
        print("viewLoaded")
    }
    
    override func viewWillDisappear(animated: Bool) {
        centralManager.stopScan()
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
            print("scanning started")
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("peripheral discovered: \(peripheral.name)")
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
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("discovered characteristic")
        if error != nil{
            print(error?.description)
            return
        }
        //might want to check for the correct UUID
        print(service.characteristics!.count)
        for char in service.characteristics!{
            print(char)
            //print(String(data:char.value!, encoding:NSUTF8StringEncoding))
            peripheral.readValueForCharacteristic(char)
        }
        
        /*if let char = service.characteristics?.first{
            print("unwrapped characteristic")
            print(char.UUID)
            peripheral.readValueForCharacteristic(char)
        }*/
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let data = characteristic.value{
            print("data unwrapped")
            newConnection = String(data: data, encoding:NSUTF8StringEncoding)
        }
    }
    
    //newConnection = String(data: data, encoding:NSUTF8StringEncoding)

    
    
    /*
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            print(error?.description)
            return
        }
        
        newConnection = String(data: characteristic.value!, encoding: NSUTF8StringEncoding)
        peripheral.setNotifyValue(false, forCharacteristic: characteristic)
        centralManager.cancelPeripheralConnection(peripheral)
        let alert = UIAlertController.createAlert("Connected to \(newConnection)")
        presentViewController(alert, animated: true, completion: nil)

    }
*/
  
    /*
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if !characteristic.isNotifying{
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
*/
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        discoveredPeripheral = nil
        print("connection lost")
    }
    
    func removeConnections(){
        if let peri = discoveredPeripheral{
            centralManager.cancelPeripheralConnection(peri)
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        removeConnections()
        let alert = UIAlertController.createAlert("Error", withMessage: "Failed to connect to device.")
        presentViewController(alert, animated: true, completion: nil)
    }
    
}
