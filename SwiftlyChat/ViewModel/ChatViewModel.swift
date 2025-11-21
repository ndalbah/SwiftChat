//
//  ChatViewModel.swift
//  SwiftlyChat
//
//  Created by NRD on 05/11/2025.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

class ChatViewModel: ObservableObject{
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    @Published var imageToSend: UIImage?
    @Published var chatUser: ChatUser?

    init(chatUser: ChatUser?){
        self.chatUser = chatUser
        
        //fetchMessages()
    }
    
    var firestoreListener: ListenerRegistration?
    
    private func uploadImage(image: UIImage, completion: @escaping (String?) -> Void) {
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                completion(nil)
                return
            }
            
            let filename = UUID().uuidString
            let storageRef = FirebaseManager.shared.storage.reference(withPath: "/chat_images/\(filename)")
            
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Failed to upload image: \(error)")
                    self.errorMessage = "Failed to upload image: \(error)"
                    completion(nil)
                    return
                }
                
                storageRef.downloadURL { url, _ in
                    completion(url?.absoluteString)
                }
            }
        }
    
    func fetchMessages(){
        guard let senderId = FirebaseManager.shared.user?.uid else {return}
        guard let recepientId = chatUser?.id else { return }
        
        firestoreListener = FirebaseManager.shared.db
            .collection("messages")
            .document(senderId)
            .collection(recepientId)
            .order(by: "timestamp")
            .addSnapshotListener{querySnapshot, error in
                if let error = error{
                    self.errorMessage = "Failed to listen for messages \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added{
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
                    }
                })
                
                DispatchQueue.main.async {
                    self.count += 1
                }
                
            }
    }
    
//    func send(){
//        print(chatText)
//        guard let senderId = FirebaseManager.shared.user?.uid else {return}
//        guard let recipientId = chatUser?.id else {return}
//        print(recipientId)
//        
//        let document = FirebaseManager.shared.db.collection("messages")
//            .document(senderId)
//            .collection(recipientId)
//            .document()
//        
//        let messageData = ["senderId": senderId, "recipientId": recipientId, "text": chatText, "timestamp": Timestamp()] as [String : Any]
//        
//        document.setData(messageData){ error in
//            if let error = error {
//                self.errorMessage = "saving sender message failed \(error)"
//                return
//            }
//            
//            print("sent message saved")
//            
//            self.saveRecentMessage()
//            
//            self.chatText = ""
//            self.count += 1
//        }
//        
//        let recipientDocument = FirebaseManager.shared.db.collection("messages")
//            .document(recipientId)
//            .collection(senderId)
//            .document()
//        
//        recipientDocument.setData(messageData){ error in
//            if let error = error {
//                self.errorMessage = "saving recipient message failed \(error)"
//                return
//            }
//            print("received message saved")
//        }
//    }

//    func send() {
//        guard let senderId = FirebaseManager.shared.user?.uid else { return }
//        guard let recipientId = chatUser?.id else { return }
//        guard let chatUser = chatUser else { return }
//
//        let text = chatText
//
//        let messageData: [String : Any] = [
//            "senderId": senderId,
//            "recipientId": recipientId,
//            "text": text,
//            "timestamp": Timestamp()
//        ]
//
//        // Save message under sender
//        FirebaseManager.shared.db.collection("messages")
//            .document(senderId)
//            .collection(recipientId)
//            .document()
//            .setData(messageData)
//
//        // Save message under recipient
//        FirebaseManager.shared.db.collection("messages")
//            .document(recipientId)
//            .collection(senderId)
//            .document()
//            .setData(messageData)
//
//        // 🔥 SINGLE FUNCTION used for both sides
//        saveRecentMessage(forUser: senderId, otherUser: chatUser, messageText: text)
//        
//        if let currentUser = FirebaseManager.shared.currentChatUser {
//            saveRecentMessage(
//                forUser: recipientId,
//                otherUser: currentUser,   // sender user with correct profileImageUrl
//                messageText: text
//            )
//        }
//
//        chatText = ""
//        count += 1
//    }

    // ChatViewModel.swift

        func send() {
            guard let senderId = FirebaseManager.shared.user?.uid else { return }
            guard let recipientId = chatUser?.id else { return }
            guard let chatUser = chatUser else { return }

            let text = chatText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 1. Check for image
            if let image = imageToSend {
                uploadImage(image: image) { [weak self] imageUrl in
                    guard let self = self, let imageUrl = imageUrl else { return }
                    
                    self.sendData(senderId: senderId, recipientId: recipientId, text: text, imageUrl: imageUrl, chatUser: chatUser)
                    
                    // Clear state
                    self.imageToSend = nil
                    self.chatText = ""
                    self.count += 1
                }
            } else if !text.isEmpty {
                // 2. Fallback to text only
                sendData(senderId: senderId, recipientId: recipientId, text: text, imageUrl: "", chatUser: chatUser)
                self.chatText = ""
                self.count += 1
            }
        }
        
        // 🔥 NEW HELPER: Consolidates Firestore saving logic
    private func sendData(senderId: String, recipientId: String, text: String, imageUrl: String, chatUser: ChatUser) {
        let messageData: [String : Any] = [
            "senderId": senderId,
            "recipientId": recipientId,
            "text": text,
            "imageUrl": imageUrl, // 👈 New field
            "timestamp": Timestamp()
        ]
        
        // Save message under sender
        FirebaseManager.shared.db.collection("messages").document(senderId).collection(recipientId).document().setData(messageData)
        
        // Save message under recipient
        FirebaseManager.shared.db.collection("messages").document(recipientId).collection(senderId).document().setData(messageData)
        
        // Update recent message (use a simple tag for images)
        let recentText: String
        if !imageUrl.isEmpty {
            // If there's an image, use "Image" plus the caption (if any)
            recentText = "Image: \(text.isEmpty ? "" : text)"
        } else {
            // Otherwise, use the text
            recentText = text
        }
        
        saveRecentMessage(forUser: senderId, otherUser: chatUser, messageText: recentText)
        if let currentUser = FirebaseManager.shared.currentChatUser {
            saveRecentMessage(forUser: recipientId, otherUser: currentUser, messageText: recentText)
        }
    }

    // ...
//    private func saveRecentMessage(){
//        
//        guard let chatUser = chatUser else { return }
//        guard let uid = FirebaseManager.shared.user?.uid else {return}
//        guard let recipientId = self.chatUser?.id else {return}
//        
//        let document = FirebaseManager.shared.db.collection("recent")
//            .document(uid)
//            .collection("messages")
//            .document(recipientId)
//        
//        let data = [
//            "timestamp": Timestamp(),
//            "text": self.chatText,
//            "senderId": uid,
//            "recipientId": recipientId,
//            "profileImageUrl": chatUser.profileImageUrl,
//            "email": chatUser.email
//        ] as [String : Any]
//        
//        
//        
//        document.setData(data) { error in
//            if let error = error {
//                self.errorMessage = "Failed to save recent message: \(error)"
//                print("Failed to save recent message: \(error)")
//                return
//            }
//        }
//            
//    }
    
    private func saveRecentMessage(
        forUser userId: String,
        otherUser: ChatUser,
        messageText: String
    ) {
        let document = FirebaseManager.shared.db.collection("recent")
            .document(userId)
            .collection("messages")
            .document(otherUser.id ?? "")

        let data: [String : Any] = [
            "timestamp": Timestamp(),
            "text": messageText,
            "senderId": userId,
            "recipientId": otherUser.id ?? "",
            "profileImageUrl": otherUser.profileImageUrl,
            "email": otherUser.email
        ]

        document.setData(data)
    }

    
    @Published var count = 0
}
