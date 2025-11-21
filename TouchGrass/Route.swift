//
//  Route.swift
//  TouchGrass
//
//  Created by Ben Keane on 11/10/25.
//
// Route data model for how a route is defined in firebase

import FirebaseFirestore
import MapKit

struct Route: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var coordinates: [GeoPoint]
    
    // Maps to "photoPins" in Firestore
    var savedPhotoPins: [SavedPhotoPin]?
    
    var date: Date
    var totalTime: Double?
    
    var coordinatePoints: [CLLocationCoordinate2D] {
        coordinates.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }
    
    var routePhotoPins: [PhotoPin] {
        guard let saved = savedPhotoPins else { return [] }
        return saved.map { savedPin in
            // Create the pin
            var pin = PhotoPin(coordinate: CLLocationCoordinate2D(latitude: savedPin.latitude, longitude: savedPin.longitude))
            
            pin.title = savedPin.title ?? ""
            pin.description = savedPin.description ?? ""
            
            // Reconstruct the image data from Base64
            if let base64 = savedPin.imageBase64 {
                pin.imageData = Data(base64Encoded: base64)
            }
            return pin
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case coordinates
        case savedPhotoPins = "photoPins"
        case date
        case totalTime
    }
}

struct SavedPhotoPin: Codable, Identifiable {
    var id = UUID()
    let latitude: Double
    let longitude: Double
    let imageBase64: String?
    let title: String?
    let description: String?

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case imageBase64
        case title
        case description
    }
}
