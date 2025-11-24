//
//  RecentMessageCard.swift
//  SwiftlyChat
//
//  Created by NRD on 20/11/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct RecentMessageCard: View {
    let recentMessage: RecentMessage
    
    var body: some View {
        HStack(spacing: 16) {
            WebImage(url: URL(string: recentMessage.profileImageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipped()
                .cornerRadius(64)
                .overlay(RoundedRectangle(cornerRadius: 64)
                            .stroke(Color.black, lineWidth: 1))
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(recentMessage.username)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(.label))
                    .multilineTextAlignment(.leading)
                
                Text(recentMessage.text)
                    .font(.system(size: 14))
                    .foregroundColor(Color(.darkGray))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(recentMessage.timeAgo)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(.label))
        }
    }
}

//
//#Preview {
//    RecentMessageCard(recentMessage: <#RecentMessage#>)
//}
