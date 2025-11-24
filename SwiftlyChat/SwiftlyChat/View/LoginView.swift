//
//  LoginView.swift
//  FirebaseExample
//
//  Created by NRD on 20/10/2025.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var errorMessage: String?
    @State private var showImagePicker = false;
    @State private var image: UIImage?
    let isLoggedIn: () -> ()
    
    private func loggedIn() {
        self.isLoggedIn()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode {
                        Button {
                            showImagePicker
                                .toggle()
                        } label: {
                            
                            VStack{
                                if let image = self.image{
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 150, height: 150)
                                        .scaledToFill()
                                        .cornerRadius(75)
                                } else{
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 100))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 75)
                                .stroke(Color.black, lineWidth: 3))
                            
                        }
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(Color.white)
                    
                    Button {
                        handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color.blue)
                        
                    }
                    
                    Text(self.errorMessage ?? "")
                        .foregroundColor(.red)
                }
                .padding()
                
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                .ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil){
            ImagePicker(image: $image)
        }
    }
    
    private func handleAction() {
        if isLoginMode {
            
            if email.isEmpty && password.isEmpty {
                self.errorMessage = "Enter both email and password"
                
                return
            }
            FirebaseManager.shared.login(email: email, password: password) {
                result in
                switch result {
                case .success:
                    print ("Login Successful")
                    loggedIn()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
                
            }
            
        } else {
            
            if image == nil {
                errorMessage = "Please select a profile picture"
                return
            }
            
            if email.isEmpty && password.isEmpty {
                self.errorMessage = "Enter both email and password"
                
                return
            }
            FirebaseManager.shared.register(email: email, password: password, image: self.image) {
                result in
                switch result {
                case .success:
                    print ("Registration Successful")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    LoginView(isLoggedIn: {})
        .environmentObject(FirebaseManager())
}
