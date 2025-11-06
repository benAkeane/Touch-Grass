//
//  FirebaseFunctions.swift
//  TouchGrass
//
//  Created by Ben Keane on 10/16/25.
//

import FirebaseAuth
import FirebaseFirestore
import Combine


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

    
    //
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
    
    
    func addNewRoute(for userID: String, routeData: [String: Any]) {
        db.collection("users")
            .document(userID)
            .collection("routes")
            .addDocument(data: routeData)
    }
    
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

