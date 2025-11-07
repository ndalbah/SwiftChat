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
    @ObservedObject private var vm = MessagesViewModel()
    
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
            })
        }
    }
    @State var showChat = false
    var body: some View {
        
        NavigationStack {
            VStack {
                Navbar
                messagesView
            }
            .overlay(newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showChat) {
                if let chatUser = chatUser {
                    ChatView(chatUser: chatUser)
                }
            }
        }
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                VStack {
                    NavigationLink {
                        Text("chat")
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .padding(8)
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                    .stroke(Color(.label), lineWidth: 1)
                                )
                            
                            
                            VStack(alignment: .leading) {
                                Text("User")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Test message")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.lightGray))
                            }
                            Spacer()
                            
                            Text("14h")
                                .font(.system(size: 14, weight: .semibold))
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
            print("new message")
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
        .fullScreenCover(isPresented: $showNewMessageList){
            NewMessageView(didSelectUser: {user
                in
                print(user.email)
                self.showChat.toggle()
                self.chatUser = user
            })
        }
    }
    
    @State var chatUser: ChatUser?
}



#Preview {
    MessagesView()
        .environmentObject(FirebaseManager())
}
