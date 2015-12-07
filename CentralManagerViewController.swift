//
//  CentralManagerViewController.swift
//  Connect
//
//  Created by Abiel Gutierrez on 12/6/15.
//  Copyright © 2015 Abiel Gutierrez. All rights reserved.
//

import UIKit
import CoreBluetooth

class CentralManagerViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var data = NSMutableData()
    var discoveredPeripheral: CBPeripheral?
    var centralManager = CBCentralManager()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.navigationItem.title = "Seek Connection"
        centralManager.delegate = self
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
            centralManager.scanForPeripheralsWithServices([CBUUID(string: "FB694B90-F49E-4597-8306-171BBA78F846")], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        discoveredPeripheral = peripheral
        centralManager.connectPeripheral(peripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        let alert = UIAlertController.createAlert("Error", withMessage: "Failed to connect to device.")
        presentViewController(alert, animated: true, completion: nil)
    }
    
}
