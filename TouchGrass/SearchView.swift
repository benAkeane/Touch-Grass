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
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        onBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding()
                
                TextField("Search for a username", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                List(filteredUsernames, id: \.self) { username in
                    Button {
                        selectedUser = username
                    } label: {
                        Text(username)
                    }
                }
                .listStyle(.plain)
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
