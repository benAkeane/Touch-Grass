//  SearchView.swift
//  TouchGrass
//
//  Created by Ben Keane on 11/10/25.
//

import SwiftUI

// TODO: FINISH SearchView
struct SearchView: View {
    @EnvironmentObject var firebaseFunctions: FirebaseFunctions
    @State private var searchText = ""
    @State private var usernames: [String] = []
    @State private var selectedUser: String? = nil
    
    var onBack: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGreen).opacity(0.15)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Back Button
                    HStack {
                        Button {
                            onBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.green)
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    
                    // Search Field
                    TextField("Search for a username", text: $searchText)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(14)
                        .shadow(radius: 4)
                        .padding(.horizontal)
                    
                    
                    // List of users
                    List(filteredUsernames, id: \.self) { username in
                        Button {
                            selectedUser = username
                        } label: {
                            HStack {
                                Image(systemName: "person.crop.circle")
                                    .foregroundColor(.green)
                                
                                Text(username)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
            .navigationTitle("User Search")
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    usernames = await firebaseFunctions.getAllUsers()
                }
            }
            .navigationDestination(item: $selectedUser) { username in
                SearchedUserProfileView(username: username)
                    .environmentObject(firebaseFunctions)
            }
        }
    }
    
    var filteredUsernames: [String] {
        // Displays all usernames if search text field is empty for testing purposes
        if searchText.isEmpty {
            return usernames
            // return [] // shows nothing until user types
        }
        
        return usernames.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
}

#Preview {
    SearchView(onBack: {})
        .environmentObject(FirebaseFunctions())
}
