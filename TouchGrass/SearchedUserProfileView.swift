//
//  SearchedUserProfileView.swift
//  TouchGrass
//
//  Created by Ben Keane on 11/17/25.
//

import SwiftUI
import FirebaseFirestore

struct SearchedUserProfileView: View {
    @EnvironmentObject var firebaseFunctions: FirebaseFunctions
    @State private var userID: String?
    @State private var profileImage: Image? = nil
    @State private var routes: [Route] = []
    
    let username: String
    
    var body: some View {
        ZStack {
            Color(.systemGreen).opacity(0.15)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 300, height: 300)
                            .shadow(radius: 12)
                        Group {
                            if let profileImage = profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image("Profile")
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                        .frame(width: 260, height: 260)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.green, lineWidth: 4))
                    }
                    .padding(.top)
                    Text(username)
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.green)
                        .shadow(radius: 3)
                    Text("Past Routes")
                        .font(.title2.bold())
                        .foregroundColor(.green)
                        .padding(.top, 10)
                    

                    VStack(spacing: 15) {
                        if routes.isEmpty {
                            Text("No routes yet")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(routes) { route in
                                NavigationLink {
                                    RouteDetailView(route: route)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(route.name)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text(route.date.formatted(date: .abbreviated, time: .shortened))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "map")
                                            .font(.title2)
                                            .foregroundColor(.green)
                                    }
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(15)
                                    .shadow(radius: 4)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                        .frame(height: 40)
                }
            }
        }
        .onAppear {
            Task {
                await loadUser()
            }
        }
    }
    
    private func loadUser() async {
        if let fetchedID = await firebaseFunctions.getUserIdFromUsername(username) {
            self.userID = fetchedID
            
            firebaseFunctions.getProfileImageBase64(for: fetchedID) { base64 in
                if let base64,
                   let data = Data(base64Encoded: base64),
                   let uiImage = UIImage(data: data) {
                    self.profileImage = Image(uiImage: uiImage)
                }
            }
            
            firebaseFunctions.getRoutes(for: fetchedID) { fetchedRoutes in
                self.routes = fetchedRoutes
            }
        }
    }
}

#Preview {
    SearchedUserProfileView(username: "exampleUser")
        .environmentObject(FirebaseFunctions())
}
