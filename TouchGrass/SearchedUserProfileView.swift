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
    
    private let mintGreen = Color(red: 0.78, green: 0.93, blue: 0.80)
    private let softGreen = Color(red: 0.35, green: 0.60, blue: 0.40)
    
    let username: String
    
    var body: some View {
        ZStack {
            mintGreen.opacity(0.35)
                .ignoresSafeArea()
            
            VStack {
                
                Text("Profile")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                    .foregroundColor(softGreen)
                
                ZStack(alignment: .bottomTrailing) {
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
                    .frame(width: 250, height: 250)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(softGreen, lineWidth: 4))
                }
                .padding()
                
                Text(username)
                    .font(.title)
                    .bold()
                    .foregroundColor(softGreen)
                
                // ----- Code for routes below -----
                
                Text("Past Routes")
                    .font(.title2)
                    .bold()
                    .padding(.top)
                    .foregroundColor(softGreen)
                
                ScrollView {
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
                                        VStack(alignment: .leading) {
                                            Text(route.name)
                                                .font(.headline)
                                                .foregroundColor(softGreen)
                                            Text(route.date.formatted(date: .abbreviated, time: .shortened))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Image(systemName: "map")
                                            .font(.title2)
                                            .foregroundColor(softGreen)
                                    }
                                    .padding()
                                    .background(mintGreen.opacity(0.6))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
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
