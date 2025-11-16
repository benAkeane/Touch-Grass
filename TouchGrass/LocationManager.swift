//
//  TrackingTestView.swift
//  TouchGrass
//
//  Created by Quinn Doyle on 10/24/25.
//

import MapKit
import FirebaseAuth
import FirebaseFirestore

struct PhotoPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let timestamp = Date()
    // will use later to link to a picture
    var photoID: String {
        return id.uuidString
    }
}

final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var region = MKCoordinateRegion(
        center: .init(latitude: 37.334_900, longitude: -122.009_020),
        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    
    @Published var isRecording = false
    @Published var recordedRoute: [CLLocationCoordinate2D] = []
    
    @Published var photoPins: [PhotoPin] = []
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.setup()
    }
    
    func setup() {
        switch locationManager.authorizationStatus {
        //If we are authorized then we request location just once, to center the map
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        //If we don´t, we request authorization
        case .notDetermined:
            locationManager.startUpdatingLocation()
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    func startRecording() {
        recordedRoute.removeAll()
        photoPins.removeAll()
        isRecording = true
        locationManager.startUpdatingLocation()
    }
    
    func stopRecording(firebaseFunctions: FirebaseFunctions) {
        isRecording = false
        locationManager.stopUpdatingLocation()
        
        guard let userID = firebaseFunctions.currentUser?.id else { return }
        
        let pinGeoPoints = photoPins.map { GeoPoint(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
        
        firebaseFunctions.saveRoute(for: userID, name: "Route \(Date())", coordinates: recordedRoute, photoPinLocations: pinGeoPoints)
        
//        photoPins = []
    }
    
    func dropPhotoPin() {
            guard let location = locationManager.location?.coordinate else {
                print("Location not available to drop a pin.")
                return
            }
            let newPin = PhotoPin(coordinate: location)
            photoPins.append(newPin)
            print("Dropped pin at: (\(location.latitude), \(location.longitude))")
        }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Something went wrong: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if isRecording {
            recordedRoute.append(location.coordinate)
        }
    }
}
