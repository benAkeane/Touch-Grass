//
//  LoginView.swift
//  TouchGrass
//
//  Created by Ben Keane on 10/18/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var firebaseFunctions: FirebaseFunctions
    @State private var email = ""
    @State private var password = ""
    @State private var authMessage = ""
    @State private var isSignUp = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Touch Grass")
                .padding()
            
            Text(isSignUp ? "Create Account" : "Log In")
                .font(.largeTitle)
                .bold()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(isSignUp ? "Sign Up" : "Log In") {
                if isSignUp {
                    firebaseFunctions.signUp(email: email, password: password) { result in printResult(result)
                    }
                } else {
                    firebaseFunctions.logIn(email: email, password: password) {
                        result in printResult(result)}
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button(isSignUp ? "Login" : "Sign Up") {
                isSignUp.toggle()
            }
            .foregroundColor(.blue)
            
            Text(authMessage)
                .foregroundColor(.red)
                .padding(.top)
        }
        .padding()
    }
    
    private func printResult(_ result: Result<AuthDataResult, Error>) {
        switch result {
        case .success(let authResult):
            authMessage = "Logged In \(authResult.user.email ?? "")"
        case .failure(let error):
            authMessage = "Error: \(error.localizedDescription)"
        }
    }
}
