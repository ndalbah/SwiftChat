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
                VStack(spacing: 0) {
                    ForEach(vm.chatMessages){message in
                        VStack{
                            if message.senderId == FirebaseManager.shared.auth.currentUser?.uid{
                                // --- SENDER (BLUE BUBBLE) ---
                                HStack(alignment: .bottom){ // Align items to the bottom (text bubble below image)
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        
                                        // 1. Image Content (No background/padding here)
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
                                        
                                        // 2. Text Content (Apply background/padding only to the text)
                                        if !message.text.isEmpty {
                                            Text(message.text)
                                                .foregroundColor(.white)
                                                .padding() // Padding inside the bubble
                                                .background(Color.blue) // Blue background for text
                                                .cornerRadius(10) // Rounded corners for text bubble
                                        }
                                    }
                                }
                            } else {
                                // --- RECEIVER (WHITE BUBBLE) ---
                                HStack(alignment: .bottom){
                                    VStack(alignment: .leading, spacing: 4) {
                                        
                                        // 1. Image Content (No background/padding here)
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
                                        
                                        // 2. Text Content (Apply background/padding only to the text)
                                        if !message.text.isEmpty {
                                            Text(message.text)
                                                .foregroundColor(.black)
                                                .padding() // Padding inside the bubble
                                                .background(Color.white) // White background for text
                                                .cornerRadius(10) // Rounded corners for text bubble
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top,1)
                    }
                }
            }
            .defaultScrollAnchor(.bottom)
            .background(Color(.init(white: 0.80, alpha: 1)))
            
            // Input Bar
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
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
        }
        .navigationTitle(vm.chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear{
            vm.firestoreListener?.remove()
        }
    }
}

#Preview {
    MessagesView()
}
