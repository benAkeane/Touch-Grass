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

    var imageData: Data? = nil
    var title: String = ""
    var description: String = ""
        
    static func == (lhs: PhotoPin, rhs: PhotoPin) -> Bool {
        return lhs.id == rhs.id
    }
}

struct FinishedRoute {
    let totalTime: TimeInterval
    let coordinates: [CLLocationCoordinate2D]
    let photoPins: [PhotoPin]
    let distanceMeters: CLLocationDistance
}

private func totalDistance(in coordinates: [CLLocationCoordinate2D]) -> CLLocationDistance {
    guard coordinates.count > 1 else { return 0 }
    var total: CLLocationDistance = 0
    for i in 1..<coordinates.count {
        let a = CLLocation(latitude: coordinates[i-1].latitude, longitude: coordinates[i-1].longitude)
        let b = CLLocation(latitude: coordinates[i].latitude, longitude: coordinates[i].longitude)
        total += a.distance(from: b)
    }
    return total
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

    // Live time (in sec) since startRecording()
    @Published var elapsedTime: TimeInterval = 0

    // MARK: - Private state
    private var recordingStartDate: Date?
    private var timer: DispatchSourceTimer?

    var currentDistanceMeters: CLLocationDistance {
        totalDistance(in: recordedRoute)
    }

    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.setup()
    }

    // Starts timer, stopping previous timer if there is one and reseting to start.
    private func startTimer() {
        stopTimer()
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now(), repeating: .seconds(1), leeway: .milliseconds(200))
        timer.setEventHandler { [weak self] in
            guard let self = self, let start = self.recordingStartDate else { return }
            self.elapsedTime = Date().timeIntervalSince(start)
        }
        self.timer = timer
        timer.resume()
    }

    private func stopTimer() {
        timer?.setEventHandler {}
        timer?.cancel()
        timer = nil
    }

    deinit {
        stopTimer()
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
        elapsedTime = 0
        isRecording = true
        recordingStartDate = Date()
        startTimer()
        locationManager.startUpdatingLocation()
    }
    
    func stopRecording() -> FinishedRoute? {
        isRecording = false
        locationManager.stopUpdatingLocation()
        stopTimer()

        guard let start = recordingStartDate else { return nil }

        let totalTime = Date().timeIntervalSince(start)
        elapsedTime = totalTime
        let distanceMeters = totalDistance(in: recordedRoute)

        // Clear start date to mark end of a session
        recordingStartDate = nil

        return FinishedRoute(
            totalTime: totalTime,
            coordinates: recordedRoute,
            photoPins: photoPins,
            distanceMeters: distanceMeters
        )
    }
    
    // Reset recording function to help with UI
    func resetRecording() {
        isRecording = false
        stopTimer()
        locationManager.stopUpdatingLocation()
        recordedRoute.removeAll()
        photoPins.removeAll()
        elapsedTime = 0
        recordingStartDate = nil
    }
    
    @discardableResult
    func dropPhotoPin() -> PhotoPin? {
        guard let location = locationManager.location?.coordinate else {
            print("Location not available to drop a pin.")
            return nil
        }
        let newPin = PhotoPin(coordinate: location)
        photoPins.append(newPin)
        print("Dropped pin at: (\(location.latitude), \(location.longitude))")
        return newPin
    }
    
    func updatePin(_ pin: PhotoPin) {
            if let index = photoPins.firstIndex(where: { $0.id == pin.id }) {
                photoPins[index] = pin
            }
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
            if let start = recordingStartDate {
                elapsedTime = Date().timeIntervalSince(start)
            }
        }
    }
}
