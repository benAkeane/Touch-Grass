//
//  FirebaseFunctions.swift
//  TouchGrass
//
//  Created by Ben Keane on 10/16/25.
//

import FirebaseAuth
import FirebaseFirestore

class FirebaseFunctions: ObservableObject {
    private let db = Firestore.firestore()
    
    func signUp(email: String, password: String, passed: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                passed(.failure(error))
            } else if let result = result {
                passed(.success(result))
            }
        }
    }

    
    func logIn(email: String, password: String, passed: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                passed(.failure(error))
            } else if let result = result {
                passed(.success(result))
            }
        }
    }

    
    func addUserData(userID: String, data: [String: Any]) {
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
    
    
    func addRoute(for userID: String, routeData: [String: Any]) {
        db.collection("users")
            .document(userID)
            .collection("routes")
            .addDocument(data: routeData)
    }
}
