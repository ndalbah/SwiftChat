//
//  MessagesView.swift
//  SwiftlyChat
//
//  Created by NRD on 04/11/2025.
//

import SwiftUI
import SDWebImageSwiftUI



struct MessagesView: View {

    @State var showLogout = false
    @State var showChatLog = false
    @ObservedObject private var vm = MessagesViewModel()
    @State private var chatViewModel: ChatViewModel? = nil

    private var Navbar: some View {
        HStack(spacing: 16) {
            if(vm.chatUser?.profileImageUrl != nil){
                WebImage(url: URL(string: vm.chatUser?.profileImageUrl ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipped()
                    .cornerRadius(50)
                    .overlay(RoundedRectangle(cornerRadius: 44).stroke(Color(.label), lineWidth: 1))
                    .shadow(radius: 5)
            } else{
                Image(systemName: "person.fill")
                    .font(.system(size: 34, weight: .heavy))
            }
            
            
            
            
            VStack(alignment: .leading, spacing: 4) {
                let email = vm.chatUser?.email ?? "" //.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                
                Text("\(email)")
                    .font(.system(size: 24, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
                
            }
            
            Spacer()
            Button {
                showLogout.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $showLogout) {
            .init(title: Text("Settings"), message: Text("Are you sure you want to sign out?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("sign out")
                    vm.signOut()
                }),
                .cancel()
            ])
        }.fullScreenCover(isPresented: $vm.isUserLoggedOut, onDismiss: nil){
            LoginView(isLoggedIn: {
                self.vm.isUserLoggedOut = false
                self.vm.fetchCurrentUser()
                self.vm.fetchRecentMessages()
            })
        }
    }
    @State var showChat = false
    var body: some View {
        
        NavigationView {
            
            VStack {
                Navbar
                messagesView
                
                NavigationLink("", isActive: $showChatLog) {
                    if let vm = chatViewModel {
                        ChatView(vm: vm)
                    }
                }
            }
            .overlay(
                newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    private var messagesView: some View {
//        ScrollView {
//            ForEach(vm.recentMessages) { recentMessage in
//                VStack {
//                    NavigationLink {
//                        Text("chat")
//                    } label: {
//                        HStack(spacing: 16) {
//                            WebImage(url: URL(string: recentMessage.profileImageUrl))
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 64, height: 64)
//                                .clipped()
//                                .cornerRadius(64)
//                                .overlay(RoundedRectangle(cornerRadius: 64)
//                                    .stroke(Color.black, lineWidth: 1))
//                                .shadow(radius: 5)
//                            
//                            
//                            VStack(alignment: .leading, spacing: 8) {
//                                Text(recentMessage.username)
//                                    .font(.system(size: 16, weight: .bold))
//                                    .foregroundColor(Color(.label))
//                                    .multilineTextAlignment(.leading)
//                                Text(recentMessage.text)
//                                    .font(.system(size: 14))
//                                    .foregroundColor(Color(.darkGray))
//                                    .multilineTextAlignment(.leading)
//                            }
//                            Spacer()
//                            
//                            Text(recentMessage.timeAgo)
//                                .font(.system(size: 14, weight: .semibold))
//                                .foregroundColor(Color(.label))
//                        }
//                    }
//                    
//                    
//                    Divider()
//                        .padding(.vertical, 8)
//                }.padding(.horizontal)
//                
//            }.padding(.bottom, 50)
//        }
        
        ScrollView {
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                    Button {
                        let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.senderId ? recentMessage.recipientId : recentMessage.senderId
                        
                        self.chatUser = .init(id: uid, email: recentMessage.email, profileImageUrl: recentMessage.profileImageUrl)
                        
                        self.chatViewModel = ChatViewModel(chatUser: self.chatUser)
                        self.chatViewModel?.fetchMessages()

                        self.showChatLog = true
                    } label: {
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
                            }
                            Spacer()
                            
                            Text(recentMessage.timeAgo)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(.label))
                        }
                    }


                    
                    Divider()
                        .padding(.vertical, 8)
                }.padding(.horizontal)
                
            }.padding(.bottom, 50)
        }

    }
    

    @State var showNewMessageList = false
    
    private var newMessageButton: some View {
        Button {
            showNewMessageList.toggle()
        } label: {
            HStack {
                Spacer()
                Text("+ New Chat")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(Color.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 15)
        }
        .fullScreenCover(isPresented: $showNewMessageList) {
            NewMessageView(didSelectUser: { user in
                print(user.email)

                self.chatUser = user
                self.chatViewModel = ChatViewModel(chatUser: user)
                self.chatViewModel?.fetchMessages()

                self.showNewMessageList = false
                self.showChatLog = true
            })
        }
    }

    
    @State var chatUser: ChatUser?
}



#Preview {
    MessagesView()
        .environmentObject(FirebaseManager())
}
