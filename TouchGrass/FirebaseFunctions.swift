//
//  FirebaseFunctions.swift
//  TouchGrass
//
//  Created by Ben Keane on 10/16/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import CoreLocation
//import Combine

// defines how a route will be stored in firebase
struct Route: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var coordinates: [GeoPoint]
    var date: Date
}


class FirebaseFunctions: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var currentUser: User?
    
    // When authentication state changes, store current user
    init() {
        Auth.auth().addStateDidChangeListener {
            _, user in self.currentUser = user
        }
    }
    
    
    // user signup function using firebase auth,
    // stores uid, and user data: username, email, timestamp for when account created
    func signUp(email: String, password: String, username: String, passed: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) {
            result, error in
            if let error = error {
                passed(.failure(error))
            } else if let result = result {
                let userID = result.user.uid
                let data: [String: Any] = [
                    "email": email,
                    "username": username,
                    "time_created": Timestamp(date: Date())
                ]
                self.addNewUser(userID: userID, data: data)
                passed(.success(result))
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
            currentUser = nil
            print("Signed out successfully")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    
    // add new user to the firestore database
    // saves userID, email, username, and timestamp when created
    func addNewUser(userID: String, data: [String: Any]) {
        db.collection("users")
            .document(userID)
            .setData(data) { error in
            if let error = error {
                print("Error writing to Firestore: \(error.localizedDescription)")
            } else {
                print("successfully added document")
            }
        }
    }
    
    
    // current function for adding a route to the firestore database
    // not tested yet...
    // uses the route struct to store route name, coordinates (via geopoints), and timestamp
    // geopoints should be work with firebase (but not tested yet, so im not sure)
    func saveRoute(for userID: String, name: String, coordinates: [CLLocationCoordinate2D]) {
        let geoPoints = coordinates.map { GeoPoint(latitude: $0.latitude, longitude: $0.longitude) }
        let routeData: [String: Any] = [
            "name": name,
            "coordinates": geoPoints,
            "date": Timestamp(date: Date())
        ]
        
        // store routes as a subcollection of users
        db.collection("users")
            .document(userID)
            .collection("routes")
            .addDocument(data: routeData) { error in
                if let error = error {
                    print("error saving route \(error.localizedDescription)")
                } else {
                    print("saved route")
                }
            }
    }
    
    
    // getter function for fetching the current users username
    func getUsername(userID: String, passed: @escaping (String?) -> Void) {
        db.collection("users").document(userID).getDocument { name, error in
            if let error = error {
                print("error getting username: \(error.localizedDescription)")
                passed(nil)
            } else if let data = name?.data(), let username = data["username"] as? String {
                passed(username)
            } else {
                passed(nil)
            }
        }
    }
}

