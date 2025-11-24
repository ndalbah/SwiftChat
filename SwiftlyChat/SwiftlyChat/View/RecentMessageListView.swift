// RecentMessageListView.swift (Equivalent to TopSellingView)

import SwiftUI

struct RecentMessageListView: View {
    @ObservedObject var vm: MessagesViewModel
    
    @Binding var showChatLog: Bool
    @Binding var chatViewModel: ChatViewModel?
    @State private var selectedChatUser: ChatUser?
    
    var body: some View {
        List {
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                    Button {
                        let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.senderId ? recentMessage.recipientId : recentMessage.senderId
                        
                        let user = ChatUser(id: uid, email: recentMessage.email, profileImageUrl: recentMessage.profileImageUrl)
                        
                        self.chatViewModel = ChatViewModel(chatUser: user)
                        self.chatViewModel?.fetchMessages()
                        
                        self.showChatLog = true
                    } label: {
                        RecentMessageCard(recentMessage: recentMessage)
                            .foregroundColor(Color(.label))
                    }.buttonStyle(PlainButtonStyle())
                }
            }.onDelete(perform: deleteRecent)
        }.listStyle(PlainListStyle())
    }
    
    private func deleteRecent(at offsets: IndexSet) {
        offsets.forEach { index in
            let rm = vm.recentMessages[index]
            vm.deleteChat(recent: rm)
        }
    }
    
}

//#Preview {
//    RecentMessageListView(vm: <#MessagesViewModel#>, showChatLog: <#Binding<Bool>#>, chatViewModel: <#Binding<ChatViewModel?>#>)
//}
//}
