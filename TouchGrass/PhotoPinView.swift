//
//  PhotoPinView.swift
//  TouchGrass
//
//  Created by Marco Rubens on 11/19/25.
//

import SwiftUI
import PhotosUI
import UIKit
import AVFoundation

struct PhotoPinView: View {
    @Binding var pin: PhotoPin
    
    @EnvironmentObject var firebaseFunctions: FirebaseFunctions
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var displayImage: Image? = nil
    @State private var errorMessage: String? = nil
    @State private var showCamera = false
    @State private var showPermissionAlert = false
    
    private let mintGreen = Color(red: 0.78, green: 0.93, blue: 0.80)
    private let softGreen = Color(red: 0.35, green: 0.60, blue: 0.40)
    
    // if true for RouteDetailView
    // if false for ContentView recording
    var isReadOnly: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                mintGreen.opacity(0.35)
                    .ignoresSafeArea()
                VStack(spacing: 20) {
                    if isReadOnly {
                        Text(pin.title.isEmpty ? "Untitled" : pin.title)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(mintGreen.opacity(0.3))
                            .foregroundColor(softGreen)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    } else {
                        TextField("Enter Image Title", text: $pin.title)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(mintGreen.opacity(0.3))
                            .foregroundColor(softGreen)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    ZStack {
                        if let displayImage = displayImage {
                            displayImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 300, height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(softGreen, lineWidth: 3))
                            
                        } else if let data = pin.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 300, height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(softGreen, lineWidth: 3))
                            
                        } else if let urlString = pin.imageURL, let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 300, height: 300)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 300, height: 300)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(softGreen, lineWidth: 3))
                                case .failure:
                                    VStack {
                                        Image(systemName: "exclamationmark.triangle")
                                        Text("Failed to load")
                                    }
                                    .frame(width: 300, height: 300)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            
                        } else {
                            // Placeholder
                            RoundedRectangle(cornerRadius: 20)
                                .fill(mintGreen.opacity(0.3))
                        }
                    }
                    if isReadOnly {
                        Text(pin.description.isEmpty ? "No Description" : pin.description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(mintGreen.opacity(0.3))
                            .foregroundColor(softGreen)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    } else {
                        TextField("Enter Description", text: $pin.description, axis: .vertical)
                            .lineLimit(3...6)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(mintGreen.opacity(0.3))
                            .foregroundColor(softGreen)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    // Buttons (only shows if editing is allowed)
                    if !isReadOnly {
                        HStack(spacing: 12) {
                            // Camera Button
                            Button(action: {
                                checkCameraPermission()
                            }) {
                                VStack {
                                    Image(systemName: "camera.fill")
                                    Text("Camera")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(UIImagePickerController.isSourceTypeAvailable(.camera) ? softGreen : Color.gray)
                                .cornerRadius(10)
                            }
                            .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                            
                            // Library Button
                            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                VStack {
                                    Image(systemName: "photo.on.rectangle")
                                    Text("Library")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(softGreen)
                                .cornerRadius(10)
                            }
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
                        .foregroundColor(softGreen)
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
                            processImage(uiImage)
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
                .sheet(isPresented: $showCamera) {
                    CameraInput { image in
                        processImage(image)
                    }
                }
                .alert("Camera Access Required", isPresented: $showPermissionAlert) {
                    Button("Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Please enable camera access in your device settings to take photos.")
                }
            }
        }
    }
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        showCamera = true
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert = true
        @unknown default:
            break
        }
    }
    
    private func processImage(_ uiImage: UIImage) {
        guard let compressedData = firebaseFunctions.compressImage(uiImage),
              let compressedImage = UIImage(data: compressedData) else {
            errorMessage = "Failed to compress image"
            return
        }
        
        pin.imageData = compressedData
        displayImage = Image(uiImage: compressedImage)
    }
}

struct CameraInput: UIViewControllerRepresentable {
    var onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraInput

        init(parent: CameraInput) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
