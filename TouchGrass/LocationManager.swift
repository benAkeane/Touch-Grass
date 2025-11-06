//
//  TrackingTestView.swift
//  TouchGrass
//
//  Created by Quinn Doyle on 10/24/25.
//

import MapKit
import FirebaseAuth

final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var region = MKCoordinateRegion(
        center: .init(latitude: 37.334_900, longitude: -122.009_020),
        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    
    @Published var isRecording = false
    @Published var recordedRoute: [CLLocationCoordinate2D] = []
    
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
        isRecording = true
        locationManager.startUpdatingLocation()
    }
    
    func stopRecording(firebaseFunctions: FirebaseFunctions) {
        isRecording = false
        locationManager.stopUpdatingLocation()
        
        guard let userID = firebaseFunctions.currentUser?.uid else { return }
        firebaseFunctions.saveRoute(for: userID, name: "Route \(Date())", coordinates: recordedRoute)
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
        
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        if isRecording {
            recordedRoute.append(location.coordinate)
        }
    }
}
