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
    
    func fetchRecentMessages(){
        guard let uid = FirebaseManager.shared.user?.uid else { return }
        
        firestoreListener?.remove()
        self.recentMessages.removeAll()
        
        firestoreListener = FirebaseManager.shared.db.collection("recent")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for recent messages: \(error)"
                    print( "Failed to listen for recent messages: \(error)")
                    return
                }
                
                querySnapshot?.documentChanges.forEach { change in
                        let docId = change.document.documentID
                    if let index = self.recentMessages.firstIndex(where: {
                        rm in
                        return rm.id == docId
                    }){
                        self.recentMessages.remove(at: index)
 
                    }
                    
                    if let rm = try? change.document.data(as: RecentMessage.self) {
                        self.recentMessages.insert(rm, at: 0)
                    }
                }
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
}
