//
//  SwiftlyChatApp.swift
//  SwiftlyChat
//
//  Created by NRD on 04/11/2025.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct SwiftlyChatApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authManager = FirebaseManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
