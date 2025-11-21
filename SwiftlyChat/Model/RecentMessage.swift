//
//  RecentMessages.swift
//  SwiftlyChat
//
//  Created by NRD on 08/11/2025.
//

import Foundation
import Firebase
import FirebaseFirestore

struct RecentMessage: Codable, Identifiable {
    
    @DocumentID var id: String?
    
    let text, senderId, recipientId, email, profileImageUrl: String
    let timestamp: Date
    
    var username: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
