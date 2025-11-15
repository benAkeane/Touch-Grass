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
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var firebaseFunctions: FirebaseFunctions
    @State private var routes: [Route] = []
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil
    @State private var isUploading: Bool = false
    @State private var uploadError: String? = nil
    var onBack: () -> Void = {}
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    HStack {
                        Button {
                            onBack() // takes user back to home screen
                        } label: {
                            Image(systemName: "chevron.left")
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
                
                if let username = firebaseFunctions.currentUser?.username {
                    Text(username)
                        .font(.largeTitle)
                }
                
                // ----- Code for routes below -----

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
                loadProfileData()
            }
            .onChange(of: selectedItem) { oldValue, newValue in
                guard let newValue = newValue, let userID = firebaseFunctions.currentUser?.id else { return }
                Task {
                    do {
                        uploadError = nil
                       
                        guard let data = try await newValue.loadTransferable(type: Data.self),
                                          let uiImage = UIImage(data: data) else {
                                        throw NSError(domain: "ProfileView", code: -1, userInfo: [NSLocalizedDescriptionKey: "failed to read selected image data"])
                                    }
                        
                        guard let compressedData = firebaseFunctions.compressImage(uiImage),
                              let compressedImage = UIImage(data: compressedData) else {
                            throw NSError(domain: "ProfileView", code: -1,
                                          userInfo: [NSLocalizedDescriptionKey: "failed to ompress image"])
                        }
                        
                        // Optimistically show selected image
                        profileImage = Image(uiImage: compressedImage)
                        
                        try await firebaseFunctions.uploadProfileImage(compressedImage, for: userID)
                        } catch {
                            uploadError = "test \(error.localizedDescription)"
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Sign Out") {
                            firebaseFunctions.signOut()
                            onBack()
                        }
                    }
                }
        }
    }
    
    private func loadProfileImage(from base64: String) {
        if let data = Data(base64Encoded: base64),
           let uiImage = UIImage(data: data) {
            profileImage = Image(uiImage: uiImage)
        }
    }
    
    private func loadProfileData() {
        guard let user = firebaseFunctions.currentUser, let userID = user.id else { return }
        
        // get routes
        firebaseFunctions.getRoutes(for: userID) { fetchedRoutes in
            self.routes = fetchedRoutes
        }
        
        firebaseFunctions.getProfileImageBase64(for: userID) { base64 in
            if let base64 {
                loadProfileImage(from: base64)
            }
        }

    }
}

#Preview {
    ProfileView()
        .environmentObject(FirebaseFunctions())
}

