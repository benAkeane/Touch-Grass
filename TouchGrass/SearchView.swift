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
                        // TODO: take the user to another user's profile view
                        print("selected: \(username)")
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
        }
    }
    
    var filteredUsernames: [String] {
        if searchText.isEmpty {
            return usernames
        }
        
        return usernames.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
}

#Preview {
    SearchView(onBack: {})
        .environmentObject(FirebaseFunctions())
}
