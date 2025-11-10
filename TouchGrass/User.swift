//
//  User.swift
//  TouchGrass
//
//  Created by Ben Keane on 11/10/25.
//
// User data model for how a user is defined in firebase

import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var email: String?
    var profileImageURL: String?
    var time_created: Date?
}
