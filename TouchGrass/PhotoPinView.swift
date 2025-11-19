//
//  PhotoPinView.swift
//  TouchGrass
//
//  Created by Marco Rubens on 11/19/25.
//

import SwiftUI
import PhotosUI

struct PhotoPinView: View {
    @Binding var pin: PhotoPin
    
    @EnvironmentObject var firebaseFunctions: FirebaseFunctions
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var displayImage: Image? = nil
    @State private var errorMessage: String? = nil
    
    // if true for RouteDetailView
    // if false for ContentView recording
    var isReadOnly: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField(isReadOnly ? "Untitled" : "Enter Image Title", text: $pin.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(isReadOnly)
            
                ZStack {
                    if let displayImage = displayImage {
                        displayImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    } else if let data = pin.imageData, let uiImage = UIImage(data: data) {
                        // Load from existing data
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 300, height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    } else {
                        // Placeholder
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 300, height: 300)
                            .overlay {
                                VStack {
                                    Image(systemName: "camera")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                    Text("No Photo Available")
                                        .foregroundColor(.gray)
                                }
                            }
                    }
                }
                // picker button (only shows if editing is allowed)
                if !isReadOnly {
                    PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                        HStack {
                            Image(systemName: "photo.badge.plus")
                            Text(pin.imageData == nil ? "Select Photo" : "Change Photo")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedItem) { oldValue, newValue in
                guard let newValue = newValue else { return }
                Task {
                    do {
                        errorMessage = nil
                        guard let data = try await newValue.loadTransferable(type: Data.self),
                              let uiImage = UIImage(data: data) else {
                            throw NSError(domain: "PhotoPinView", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to read image"])
                        }
                        
                        guard let compressedData = firebaseFunctions.compressImage(uiImage),
                              let compressedImage = UIImage(data: compressedData) else {
                            throw NSError(domain: "PhotoPinView", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"])
                        }
                        
                        pin.imageData = compressedData
                        displayImage = Image(uiImage: compressedImage)
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}
