//
//  FirebaseManager.swift
//  SwiftlyChat
//
//  Created by NRD on 04/11/2025.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseStorage
import UIKit
import FirebaseFirestore

class FirebaseManager: ObservableObject {
    @Published var user: User?
    @Published var currentChatUser: ChatUser?
    
    let storage: Storage
    var auth: Auth
    
    static let shared = FirebaseManager()
    let db = Firestore.firestore()
    
    
    init() {
        self.user = Auth.auth().currentUser
        self.storage = Storage.storage()
        self.auth = Auth.auth()
    }
    
    func register(email: String, password: String, image: UIImage?, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user{
                self.user = user
                self.saveImageToStorage(image: image)
                completion(.success(user))
            }
        }
        
    }
    
    func saveImageToStorage(image: UIImage?) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = storage.reference(withPath: uid)
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to push image to Storage: \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    print("Failed to download URL: \(error.localizedDescription)")
                    return
                }
                
                print("Image uploaded successfully!")
                
                guard let url = url else { return }
                self.storeUserInformation(profileImageUrl: url)
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error{
                completion(.failure(error))
            } else if let user = result?.user{
                self.user = user
                completion(.success(user))
            }
        }
    }
    
    func logout(){
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            print("Error Signing Out: \(error.localizedDescription)")
        }
    }
    
    func storeUserInformation(profileImageUrl: URL){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userData = ["email": self.user?.email, "uid": uid, "profileImageUrl": profileImageUrl.absoluteString]
        self.db.collection("users").document(uid).setData(userData as [String : Any]) { error in
            if let error = error {
                print("Error storing user data: \(error.localizedDescription)")
                return
            } else {
                print("User data successfully saved to Firestore.")
            }
        }
    }
}
