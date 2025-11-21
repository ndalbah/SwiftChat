//
//  ChatMessage.swift
//  SwiftlyChat
//
//  Created by NRD on 08/11/2025.
//

import Foundation
import FirebaseFirestore

struct ChatMessage: Identifiable{
    var id: String { documentId }
//    @DocumentID var id: String?
    
    let documentId: String
    let senderId, recipientId, text, timestamp, imageUrl: String
    
    init(documentId: String, data: [String: Any]){
        self.documentId = documentId
        self.senderId = data["senderId"] as? String ?? ""
        self.recipientId = data["recipientId"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        self.timestamp = data["timestamp"] as? String ?? ""
        self.imageUrl = data["imageUrl"] as? String ?? ""
    }
    
//    @DocumentID var id: String?
//    let senderId: String
//    let recipientId: String
//    let text: String
//    let timestamp: Date
}


