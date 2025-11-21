//
//  LandingPageView.swift
//  TouchGrass
//
//  Created by Ben Keane on 11/21/25.
//

import SwiftUI

struct LandingPageView: View {
    var onLogin: () -> Void
    var onSignUp: () -> Void
    private let mintGreen = Color(red: 0.78, green: 0.93, blue: 0.80)

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            Text("TouchGrass")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.green)

            Spacer()

            Button(action: onLogin) {
                Text("Log In")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)

            Button(action: onSignUp) {
                Text("Sign Up")
                    .font(.title2)
                    .foregroundColor(Color.green)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green, lineWidth: 2)
                    )
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .background(Color(mintGreen).ignoresSafeArea())
    }
}

#Preview {
    LandingPageView(onLogin: {}, onSignUp: {})
}
