//
//  DevicesViewController.swift
//  RedAlert
//
//  Created by Jean-Thierry BONHOMME on 07/02/2018.
//  Copyright © 2018 Jean-Thierry BONHOMME. All rights reserved.
//

import UIKit
import CoreBluetooth

class DevicesViewController: UIViewController, BluetoothSerialDelegate {

    // BluetoothSerial Delegate stubs
    func serialDidReceiveString(_ message: String) {
    }
    
    func serialDidChangeState() {
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        serial.delegate = self
    }

    @IBAction func cancelPressed(_ sender: Any) {
        // exit the view
        dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
