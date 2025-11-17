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
        VStack {
            ZStack {
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
                .frame(width: 300, height: 300)
                .clipShape(Circle())
                .overlay(Circle().stroke(style: StrokeStyle(lineWidth: 4)))
            }
            .padding(.top)
            
            Text(username)
                .font(.largeTitle)
                .bold()
            
            Text("Past Routes")
                .font(.title2)
                .bold()
                .padding(.top)
            
            ScrollView {
                VStack {
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
                                        Text(route.date.formatted(date: .abbreviated, time: .shortened))
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "map")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color(.gray))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
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
            
            firebaseFunctions.getRoutes(for: fetchedID) { FetchedRoutes in
                self.routes = FetchedRoutes
            }
        }
    }
}

#Preview {
    SearchedUserProfileView(username: "exampleUser")
        .environmentObject(FirebaseFunctions())
}
