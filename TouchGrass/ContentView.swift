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
        Map(position: $camera) {
            Marker("Mercat Central", coordinate: mercatCentral)
                .tint(.green)
            Marker("Balcó del Mediterrani", coordinate: balco)
                .tint(.blue)
            Marker("Abuelos", coordinate: abuelos)
                .tint(.purple)
        }
        // container for buttons
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button {
                    camera = .region(MKCoordinateRegion(center: burlington, latitudinalMeters: 2000, longitudinalMeters: 2000))
                    
                } label: {
                    Text("Go to Burlington")
                }
                Spacer()
            }
            .padding(.top)
            .background(.thinMaterial)
        }
        .mapStyle(.standard)
    }
}

#Preview {
    ContentView()
}
