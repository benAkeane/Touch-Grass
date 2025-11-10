//
//  ProfileView.swift
//  TouchGrass
//
//  Created by Tim Mäser on 10.27.25
//

import SwiftUI
import FirebaseAuth
import MapKit
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var firebaseFunctions: FirebaseFunctions
    @State private var username: String = ""
    @State private var routes: [Route] = []
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil
    @State private var isUploading: Bool = false
    @State private var uploadError: String? = nil
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
            
            // ---- Code for Photo Upload below ----
            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
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
                    .frame(width: 300, height: 300)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(style: StrokeStyle(lineWidth: 4)))
                    

                    // Edit badge
                    ZStack {
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 44, height: 44)
                        Image(systemName: "pencil")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .bold))
                    }
                    .offset(x: -15, y: -15)
                }
            }
            .buttonStyle(.plain)
            .padding()
            
            if let uploadError = uploadError {
                Text(uploadError)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.bottom, 4)
            }

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
            loadProfileData()
        }
        .onChange(of: selectedItem) { oldValue, newValue in
            guard let newValue = newValue else { return }
            Task {
                do {
                    uploadError = nil
                   
                    let data = try await newValue.loadTransferable(type: Data.self)
                    guard let data, let uiImage = UIImage(data: data) else {
                        throw NSError(domain: "ProfileView", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not read selected image data"]) 
                    }
                    // Optimistically show selected image
                    profileImage = Image(uiImage: uiImage)
                    if let user = firebaseFunctions.currentUser {
                        _ = try await firebaseFunctions.uploadProfileImage(data, for: user.uid)
                    }
                } catch {
                    uploadError = error.localizedDescription
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
        .environmentObject(FirebaseFunctions())
}

