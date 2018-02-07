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
    @IBOutlet weak var debugLabel: UILabel!
    var pusher: Pusher!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let options = PusherClientOptions(
            host: .cluster("eu")
        )

        if let path = Bundle.main.path(forResource: "key", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let _key = jsonResult["key"] as? String {
                    // do stuff
                    pusher = Pusher(key: _key, options: options)
                }
            } catch {
                // handle error
                print("Did not find app key in key.json file\n")
                self.debugLabel.text = "Did not find app key in key.json file\n"
            }
        }
        
        print("connect pusher\n")
        pusher.connect()
        print("subscribe pusher\n")
        let myChannel = pusher.subscribe("test")
        print("bind pusher events\n")
        let _ = myChannel.bind(eventName: "foo", callback: { (data: Any?) -> Void in
            print("pusher events received\n")
            if let data = data as? [String : AnyObject] {
                if let message = data["message"] as? String {
                    print(message + "\n")
                    self.debugLabel.text = message
                }
            }
        })
        if #available(iOS 10.0, *) {
            print("notification\n")
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = "Late wake up call"
            content.body = "The early bird catches the worm, but the second mouse gets the cheese."
            content.categoryIdentifier = "alarm"
            content.userInfo = ["customData": "fizzbuzz"]
            content.sound = UNNotificationSound.default()
            
            var dateComponents = DateComponents()
            dateComponents.hour = 15
            dateComponents.minute = 49
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonPressed(_ sender: UIButton, forEvent event: UIEvent) {
        let text = "Connecting ..."
        debugLabel.text = text
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

