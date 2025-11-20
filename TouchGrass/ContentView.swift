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

            // MARK: - TOP BUTTONS
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

        // MARK: - FLOATING BOTTOM CONTROLS
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 40) {
                bottomAction(icon: "camera.fill") {
                    if let newPin = manager.dropPhotoPin() {
                        selectedPin = newPin
                    }
                }

                bottomAction(icon: "location.fill") {
                    cameraPosition = .userLocation(
                        followsHeading: true,
                        fallback: .automatic
                    )
                }

                bottomAction(icon: manager.isRecording ? "stop.fill" : "play.fill") {
                    if manager.isRecording {
                        manager.stopRecording(firebaseFunctions: firebaseFunctions)
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
}

#Preview {
    ContentView()
}
