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
    var characteristic: CBMutableCharacteristic?
    var sentData = NSData()
    let dataIndex = NSInteger()
    
    let SERVICE_UUID = "FB694B90-F49E-4597-8306-171BBA78F846"
    let CHARACTERISTIC_UUID = "EB6727C4-F184-497A-A656-76B0CDAC633A"
    
    let user = PFUser.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Create Connection"
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        sentData = ("Alberto").dataUsingEncoding(NSUTF8StringEncoding)!
        peripheralManager!.startAdvertising([CBAdvertisementDataServiceUUIDsKey:CBUUID(string:SERVICE_UUID)])
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        print("got here")
        if peripheral.state != CBPeripheralManagerState.PoweredOn{
            print("SUPPORT BLUETOOTH")
            return
        }
        
        if peripheral.state != CBPeripheralManagerState.PoweredOn{
            characteristic = CBMutableCharacteristic(type: CBUUID(string: CHARACTERISTIC_UUID), properties: CBCharacteristicProperties.Notify, value: sentData, permissions: CBAttributePermissions.Readable)
            let service = CBMutableService(type: CBUUID(string: SERVICE_UUID), primary: true)
            service.characteristics = [characteristic!]
            peripheralManager!.addService(service)
            print("service added")
        }
    }
}
