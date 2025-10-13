//
//  ContentView.swift
//  TouchGrass
//
//  Created by Ben Keane on 10/8/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    // example pins
    let mercatCentral = CLLocationCoordinate2D(latitude: 41.115908,
                                               longitude: 1.248912)
    let balco = CLLocationCoordinate2D(latitude: 41.113694,
                                       longitude: 1.256485)
    let abuelos = CLLocationCoordinate2D(latitude: 41.113518,
                                         longitude: 1.253227)
    let burlington = CLLocationCoordinate2D(latitude: 44.477095,
                                            longitude: -73.212567)
    
    @State var camera: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack {
            Map(position: $camera) {
                Marker("Mercat Central", coordinate: mercatCentral)
                    .tint(.green)
                Marker("Balcó del Mediterrani", coordinate: balco)
                    .tint(.blue)
                Marker("Abuelos", coordinate: abuelos)
                    .tint(.purple)
            }
            .mapStyle(.standard)
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
                    camera = .region(MKCoordinateRegion(center: burlington, latitudinalMeters: 2000, longitudinalMeters: 2000))
                    
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
