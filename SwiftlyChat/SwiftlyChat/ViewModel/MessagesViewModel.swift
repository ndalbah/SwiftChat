//
//  MessagesViewModel.swift
//  SwiftlyChat
//
//  Created by NRD on 04/11/2025.
//

import Foundation
import Combine
import FirebaseFirestore
import Firebase

class MessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserLoggedOut: Bool = false
    
    init(){
        self.isUserLoggedOut = FirebaseManager.shared.user?.uid == nil
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    @Published var recentMessages = [RecentMessage]()
    
    private var firestoreListener: ListenerRegistration?
    
    func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.user?.uid else { return }
        
        firestoreListener?.remove()
        
        firestoreListener = FirebaseManager.shared.db
            .collection("recent")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Failed: \(error.localizedDescription)")
                    return
                }
                
                self.recentMessages = snapshot?.documents.compactMap {
                    try? $0.data(as: RecentMessage.self)
                } ?? []
            }
    }
    
    
    func fetchCurrentUser(){
        guard let uid = FirebaseManager.shared.user?.uid else {
            self.errorMessage = "User ID not found!"
            return }
        
        FirebaseManager.shared.db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("unable to fetch current user: ", error)
                return
            }
            
            do {
                let chatUser = try snapshot?.data(as: ChatUser.self)
                self.chatUser = chatUser
            } catch {
                self.errorMessage = error.localizedDescription
            }
            
            if let chatUser = try? snapshot?.data(as: ChatUser.self) {
                self.chatUser = chatUser
                FirebaseManager.shared.currentChatUser = chatUser
            }
        }
    }
    
    func signOut() {
        isUserLoggedOut.toggle()
        do {
            try FirebaseManager.shared.auth.signOut()
            FirebaseManager.shared.user = nil
        } catch {
            
        }
    }
    
    func deleteChat(recent: RecentMessage) {
        guard let currentUserId = FirebaseManager.shared.user?.uid else { return }
        
        let otherUserId =
        (recent.senderId == currentUserId)
        ? recent.recipientId
        : recent.senderId
        
        FirebaseManager.shared.db
            .collection("recent")
            .document(currentUserId)
            .collection("messages")
            .document(otherUserId)
            .delete { error in
                if let error = error {
                    print("Failed to delete recent entry: \(error.localizedDescription)")
                } else {
                    print("Deleted recent entry for user: \(otherUserId)")
                }
            }
        
        FirebaseManager.shared.db
            .collection("messages")
            .document(currentUserId)
            .collection(otherUserId)
            .getDocuments { snapshot, _ in
                snapshot?.documents.forEach { $0.reference.delete() }
            }
        
        FirebaseManager.shared.db
            .collection("messages")
            .document(otherUserId)
            .collection(currentUserId)
            .getDocuments { snapshot, _ in
                snapshot?.documents.forEach { $0.reference.delete() }
            }
    }
    
    func updateProfileImage(_ image: UIImage) {
        
        guard let uid = FirebaseManager.shared.user?.uid else { return }
        
        guard let imageData = image.jpegData(compressionQuality: 0.4) else { return }
        
        let ref = FirebaseManager.shared.storage.reference(withPath: "profile_images/\(uid).jpg")
        
        ref.putData(imageData) { metadata, error in
            if let error = error {
                print("Failed to upload profile image:", error)
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL:", error)
                    return
                }
                
                guard let url = url else { return }
                
                FirebaseManager.shared.db
                    .collection("users")
                    .document(uid)
                    .updateData(["profileImageUrl": url.absoluteString]) { error in
                        if let error = error {
                            print("Failed to update Firestore:", error)
                            return
                        }
                        
                        print("Updated profile picture!")
                        
                        DispatchQueue.main.async {
                            self.chatUser?.profileImageUrl = url.absoluteString
                            FirebaseManager.shared.currentChatUser?.profileImageUrl = url.absoluteString
                        }
                    }
            }
        }
    }
    
}
