//
//  User.swift
//  SwiftlyChat
//
//  Created by NRD on 04/11/2025.
//

import Foundation
import FirebaseFirestore

struct ChatUser: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
    var profileImageUrl: String
}
