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

class ViewController: UIViewController {
    // https://github.com/pusher/pusher-websocket-swift/issues/109
    var pusher: Pusher!
    var center: UNUserNotificationCenter!
    var content: UNMutableNotificationContent!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
            print(data)
            //let _ = self.pusher.subscribe("test", onMemberAdded: onMemberAdded)
            
            if let data = data as? [String : AnyObject] {
                if let testVal = data["data"] as? String {
                    print(testVal)
                    // create notification and trigger it
                    self.content = UNMutableNotificationContent()
                    self.content.title = "RedAlert Notification"
                    self.content.body = testVal
                    self.content.sound = UNNotificationSound.default()
                    
                    // trigger notification in 1 second
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                                    repeats: false)
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: self.content, trigger: trigger)
                    self.center.add(request)
                    
                    // alert
                    let alertController = UIAlertController(title: "RedAlert", message:
                        testVal, preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Fermer", style: UIAlertActionStyle.default,handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        })

        print("notification\n")
        
        // initialize notifications center
        center = UNUserNotificationCenter.current()
        
        let notificationsOptions: UNAuthorizationOptions = [.alert, .sound];
        center.requestAuthorization(options: notificationsOptions) {
            (granted, error) in
            if !granted {
                print("Something went wrong while requesting notifications authorization")
            }
        }
        content = UNMutableNotificationContent()
        content.title = "RedAlert Notification"
        content.body = "CA MARCHE !"
        content.sound = UNNotificationSound.default()
        
        // trigger notification in 1 second
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10,
                                                        repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: self.content, trigger: trigger)
        center.add(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        performSegue(withIdentifier: "ConnectSegue", sender: self)
    }
}

