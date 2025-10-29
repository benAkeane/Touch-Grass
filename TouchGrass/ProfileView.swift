//
//  ProfileView.swift
//  TouchGrass
//
//  Created by Tim Mäser on 10.27.25
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var firebaseFunctions: FirebaseFunctions
    
    
    var body: some View {
        VStack {

            ZStack {
                HStack {
                    Button {
                        print("")
                    } label: {
                        Image(systemName: "list.dash")
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

            Image("Profile")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .clipShape(Circle())
                .overlay(Circle().stroke(style: StrokeStyle(lineWidth: 4)))
                .padding()

            Text("\(Auth.auth().currentUser?.displayName ?? "User")")
                .font(.largeTitle)

            Spacer()
        }
    }
    
    
      
}

#Preview {
    ProfileView()
}
