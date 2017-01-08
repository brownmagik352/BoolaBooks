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
    var ws: WebSocket?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize WebSocket
        let prefs = UserDefaults.standard
        let urlWithParams = "wss://boolabooks.herokuapp.com/cable?token=\(prefs.string(forKey: "rails_token")!)&uid=\(prefs.string(forKey: "fb_uid")!)"
        let request = NSMutableURLRequest(url: NSURL(string: urlWithParams)! as URL)
        ws = WebSocket(request: request as URLRequest)
        
        // Connect to Channel
        ws?.event.open = {
            print("opened")
            
            let identifierDict = ["channel": "ConversationsChannel", "conversation_id": self.conversationID!] as [String: Any?]
            let identifierJSON = JSON(identifierDict)
            let identifierRawString = identifierJSON.rawString()
            let dict = ["command": "subscribe", "identifier": identifierRawString ] as [String: Any?]
            let json = JSON(dict)
            let msg = json.rawString()
            
            self.ws?.send(msg!)
        }
        
        // parse the messasge
        ws?.event.message = { message in
            if let text = message as? String {
                print("received: \(text)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // close channel connection when leaving chat
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController){
            ws?.close()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Actions

    @IBAction func sendMessage(_ sender: UIButton) {
        
        // hard-coded message right now
        let dataDict = ["conversation_id": self.conversationID!, "text": "iOS CLIENT", "action": "send_message"] as [String: Any?]
        let dataJSON = JSON(dataDict)
        let dataRawString = dataJSON.rawString()
        
        let identifierDict = ["channel": "ConversationsChannel", "conversation_id": self.conversationID!] as [String: Any?]
        let identifierJSON = JSON(identifierDict)
        let identifierRawString = identifierJSON.rawString()
        
        let dict = ["command": "message", "identifier": identifierRawString, "data": dataRawString ] as [String: Any?]
        let json = JSON(dict)
        let msg = json.rawString()
        
        self.ws?.send(msg!)
        print("Sent: \(msg!)")
        
    }
}
