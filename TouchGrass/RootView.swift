//
//  RootView.swift
//  TouchGrass
//
//  Created by Ben Keane on 10/18/25.
//

import SwiftUI
import FirebaseAuth

// enum to handle swapping between home, profile, and search view
enum MainView {
    case home
    case profile
    case search
}

struct RootView: View {
    @EnvironmentObject var firebaseFunctions: FirebaseFunctions
    @State private var currentView: MainView = .home
    @State private var showLandingPage = true
    
    var body: some View {
        if showLandingPage {
            LandingPageView(
                onLogin: {
                    showLandingPage = false
                },
                onSignUp: {
                    showLandingPage = false
                }
            )
        } else if firebaseFunctions.currentUser == nil {
            LoginView() // Show login screen if user isn't currently logged in
        } else {
            switch currentView {
            case .home:
                MapView(
                    profileSwap: { currentView = .profile },
                    searchSwap: { currentView = .search }
                )
                
            case .profile:
                ProfileView(onBack: { currentView = .home })
                
            case .search:
                NavigationStack {
                    SearchView(onBack: { currentView = .home })
                }
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(FirebaseFunctions())
}
