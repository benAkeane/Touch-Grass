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
    var date: Date
    
    // Converts firebase geopoints into CLLocationCoordinate2D (what we use in LocationManager)
    var coordinatePoints: [CLLocationCoordinate2D] {
        coordinates.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }
}
