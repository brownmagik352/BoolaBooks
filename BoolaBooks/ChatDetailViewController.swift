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
import Alamofire

class ChatDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK: - Properties
    
    // Outlets
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var sendMessageField: UITextField!
    @IBOutlet weak var markAsSoldButton: UIButton!
    
    
    // Class Variables
    var conversationID: Int?
    var listingID: Int?
    var sold: Bool?
    var ws: WebSocket?
    var messages: Array<String> = [] // actual text of messages
    var imageStrings: Array<String> = [] // image of message sender
    var names: Array<String> = [] // name of message sender
    
    // MARK: - Base Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.sold! {
            markAsSoldButton.setTitle("SOLD", for: .normal)
            markAsSoldButton.isEnabled = false
        }
        
        // call just to make sure the messages get marked as unread
        getConversationDetail(chatID: self.conversationID!)
        
        // initialize messages table & newMessage Field
        self.messagesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell") // required for tableViews embedded in UIViewControllers
        sendMessageField.delegate = self
        
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
                // if it is actual received message
                if text.range(of: "sender_name") != nil {
                    let encodedString : NSData = (text as NSString).data(using: String.Encoding.utf8.rawValue)! as NSData
                    var json = JSON(data: encodedString as Data)
                    self.messages.append("\(json["message"]["text"])")
                    self.imageStrings.append("\(json["message"]["sender_image"])")
                    self.names.append("\(json["message"]["sender_name"])")
                    self.messagesTableView.insertRows(at: [IndexPath(row: self.messages.count-1, section: 0)], with: .automatic)
                    self.messagesTableView.scrollToRow(at: IndexPath(row: self.messages.count-1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
                    
                    // mark incoming message as read (when already in an open chat)
                    let dataDict = ["message_id": "\(json["message"]["message_id"])", "action": "read_message"] as [String: Any?]
                    let dataJSON = JSON(dataDict)
                    let dataRawString = dataJSON.rawString()
                    
                    let identifierDict = ["channel": "ConversationsChannel", "conversation_id": self.conversationID!] as [String: Any?]
                    let identifierJSON = JSON(identifierDict)
                    let identifierRawString = identifierJSON.rawString()
                    
                    let dict = ["command": "message", "identifier": identifierRawString, "data": dataRawString ] as [String: Any?]
                    let json2 = JSON(dict)
                    let msg = json2.rawString()
                    
                    self.ws?.send(msg!)
                    print("Sent: \(msg!)")
                }
                print("RECEIVED:\(text)")
            }
        }
    }
    
    // scroll to the end of messages when first loading view
    override func viewDidAppear(_ animated: Bool) {
        if messages.count > 0 {
            messagesTableView.scrollToRow(at: IndexPath(row: messages.count-1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
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
    
    // MARK: - TableView Protocol
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MessageTableViewCell = self.messagesTableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell") as! MessageTableViewCell
        
        // get cell value
        let name = names[indexPath.row]
        let message = messages[indexPath.row]
        let imageString = imageStrings[indexPath.row]
        
        // Populate the label in the table cell
        cell.nameLabel.text = name
        cell.messageWordsLabel.text = message
        // Populate the image in the table cell
        if let url  = NSURL(string: imageString) {
            if let data = NSData(contentsOf: url as URL) {
                cell.senderImage.image = UIImage(data: data as Data)
            }
        }
        
        return cell
        
    }
    
    // MARK: - Moving Text Field Up When Using KB, UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(up: true, moveValue: 250)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(up: false, moveValue: 250)
    }
    
    // Lifting the view up
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    // Dismiss KB  - touch outside the field after editing has started
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sendMessageField.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    // MARK: - Actions

    @IBAction func sendMessage(_ sender: UIButton) {
        
        let dataDict = ["conversation_id": self.conversationID!, "text": sendMessageField.text, "action": "send_message"] as [String: Any?]
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
        sendMessageField.text = ""
        
    }

    @IBAction func markAsSold(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Are you sure?", message: "This action cannot be undone.", preferredStyle: UIAlertControllerStyle.alert)        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel",
                                                        style: .cancel) {
                                                            action -> Void in return
        }
        let yesAction: UIAlertAction = UIAlertAction(title: "Yes",
                                                         style: .default) {
                                                            action -> Void in self.markAsSoldAPI()
        }
        alert.addAction(cancelAction)
        alert.addAction(yesAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - BoolaBooks API Calls
    func getConversationDetail(chatID: Int) {
        
        let prefs = UserDefaults.standard
        let headers: HTTPHeaders = [
            "X-User-Email": prefs.string(forKey: "email")!,
            "X-User-Token": prefs.string(forKey: "rails_token")!,
            "Content-type": "application/json",
            "Accept": "application/json"
        ]
        
        Alamofire.request("https://boolabooks.herokuapp.com/api/v1/conversations/\(chatID)", headers: headers).responseJSON { response in
            
            if (response.result.error == nil) && ((response.response?.statusCode)! == 200) {
                print("**SUCCESSFUL CHAT DETAIL LOOKUP**")
            } else if ((response.response?.statusCode)! == 403) {
                print("403")
                let alert = UIAlertController(title: "You are not a part of this chat.", message: "Only a buyer and seller for a book can see the chat.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            } else if ((response.response?.statusCode)! == 401) {
                print("401")
                // force re-login
                return
            } else {
                print((response.response?.statusCode)!)
                let alert = UIAlertController(title: "Something went wrong.", message: "We're sorry, please try again later. Notify contact@boolabooks.com if the problem persists.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            // parse search results from JSON
            //            if let data = response.data {
            //                let json = JSON(data: data)
            //
            //                var messages: [String] = []
            //
            //                for i in 0..<json["messages"].count {
            //                    messages.append(json["messages"][i]["text"])
            //                }
            //            }
        }
    }
    
    func markAsSoldAPI() {
        let prefs = UserDefaults.standard
        let headers: HTTPHeaders = [
            "X-User-Email": prefs.string(forKey: "email")!,
            "X-User-Token": prefs.string(forKey: "rails_token")!,
            "Content-type": "application/json",
            "Accept": "application/json"
        ]
        
        let urlString = "https://boolabooks.herokuapp.com/api/v1/listings/sold/\(self.listingID!)"
        
        Alamofire.request(urlString, method: .post, headers: headers).responseJSON { response in
            if (response.result.error == nil) && ((response.response?.statusCode)! == 200) {
                print("**SUCCESSFUL MARK AS SOLD**")
                self.markAsSoldButton.setTitle("SOLD", for: .normal)
                self.markAsSoldButton.isEnabled = false
            } else if ((response.response?.statusCode)! == 403) {
                print("403")
                let alert = UIAlertController(title: "You are not the seller.", message: "Only the seller may mark an item as sold.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            } else if ((response.response?.statusCode)! == 401) {
                print("401")
                // force re-login
                return
            } else {
                print((response.response?.statusCode)!)
                let alert = UIAlertController(title: "Something went wrong.", message: "We're sorry, please try again later. Notify contact@boolabooks.com if the problem persists.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
    }
}
