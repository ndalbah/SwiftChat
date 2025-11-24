//
//  ChatView.swift
//  SwiftlyChat
//
//  Created by NRD on 05/11/2025.
//

import SwiftUI

struct ChatView: View {
    
    @ObservedObject var vm: ChatViewModel
    @State private var showImagePicker = false;
    
    var body: some View {
        VStack{
            if let image = vm.imageToSend {
                HStack(alignment: .top) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipped()
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading) {
                        Text("Image selected. Add caption below or send.")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Button("Remove Image") {
                            vm.imageToSend = nil
                        }
                        .foregroundColor(.red)
                    }
                    Spacer()
                }
                .padding([.horizontal, .top])
            }
            
            ScrollView {
                ScrollViewReader{ scrollViewProxy in
                    VStack{
                        ForEach(vm.chatMessages){message in
                            VStack{
                                if message.senderId == FirebaseManager.shared.auth.currentUser?.uid{
                                    HStack(alignment: .bottom){
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            if !message.imageUrl.isEmpty, let url = URL(string: message.imageUrl) {
                                                AsyncImage(url: url) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(maxWidth: 200, maxHeight: 200)
                                                        .cornerRadius(8)
                                                } placeholder: {
                                                    ProgressView()
                                                        .frame(width: 100, height: 100)
                                                }
                                            }
                                            
                                            if !message.text.isEmpty {
                                                Text(message.text)
                                                    .foregroundColor(.white)
                                                    .padding()
                                                    .background(Color.blue)
                                                    .cornerRadius(10)
                                            }
                                        }
                                    }
                                } else {
                                    HStack(alignment: .bottom){
                                        VStack(alignment: .leading, spacing: 4) {
                                            if !message.imageUrl.isEmpty, let url = URL(string: message.imageUrl) {
                                                AsyncImage(url: url) { image in
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(maxWidth: 200, maxHeight: 200)
                                                        .cornerRadius(8)
                                                } placeholder: {
                                                    ProgressView()
                                                        .frame(width: 100, height: 100)
                                                }
                                            }
                                            
                                            if !message.text.isEmpty {
                                                Text(message.text)
                                                    .foregroundColor(.black)
                                                    .padding()
                                                    .background(Color.white)
                                                    .cornerRadius(10)
                                            }
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                        }
                        HStack { Spacer() }
                        .id("Empty")
                    }
                    .onReceive(vm.$count){ _ in
                        withAnimation(.easeOut(duration: 0.5)) {
                            scrollViewProxy.scrollTo("Empty", anchor: .bottom)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(Color(.init(white: 0.80, alpha: 1)))
            
            HStack(spacing: 16){
                
                Button {
                    showImagePicker.toggle()
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 24))
                        .foregroundColor(Color(.darkGray))
                }
                .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil){
                    ImagePicker(image: $vm.imageToSend)
                }
                
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
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
        }
        .navigationTitle(vm.chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible)
        .onDisappear{
            vm.firestoreListener?.remove()
        }
    }
}

#Preview {
    MessagesView()
}
