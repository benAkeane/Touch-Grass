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
    @EnvironmentObject var firebaseFunctions: FirebaseFunctions
    @State private var cameraPosition: MapCameraPosition = .userLocation(
            followsHeading: true,
            fallback: .automatic
        )
    @State private var selectedPin: PhotoPin?
    @State private var mapConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic, emphasisStyle: .default)
    var profileSwap: () -> Void = {}
    var searchSwap: () -> Void = {}
        
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                UserAnnotation()
                if !manager.recordedRoute.isEmpty {
                    MapPolyline(coordinates: manager.recordedRoute)
                        .stroke(.blue, lineWidth: 4)
                }
                if !manager.isRecording && !manager.recordedRoute.isEmpty {
                    if let start = manager.recordedRoute.first {
                        Marker("Start", coordinate: start)
                    }
                    if let end = manager.recordedRoute.last {
                        Marker("End", coordinate: end)
                    }
                }
                
                ForEach(manager.photoPins) { pin in
                    Annotation("Photo", coordinate: pin.coordinate) {
                        Image(systemName: "camera.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(pin.imageData != nil ? .green : .red) // Green if photo exists, red if empty
                            .background(.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 2)
                            .onTapGesture {
                                selectedPin = pin
                            }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    // when list button is clicked take user to profile view (temporary)
                    Button {
                        profileSwap()
                    } label: {
                        Image(systemName: "list.dash")
                            .font(.system(size: 50))
                            .padding()
                    }
                    Spacer() // pushes button to left
                    
                    Button {
                        searchSwap()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .padding()
                    }
                }
                Spacer() // pushes button to top
            }
        }
        
        // Sheet to show pin details/add photo
        .sheet(item: $selectedPin) { pin in
            if let index = manager.photoPins.firstIndex(where: { $0.id == pin.id }) {
                PhotoPinView(pin: $manager.photoPins[index], isReadOnly: false)
            }
        }
        
        // container for buttons
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button {
                    if let newPin = manager.dropPhotoPin() {
                        selectedPin = newPin
                    }
                } label: {
                    Image(systemName: "camera.fill").font(.system(size: 50))
                }
                Spacer()
                Button {
                    cameraPosition = .userLocation(
                                        followsHeading: true,
                                        fallback: .automatic
                                    )
                    
                } label: {
                    Image(systemName: "location.fill").font(.system(size: 50))
                }
                Spacer()
                Button {
                    if manager.isRecording {
                        manager.stopRecording(firebaseFunctions: firebaseFunctions)
                    } else {
                        manager.startRecording()
                    }
                } label: {
                    Image(systemName: manager.isRecording ? "stop.fill" : "play.fill")
                        .font(.system(size: 50))
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
