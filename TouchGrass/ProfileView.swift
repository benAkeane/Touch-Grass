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
            
            // ----- Code for routes below -----
            
            // Sample Routes below for now
            let sampleRoutes = [
                ("Morning Run", "Oct 20, 2025"),
                ("City Ride", "Oct 18, 2025"),
                ("Evening Hike", "Oct 15, 2025")
            ]

            Text("Past Routes")
                .font(.title2)
                .bold()
                .padding(.top)

            ScrollView {
                VStack {
                    ForEach(sampleRoutes, id: \.0) { route in
                        HStack {
                            
                            VStack(alignment: .leading) {
                                Button{
                                    print("")
                                } label: {
                                    Text(route.0)
                                        .font(.headline)
                                    Spacer()
                                    Text(route.1)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                            }
                            Spacer()
                            Image(systemName: "map")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }

            
            Spacer()
        }
    }
    
    
      
}

#Preview {
    ProfileView()
}
