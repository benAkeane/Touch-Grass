//
//  ProfileView.swift
//  TouchGrass
//
//  Created by Tim Mäser on 10.27.25
//

import SwiftUI
import FirebaseAuth
import MapKit

struct ProfileView: View {
    @EnvironmentObject var firebaseFunctions: FirebaseFunctions
    @State private var username: String = ""
    @State private var routes: [Route] = []
    var onBack: () -> Void = {}
    
    
    var body: some View {
        VStack {

            ZStack {
                HStack {
                    Button {
                        onBack() // takes user back to home screen (temporary)
                    } label: {
                        Image(systemName: "list.dash")
                            .font(.system(size: 50))
                            .padding()
                    }
                    Spacer()
                }

                Text("My Profile")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
            }
            .padding(.horizontal)

            Image("Profile")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .clipShape(Circle())
                .overlay(Circle().stroke(style: StrokeStyle(lineWidth: 4)))
                .padding()

            Text(username)
                .font(.largeTitle)
            
            // ----- Code for routes below -----
            
            // Sample Routes below for now
            let sampleRoutes = [
                ("Morning Run", "Oct 20, 2025"),
                ("City Ride", "Oct 18, 2025"),
                ("Evening Hike", "Oct 15, 2025")
            ]

            Text("Past Routes")
                .font(.title2)
                .bold()
                .padding(.top)

            // SHOULD display routes, but doesn't work... yet
            // ill look into it soon - Ben
            ScrollView {
                VStack {
                    if routes.isEmpty {
                        Text("No routes yet")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(routes) { route in
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
                .padding(.horizontal)
            }

            
            Spacer()
        }
        .onAppear {
            if let user = firebaseFunctions.currentUser {
                firebaseFunctions.getUsername(userID: user.uid) { name in
                    if let name = name {
                        self.username = name
                    }
                }
            }
        }
    }
    
    private func loadProfileData() {
        guard let user = firebaseFunctions.currentUser else { return }
        
        // get username
        firebaseFunctions.getUsername(userID: user.uid) { name in
            if let name = name {
                self.username = name
            }
        }
        
        // get routes
        firebaseFunctions.getRoutes(for: user.uid) { fetchedRoutes in
            self.routes = fetchedRoutes
        }
    }
}

#Preview {
    ProfileView()
}
