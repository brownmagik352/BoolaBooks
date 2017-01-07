//
//  ChatDetailViewController.swift
//  BoolaBooks
//
//  Created by Apurv Suman on 1/7/17.
//  Copyright © 2017 Apurv Suman. All rights reserved.
//

import UIKit
import SwiftWebSocket
import SwiftyJSON

class ChatDetailViewController: UIViewController {
    
    // MARK: - Properties
    var conversationID: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chat()

        // Do any additional setup after loading the view.
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
    
    // MARK: - BoolaBooks API Calls
    
    func chat() {

        let prefs = UserDefaults.standard
        let urlWithParams = "wss://boolabooks.herokuapp.com/cable?token=\(prefs.string(forKey: "rails_token")!)&uid=\(prefs.string(forKey: "fb_uid")!)"
        let request = NSMutableURLRequest(url: NSURL(string: urlWithParams)! as URL)
        
        let ws = WebSocket(request: request as URLRequest)
        let send : ()->() = {
            
            // hard-coded need to update
            let dict1 = ["channel": "ConversationsChannel", "conversation_id": self.conversationID!] as [String: Any?]
            let json1 = JSON(dict1)
            let rawJSON1 = json1.rawString()
            let dict = ["command": "subscribe", "identifier": rawJSON1 ] as [String: Any?]
            let json = JSON(dict)
            let msg = json.rawString()
            
            ws.send(msg!)
        }
        
//        ws.event.open = {
//            print("opened")
//            send()
//        }
//        
//        ws.event.close = { code, reason, clean in
//            print("close")
//        }
        
        ws.event.error = { error in
            print("error \(error)")
        }
        
        // parse the messasge
        ws.event.message = { message in
            if let text = message as? String {
                print("recv: \(text)")
            }
        }
    }

}
