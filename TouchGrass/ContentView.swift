//
//  ContentView.swift
//  TouchGrass
//
//  Created by Ben Keane on 10/8/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @StateObject var manager = LocationManager()
        
    var body: some View {
        ZStack {
            Map(coordinateRegion: $manager.region, showsUserLocation: true)
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Button {
                        print("")
                    } label: {
                        Image(systemName: "list.dash")
                            .font(.system(size: 50))
                            .padding()
                    }
                    Spacer() // pushes button to left
                }
                Spacer() // pushes button to top
            }
        }
        
        
        
        // container for buttons
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button {
                    //temporary until we add camera functionality
                    print("")
                } label: {
                    Image(systemName: "camera.fill").font(.system(size: 50))
                }
                Spacer()
                Button {
                    print("TODO")
                    
                } label: {
                    Image(systemName: "house.fill").font(.system(size: 50))
                }
                Spacer()
                Button {
                    //temporary until we add camera functionality
                    print("")
                } label: {
                    Image(systemName: "mappin.circle.fill").font(.system(size: 50))
                }
                Spacer()
                
            }
            .padding(.top)
            .background(.thinMaterial)
        }
    }
}
#Preview {
    ContentView()
}
