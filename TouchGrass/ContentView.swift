//
//  LoginView.swift
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
    @State private var mapConfiguration = MKStandardMapConfiguration(
        elevationStyle: .realistic,
        emphasisStyle: .default
    )
    @State private var showingRouteNamePrompt = false
    @State private var newRouteName = ""
    @State private var pendingRoute: FinishedRoute?

    // Soft green theme
    private let mintGreen = Color(red: 0.78, green: 0.93, blue: 0.80)
    private let softGreen = Color(red: 0.35, green: 0.60, blue: 0.40)

    var profileSwap: () -> Void = {}
    var searchSwap: () -> Void = {}

    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                UserAnnotation()

                if !manager.recordedRoute.isEmpty {
                    MapPolyline(coordinates: manager.recordedRoute)
                        .stroke(softGreen, lineWidth: 4)
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
                            .font(.system(size: 28))
                            .foregroundColor(pin.imageData != nil ? softGreen : .red)
                            .padding(6)
                            .background(mintGreen.opacity(0.6))
                            .clipShape(Circle())
                            .shadow(radius: 3)
                            .onTapGesture {
                                selectedPin = pin
                            }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)

            // Live stats overlay (appears only when route is active)
            if manager.isRecording {
                VStack() {
                    HStack(spacing: 16) {
                        Label(formatTime(manager.elapsedTime), systemImage: "clock")
                        Label(formatDistance(manager.currentDistanceMeters), systemImage: "ruler")
                    }
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .background(.ultraThinMaterial, in: Capsule())
                    .shadow(radius: 3)

                    Spacer()
                }
                
            }

            // Top buttons
            VStack {
                HStack {
                    circularTopButton(icon: "list.dash") {
                        profileSwap()
                    }
                    Spacer()
                    circularTopButton(icon: "magnifyingglass") {
                        searchSwap()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)

                Spacer()
            }
        }
        .sheet(item: $selectedPin) { pin in
            if let index = manager.photoPins.firstIndex(where: { $0.id == pin.id }) {
                PhotoPinView(pin: $manager.photoPins[index], isReadOnly: false)
            }
        }
        .sheet(isPresented: $showingRouteNamePrompt) {
            VStack(spacing: 20) {
                Text("Name Your Route")
                    .font(.title2)
                    .bold()
                    .padding(.top, 10)
                
                TextField("Route name", text: $newRouteName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button("Save Route") {
                    guard let pending = pendingRoute,
                          let userID = firebaseFunctions.currentUser?.id else { return }
                    
                    Task {
                        await firebaseFunctions.saveRoute(
                            for: userID,
                            name: newRouteName.isEmpty ? "Route" : newRouteName,
                            totalTime: pending.totalTime,
                            coordinates: pending.coordinates,
                            photoPins: pending.photoPins
                        )
                        
                        // Dismiss the sheet on the main thread
                        DispatchQueue.main.async {
                            showingRouteNamePrompt = false
                        }
                    }
                    showingRouteNamePrompt = false
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 20)
            }
            .presentationDetents([.height(240)])
        }

        // Bottom buttons
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 40) {
                bottomAction(icon: "camera.fill") {
                    if let newPin = manager.dropPhotoPin() {
                        selectedPin = newPin
                    }
                }
                .disabled(!manager.isRecording)
                .opacity(manager.isRecording ? 1.0 : 0.5)

                bottomAction(icon: "location.fill") {
                    cameraPosition = .userLocation(
                        followsHeading: true,
                        fallback: .automatic
                    )
                }

                bottomAction(icon: manager.isRecording ? "stop.fill" : "play.fill") {
                    if manager.isRecording {
                        if let finished = manager.stopRecording() {
                            pendingRoute = finished
                            newRouteName = ""
                            showingRouteNamePrompt = true
                        }
                    } else {
                        manager.startRecording()
                    }
                }
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(mintGreen.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 16)
            .shadow(color: softGreen.opacity(0.35), radius: 8, y: -2)
        }
    }

    private func circularTopButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(softGreen)
                .padding(12)
                .background(mintGreen.opacity(0.8))
                .clipShape(Circle())
                .shadow(radius: 3)
        }
    }

    private func bottomAction(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(softGreen)
                .font(.system(size: 32))
                .padding(16)
                .background(mintGreen.opacity(0.8))
                .clipShape(Circle())
                .shadow(radius: 3)
        }
    }
    
    // Format helpers below for the time and distance
    private func formatTime(_ seconds: TimeInterval) -> String {
        let sInt = Int(seconds)
        let h = sInt / 3600
        let m = (sInt % 3600) / 60
        let s = sInt % 60
        if h > 0 { return String(format: "%dh %dm %ds", h, m, s) }
        if m > 0 { return String(format: "%dm %ds", m, s) }
        return String(format: "%ds", s)
    }

    private func formatDistance(_ meters: CLLocationDistance) -> String {
        if meters >= 1000 {
            return String(format: "%.2f km", meters / 1000.0)
        } else {
            return String(format: "%.0f m", meters)
        }
    }
}

#Preview {
    ContentView()
}
