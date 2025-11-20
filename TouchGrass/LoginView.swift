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
    
    // Theme colors
    private let mintGreen = Color(red: 0.78, green: 0.93, blue: 0.80)
    private let softGreen = Color(red: 0.35, green: 0.60, blue: 0.40)
    
    var body: some View {
        ZStack {
            
            // Background tint
            mintGreen.opacity(0.35)
                .ignoresSafeArea()
            
            VStack {
                Text("Touch Grass")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(softGreen)
                    .padding(.top)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Text(isSignUp ? "Create Account" : "Log In")
                        .font(.title)
                        .bold()
                        .foregroundColor(softGreen)
                    
                    if isSignUp {
                        TextField("Username", text: $username)
                            .padding()
                            .background(mintGreen.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(softGreen.opacity(0.6), lineWidth: 1.4)
                            )
                            .cornerRadius(12)
                            .autocapitalization(.none)
                    }
                    
                    TextField("Email", text: $email)
                        .padding()
                        .background(mintGreen.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(softGreen.opacity(0.6), lineWidth: 1.4)
                        )
                        .cornerRadius(12)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(mintGreen.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(softGreen.opacity(0.6), lineWidth: 1.4)
                        )
                        .cornerRadius(12)
                    
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
                            firebaseFunctions.logIn(email: email, password: password) { result in
                                switch result {
                                case .success:
                                    print("Logged in!")
                                case .failure(let error):
                                    authMessage = error.localizedDescription
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(softGreen.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: softGreen.opacity(0.4), radius: 5, y: 2)
                    
                    Button(isSignUp ? "Login" : "Sign Up") {
                        isSignUp.toggle()
                    }
                    .foregroundColor(softGreen)
                    .padding(.top, 4)
                    
                    Text(authMessage)
                        .foregroundColor(.red)
                        .padding(.top)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.white.opacity(0.4))
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                )
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    LoginView()
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
