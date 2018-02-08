//
//  ViewController.swift
//  Red Alert
//
//  Created by Jean-Thierry BONHOMME on 04/02/2018.
//  Copyright © 2018 Jean-Thierry BONHOMME. All rights reserved.
//

import UIKit
import PusherSwift
import UserNotifications
import CoreBluetooth

class ViewController: UIViewController, BluetoothSerialDelegate, UNUserNotificationCenterDelegate, ModalHandler {
    // called when DevicesViewController dismiss
    func modalDismissed() {
        print("ViewController:modalDismissed")
        reloadView()
    }
    
    @IBOutlet weak var connectLabel: UIButton!
    
    // fix pusher issue : https://github.com/pusher/pusher-websocket-swift/issues/109
    var pusher: Pusher!

    // BluetoothSerial Delegate stubs
    func serialDidReceiveString(_ message: String) {
        print("ViewController:serialDidReceiveString")
    }

    func serialDidChangeState() {
        print("ViewController:serialDidChangeState")
        reloadView()
        if serial.centralManager.state != .poweredOn {
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = MBProgressHUDMode.text
            hud?.labelText = "Bluetooth turned off"
            hud?.hide(true, afterDelay: 1.0)
        }
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?) {
        print("ViewController:serialDidDisconnect")
        reloadView()
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Disconnected"
        hud?.hide(true, afterDelay: 1.0)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // initialize bluetooth-serial and get delegation for BluetoothSerial
        serial = BluetoothSerial(delegate: self)
        serial.delegate = self
        reloadView()

        // get delegation for UINotifications
        UNUserNotificationCenter.current().delegate = self

        // initialize pusher connection
        let pusherOptions = PusherClientOptions(
            host: .cluster("eu")
        )

        if let path = Bundle.main.path(forResource: "key", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let _key = jsonResult["key"] as? String {
                    // do stuff
                    pusher = Pusher(key: _key, options: pusherOptions)
                }
            } catch {
                // handle error
                print("Did not find app key in key.json file\n")
            }
        }
        
        print("connect pusher\n")
        pusher.connect()
        print("subscribe pusher\n")
        let myChannel = pusher.subscribe("test")
        print("bind pusher events\n")

        let _ = myChannel.bind(eventName: "foo", callback: { data in
            print(data as Any)
            //let _ = self.pusher.subscribe("test", onMemberAdded: onMemberAdded)
            
            if let data = data as? [String : AnyObject] {
                if let testVal = data["data"] as? String {
                    print(testVal)
                    // create notification and trigger it
                    let content = UNMutableNotificationContent()
                    content.title = "RedAlert Notification"
                    content.body = "Message:\n" + testVal
                    content.sound = UNNotificationSound.default()
                    content.badge = 1

                    // trigger notification in 5 second
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,
                                                                    repeats: false)
                    
                    let request = UNNotificationRequest(identifier: "redAlertNotification", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request,
                        withCompletionHandler: { (error) in
                            // Handle error
                            print("notification error:")
                            print(error as Any)
                    })
                }
            }
        })

        print("notification\n")
        
        // initialize notifications center
        let notificationsOptions: UNAuthorizationOptions = [.alert, .sound];
        UNUserNotificationCenter.current().requestAuthorization(options: notificationsOptions) {
            (granted, error) in
            if !granted {
                print("Something went wrong while requesting notifications authorization")
            }
        }
    }

    @objc func reloadView() {
        // in case we're the visible view again
        serial.delegate = self
        print("serial is ready ?")
        print(serial.isReady)
        if serial.isReady {
            connectLabel.setTitle("Disconnect", for: [])
            connectLabel.setTitleColor(UIColor.cyan, for: [])
        } else if serial.centralManager.state == .poweredOn {
            connectLabel.setTitle("Connect", for: [])
            connectLabel.setTitleColor(UIColor.white, for: [])
        } else {
            // alert
            let alertController = UIAlertController(title: "RedAlert", message:
            "Vous devez activer le bluetooth !", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Fermer", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)

            connectLabel.setTitle("-", for: [])
            connectLabel.setTitleColor(UIColor.red, for: [])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func bigRedButtonPressed(_ sender: Any) {
        print("**********************\n")
        print("*** BIG RED BUTTON ***\n")
        print("**********************\n")
        if serial.connectedPeripheral == nil {
            // alert
            let alertController = UIAlertController(title: "RedAlert", message:
                "Vous devez vous connecter à un périphérique bluetooth !", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Fermer", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
            connectLabel.setTitle("Connect", for: [])
            connectLabel.setTitleColor(UIColor.white, for: [])
        } else {
            serial.sendBytesToDevice([1])
        }
    }

    @IBAction func buttonPressed(_ sender: UIButton, forEvent event: UIEvent) {
        let text = "Connecting ..."
        print("**********************\n")
        print(text)
        print("**********************\n")
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Connecting"
        hud?.hide(true, afterDelay: 1.0)

        // open view DevicesView thanks to the "Connect Segue"
        if serial.connectedPeripheral == nil {
            performSegue(withIdentifier: "ConnectSegue", sender: self)
        } else {
            serial.disconnect()
            reloadView()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConnectSegue" {
            let destination = segue.destination as! DevicesViewController
            destination.delegate = self
        }
    }

}

