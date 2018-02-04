//
//  ViewController.swift
//  Red Alert
//
//  Created by Jean-Thierry BONHOMME on 04/02/2018.
//  Copyright © 2018 Jean-Thierry BONHOMME. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var debugLabel: UILabel!
    
    @IBAction func buttonPressed(_ sender: UIButton, forEvent event: UIEvent) {
        let text = "Connecting ..."
        debugLabel.text = text
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud?.mode = MBProgressHUDMode.text
        hud?.labelText = "Connecting"
        hud?.hide(true, afterDelay: 1.0)
    }
}

