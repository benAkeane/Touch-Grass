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
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var mapConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic, emphasisStyle: .default)
    var profileSwap: () -> Void = {}
        
    var body: some View {
        ZStack {
            Map(position: .constant(.region(manager.region))) {
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
