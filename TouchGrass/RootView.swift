//
//  RootView.swift
//  TouchGrass
//
//  Created by Ben Keane on 10/18/25.
//

import SwiftUI
import FirebaseAuth

// enum to handle swapping between home and profile view
enum MainView {
    case home
    case profile
}

struct RootView: View {
    @EnvironmentObject var firebaseFunctions: FirebaseFunctions
    @State private var currentView: MainView = .home
    
    var body: some View {
        Group {
            if firebaseFunctions.currentUser == nil {
                LoginView() // Show login screen if user isn't currently logged in
            } else {
                if currentView == .home {
                    ContentView(profileSwap: { currentView = .profile })
                } else if currentView == .profile {
                    ProfileView(onBack: { currentView = .home })
                }
            }
        }
        .onAppear {
            firebaseFunctions.signOut()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(FirebaseFunctions())
}
