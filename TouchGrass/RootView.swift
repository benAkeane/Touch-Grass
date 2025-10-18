//
//  RootView.swift
//  TouchGrass
//
//  Created by Ben Keane on 10/18/25.
//

import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var firebaseFunctions: FirebaseFunctions
    
    var body: some View {
        Group {
            if firebaseFunctions.currentUser != nil {
                ContentView() // Show home screen (map screen)
            } else {
                LoginView() // Show login screen if user isn't currently logged in
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
