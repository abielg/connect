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
    
    let SERVICE_UUID = "FB694B90-F49E-4597-8306-171BBA78F846"
    let CHARACTERISTIC_UUID = "EB6727C4-F184-497A-A656-76B0CDAC633A"
    
    let user = PFUser.currentUser()
    var newConnection: String?{
        didSet{
            //Make all the Parse connection shit
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.navigationItem.title = "Seek Connection"
        centralManager.delegate = self
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
            print("on")
            centralManager.scanForPeripheralsWithServices([CBUUID(string: SERVICE_UUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        discoveredPeripheral = peripheral
        centralManager.connectPeripheral(peripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        centralManager.stopScan()
        peripheral.delegate = self
        if let service = peripheral.services?.first{
            peripheral.discoverCharacteristics([CBUUID(string: CHARACTERISTIC_UUID)], forService: service)
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        removeConnections()
        let alert = UIAlertController.createAlert("Error", withMessage: "Failed to connect to device.")
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if error != nil{
            print(error?.description)
            return
        }
        //might want to check for the correct UUID
        if let char = service.characteristics?.first{
            peripheral.setNotifyValue(true, forCharacteristic: char)
        }
    }
    
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
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if !characteristic.isNotifying{
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        discoveredPeripheral = nil
        print("connection lost")
    }
    
    func removeConnections(){
        if let peri = discoveredPeripheral{
            centralManager.cancelPeripheralConnection(peri)
        }
    }
    
}
