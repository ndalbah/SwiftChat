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
    
    func send() {
        guard let senderId = FirebaseManager.shared.user?.uid else { return }
        guard let recipientId = chatUser?.id else { return }
        guard let chatUser = chatUser else { return }
        
        let text = chatText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let image = imageToSend {
            uploadImage(image: image) { [weak self] imageUrl in
                guard let self = self, let imageUrl = imageUrl else { return }
                
                self.sendData(senderId: senderId, recipientId: recipientId, text: text, imageUrl: imageUrl, chatUser: chatUser)
                
                self.imageToSend = nil
                self.chatText = ""
                self.count += 1
            }
        } else if !text.isEmpty {
            sendData(senderId: senderId, recipientId: recipientId, text: text, imageUrl: "", chatUser: chatUser)
            self.chatText = ""
            self.count += 1
        }
    }
    
    private func sendData(senderId: String, recipientId: String, text: String, imageUrl: String, chatUser: ChatUser) {
        let messageData: [String : Any] = [
            "senderId": senderId,
            "recipientId": recipientId,
            "text": text,
            "imageUrl": imageUrl,
            "timestamp": Timestamp()
        ]
        
        FirebaseManager.shared.db.collection("messages")
            .document(senderId)
            .collection(recipientId)
            .document()
            .setData(messageData)
        
        FirebaseManager.shared.db.collection("messages")
            .document(recipientId)
            .collection(senderId)
            .document()
            .setData(messageData)
        
        let recentText: String
        if !imageUrl.isEmpty {
            recentText = "Image: \(text.isEmpty ? "" : text)"
        } else {
            recentText = text
        }
        
        saveRecentMessage(forUser: senderId, otherUser: chatUser, messageText: recentText)
    }
    
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
