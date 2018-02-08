//
//  DevicesViewController.swift
//  RedAlert
//
//  Created by Jean-Thierry BONHOMME on 07/02/2018.
//  Copyright © 2018 Jean-Thierry BONHOMME. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol ModalHandler {
    func modalDismissed()
}

final class DevicesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BluetoothSerialDelegate {
    var delegate : ModalHandler! = nil

    @IBOutlet weak var tableView: UITableView!

    /// The peripherals that have been discovered (no duplicates and sorted by asc RSSI)
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
    
    /// The peripheral the user has selected
    var selectedPeripheral: CBPeripheral?
    
    /// Progress hud shown
    var progressHUD: MBProgressHUD?

//MARK: Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        serial.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        
        if serial.centralManager.state != .poweredOn {
            title = "Bluetooth not turned on"
            return
        }
        
        // start scanning and schedule the time out
        serial.startScan()
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(DevicesViewController.scanTimeOut), userInfo: nil, repeats: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Should be called 10s after we've begun scanning
    @objc func scanTimeOut() {
        // timeout has occurred, stop scanning and give the user the option to try again
        serial.stopScan()
        title = "Done scanning"
        print("DevicesViewController:scanTimeOut")
    }
    
    /// Should be called 10s after we've begun connecting
    @objc func connectTimeOut() {
        
        // don't if we've already connected
        if let _ = serial.connectedPeripheral {
            return
        }
        
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        if let _ = selectedPeripheral {
            serial.disconnect()
            selectedPeripheral = nil
        }
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Failed to connect"
        hud?.hide(true, afterDelay: 2)
    }

//MARK: IBActions

    @IBAction func cancelPressed(_ sender: Any) {
        // exit the view
        dismiss(animated: true, completion: nil)
    }
    
//MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("tableView numberOfSections: 1")
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tableView numberOfRowsInSection:")
        print(peripherals.count)
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // return a cell with the peripheral name as text in the label
        print("tableView cellForRowAt:")
        print(indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        print("peripherals[(indexPath as NSIndexPath).row].peripheral.name:")
        print(peripherals[(indexPath as NSIndexPath).row].peripheral.name)

        cell.textLabel?.text = peripherals[(indexPath as NSIndexPath).row].peripheral.name
        return cell
    }
    
    
//MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // the user has selected a peripheral, so stop scanning and proceed to the next view
        print("the user has selected a peripheral, so stop scanning and proceed to the next view")
        serial.stopScan()
        selectedPeripheral = peripherals[(indexPath as NSIndexPath).row].peripheral
        print("connect to:")
        print(selectedPeripheral)
        serial.connectToPeripheral(selectedPeripheral!)
        progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        progressHUD!.labelText = "Connecting"
        
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(DevicesViewController.connectTimeOut), userInfo: nil, repeats: false)
    }

//MARK: BluetoothSerialDelegate
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?) {
        print("DevicesViewController:serialDidDiscoverPeripheral")
        print(peripheral.identifier)
        print(peripheral.name!)
        print(peripheral.state)
        // check whether it is a duplicate
        for exisiting in peripherals {
            if exisiting.peripheral.identifier == peripheral.identifier { return }
            print("peripheral already recorded")
        }
        
        // add to the array, next sort & reload
        let theRSSI = RSSI?.floatValue ?? 0.0
        print("record this peripheral")
        peripherals.append((peripheral: peripheral, RSSI: theRSSI))
        peripherals.sort { $0.RSSI < $1.RSSI }
        print("peripherals:")
        print(peripherals)
        print("reload the tableview")
        tableView.reloadData()
    }
    
    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?) {
        print("DevicesViewController:serialDidFailToConnect")
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Failed to connect"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        print("DevicesViewController:serialDidDisconnect")
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Failed to connect"
        hud?.hide(true, afterDelay: 1.0)
        
    }
    
    func serialIsReady(_ peripheral: CBPeripheral) {
        print("DevicesViewController:serialIsReady")
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadStartViewController"), object: self)
        dismiss(animated: true) {
            print("DevicesViewController:serialIsReady:dismiss")
            self.delegate?.modalDismissed()
        }
    }
    
    func serialDidChangeState() {
        print("DevicesViewController:serialDidChangeState")
        if let hud = progressHUD {
            hud.hide(false)
        }
        
        if serial.centralManager.state != .poweredOn {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadStartViewController"), object: self)
            dismiss(animated: true, completion: nil)
        }
    }
    
}
