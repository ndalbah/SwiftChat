//
//  ChatViewModel.swift
//  SwiftlyChat
//
//  Created by NRD on 05/11/2025.
//

import Foundation

class ChatViewModel: ObservableObject{
    @Published var chatText = ""
    @Published var errorMessage = ""
    let chatUser: ChatUser?
    init(chatUser: ChatUser?){
        self.chatUser = chatUser
    }
    
    func send(){
        print(chatText)
        guard let senderId = FirebaseManager.shared.user?.uid else {return}
        guard let recepientId = chatUser?.id else {return}
        print(recepientId)
        
        let document = FirebaseManager.shared.db.collection("messages")
            .document("sender " + senderId)
            .collection("recepient " + recepientId)
            .document()
        
        let messageData = ["senderId": senderId, "recipientId": recepientId, "text": chatText]
        document.setData(messageData){ error in
            if let error = error {
                self.errorMessage = "saving sender message failed \(error)"
                return
            }
            
            print("sent message saved")
            self.chatText = ""
        }
        
        let recipientDocument = FirebaseManager.shared.db.collection("messages")
            .document("recipient " + recepientId)
            .collection("sender " + senderId)
            .document()
        
        recipientDocument.setData(messageData){ error in
            if let error = error {
                self.errorMessage = "saving recipient message failed \(error)"
                return
            }
            print("received message saved")
        }
    }
}
