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
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?

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
                    .onTapGesture {
                        showImagePicker = true
                    }
            } else{
                Image(systemName: "person.fill")
                    .font(.system(size: 34, weight: .heavy))
            }
            
            
            
            
            VStack(alignment: .leading, spacing: 4) {
                let email = vm.chatUser?.email ?? "you"
                
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
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .onChange(of: selectedImage) { newImage in
                if let img = newImage {
                    vm.updateProfileImage(img)
                }
            }
        }
    }
    
    private var messagesView: some View {
        RecentMessageListView(
            vm: vm,
            showChatLog: $showChatLog,
            chatViewModel: $chatViewModel)
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
