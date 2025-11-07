//
//  MessagesViewModel.swift
//  SwiftlyChat
//
//  Created by NRD on 04/11/2025.
//

import Foundation
import Combine
import FirebaseFirestore

class MessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserLoggedOut: Bool = false
    
    init(){
        self.isUserLoggedOut = FirebaseManager.shared.user?.uid == nil
        fetchCurrentUser()
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
