//
//  NewMessageViewModel.swift
//  SwiftlyChat
//
//  Created by NRD on 05/11/2025.
//

import Foundation
import FirebaseFirestore

class NewMessageViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    
    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        FirebaseManager.shared.db.collection("users")
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    self.errorMessage = "Unable to fetch users: \(error)"
                    print("Unable to fetch users: \(error)")
                    return
                }
                
                documentsSnapshot?.documents.forEach({ snapshot in
                    do {
                        let user = try snapshot.data(as: ChatUser.self)
                        if user.id != FirebaseManager.shared.auth.currentUser?.uid {
                            self.users.append(user)
                        }
                    } catch {

                    }
                })
            }
    }
}
