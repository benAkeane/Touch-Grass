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
    @State private var username = ""
    @State private var authMessage = ""
    @State private var isSignUp = false
    
    var body: some View {
        VStack {
            Text("Touch Grass")
                .font(.largeTitle)
                .bold()
                .padding(.top)
            
            Spacer()
            
            VStack(spacing: 16) {
                Text(isSignUp ? "Create Account" : "Log In")
                    .font(.title)
                    .bold()
                
                if isSignUp {
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                }
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(isSignUp ? "Sign Up" : "Log In") {
                    if isSignUp {
                        firebaseFunctions.signUp(email: email, password: password, username: username) { result in
                            switch result {
                            case .success:
                                print("Signed up!")
                            case .failure(let error):
                                authMessage = error.localizedDescription
                            }
                        }
                    } else {
                        firebaseFunctions.logIn(email: email, password: password) { result in switch result {
                        case .success:
                            print("Logged in!")
                        case .failure(let error):
                            authMessage = error.localizedDescription
                        }
                        }
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
            
            Spacer()
        }
        .padding()
    }
}
    
        
// Dont need anymore (commented out for now)
//    private func printResult(_ result: Result<AuthDataResult, Error>) {
//        switch result {
//        case .success(let authResult):
//            authMessage = "Logged In \(authResult.user.email ?? "")"
//        case .failure(let error):
//            authMessage = "Error: \(error.localizedDescription)"
//        }
//    }
//}
