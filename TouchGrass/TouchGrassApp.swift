//
//  TouchGrassApp.swift
//  TouchGrass
//
//  Created by Ben Keane on 10/8/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct TouchGrassApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var firebaseFunctions = FirebaseFunctions()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(firebaseFunctions)
        }
    }
}
