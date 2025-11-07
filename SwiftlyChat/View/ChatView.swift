//
//  ChatView.swift
//  SwiftlyChat
//
//  Created by NRD on 05/11/2025.
//

import SwiftUI

struct ChatView: View {
    
    @ObservedObject var vm: ChatViewModel
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?){
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }
    
    var body: some View {
        VStack{
//            Text(vm.errorMessage)
            ScrollView{
                ForEach(0..<20){ num in
                    HStack{
                        Spacer()
                        HStack{
                            Text("Testing message \(num)")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }.padding(.horizontal)
                        .padding(.top,1)
                }
                
                HStack{
                    Spacer()
                }
                
            }.background(Color(.init(white: 0.80, alpha: 1)))
            HStack(spacing: 16){
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 24))
                    .foregroundColor(Color(.darkGray))
                ZStack {
                    
                    HStack {
                        Text("Message")
                            .foregroundColor(Color(.gray))
                            .font(.system(size: 17))
                            .padding(.leading, 5)
                            .padding(.top, -4)
                        Spacer()
                    }
                    
                    TextEditor(text: $vm.chatText)
                        .opacity(vm.chatText.isEmpty ? 0.5 : 1)
                        .frame(height: 40)
                }
                
                Button {
                    vm.send()
                } label: {
                    Text("Send")
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(40)
            }.padding(.horizontal)
                .padding(.vertical, 8)
            
        }.navigationTitle(chatUser?.email ?? "")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    //    NavigationView {
    //        ChatView(chatUser: .init(id: "61sn7sWMwoQ341NgcPmWoWQWBj82", email: "hello@gmail.com", profileImageUrl: "https://firebasestorage.googleapis.com:443/v0/b/swiftlychat-c5643.firebasestorage.app/o/PaWgdq17M8f5IxRUOEU9HPLys8U2?alt=media&token=ac624dfe-c17d-4576-8087-1bfe30b03049"))
    //    }
    MessagesView()
}
