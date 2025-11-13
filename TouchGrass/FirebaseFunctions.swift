//
//  FirebaseFunctions.swift
//  TouchGrass
//
//  Created by Ben Keane on 10/16/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import CoreLocation


class FirebaseFunctions: ObservableObject {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    @Published var authUser: FirebaseAuth.User?
    @Published var currentUser: User?
    
    // When authentication state changes, store current user
    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.authUser = user
            if let user = user {
                self.fetchUserData(uid: user.uid)
            } else {
                self.currentUser = nil
            }
        }
    }
    
    
    // user signup function using firebase auth,
    // stores uid, and user data: username, email, timestamp for when account created
    func signUp(email: String, password: String, username: String, passed: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) {
            result, error in
            if let error = error {
                passed(.failure(error))
                return
            }
            
            guard let result = result else { return }
            let userID = result.user.uid
            
            let newUser = User(
                id: userID,
                username: username,
                email: email,
                profileImageBase64: nil,
                time_created: Date()
            )
            
            do {
                try self.db.collection("users").document(userID).setData(from: newUser)
                passed(.success(result))
            } catch {
                passed(.failure(error))
            }
        }
    }

    
    // takes users email and password, checks with firebase auth and logs in if correct
    func logIn(email: String, password: String, passed: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) {
            result, error in
            if let error = error {
                passed(.failure(error))
            } else if let result = result {
                passed(.success(result))
            }
        }
    }
    
    
    // signs current user out
    func signOut() {
        // Error handling for user sign out
        do {
            try Auth.auth().signOut()
            self.authUser = nil
            self.currentUser = nil
            print("Signed out successfully")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    
    // get current user data
    func fetchUserData(uid: String) {
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("error fetching user data: \(error.localizedDescription)")
                return
            }
            if let user = try? snapshot?.data(as: User.self) {
                DispatchQueue.main.async {
                    self.currentUser = user
                }
            }
        }
    }
    
    // current function for adding a route to the firestore database
    // not tested yet...
    // uses the route struct to store route name, coordinates (via geopoints), and timestamp
    // geopoints should be work with firebase (but not tested yet, so im not sure)
    func saveRoute(for userID: String, name: String, coordinates: [CLLocationCoordinate2D]) {
        let geoPoints = coordinates.map { GeoPoint(latitude: $0.latitude, longitude: $0.longitude) }
        let route = Route(
            id: nil,
            name: name,
            coordinates: geoPoints,
            date: Date()
        )
        
        do {
            try db.collection("users")
                .document(userID)
                .collection("routes")
                .addDocument(from: route)
            print("saved route")
        } catch {
            print("error saving route: \(error.localizedDescription)")
        }
    }
    
    
    // getter function for fetching a users stored routes
    func getRoutes(for userID: String, passed: @escaping ([Route]) -> Void) {
        db.collection("users")
            .document(userID)
            .collection("routes")
            .order(by: "date", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("error getting routes: \(error.localizedDescription)")
                    passed([])
                    return
                }
                
                let routes = snapshot?.documents.compactMap { document -> Route? in
                    try? document.data(as: Route.self)
                } ?? []
                
                passed(routes)
            }
    }
    
    // Uploads a profile image to Firebase Storage and stores its download URL in Firestore under the user's document.
    func uploadProfileImage(_ image: UIImage, for userID: String) async throws {
        // compress image
        guard let compressedData = compressImage(image) else {
            throw NSError(domain: "FirebaseFunctions", code: 0, userInfo: [NSLocalizedDescriptionKey: "failed compressing image"])
        }
        
        // image needs to be converted to this type of string for it to be stored
        let base64ConvertedString = compressedData.base64EncodedString()

        try await db.collection("users")
            .document(userID)
            .setData(["profileImageBase64": base64ConvertedString], merge: true)
    }
    
    func getProfileImageBase64(for userID: String, passed: @escaping (String?) -> Void) {
        db.collection("users").document(userID).getDocument { doc, error in
            if let error = error {
                print("error getting profile image: \(error.localizedDescription)")
                passed(nil)
                return
            }
            let base64 = doc?.data()?["profileImageBase64"] as? String
            passed(base64)
        }
    }
    
    
    func searchUsers(by username: String, passed: @escaping ([User]) -> Void) {
        let usersQuery = db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: username)
            .whereField("username", isLessThanOrEqualTo: username + "\u{f8ff}")
        
        usersQuery.getDocuments { snapshop, error in
            if let error = error {
                print("error finding users: \(error.localizedDescription)")
                passed([])
                return
            }
            
            let users = snapshop?.documents.compactMap { document -> User? in
                try? document.data(as: User.self)
            } ?? []
            
            passed(users)
        }
    }
    
    
    func compressImage(_ image: UIImage) -> Data? {
        let maxSize: Int = 700_000
        var compression: CGFloat = 1.0
        guard var imageData = image.jpegData(compressionQuality: compression) else { return nil }
        
        while imageData.count > maxSize && compression > 0.05 {
            compression -= 0.05
            if let newData = image.jpegData(compressionQuality: compression) {
                imageData = newData
            } else {
                break
            }
        }
        return imageData
    }
}
