import SwiftUI
import MapKit
import FirebaseFirestore

struct RouteDetailView: View {
    let route: Route

    // Derived region from route coordinates if available
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 60, longitudeDelta: 60)
    )

    // Build a polyline overlay path from route coordinates if present.
    @State private var mapPolyline: [CLLocationCoordinate2D] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                Text(routeName)
                    .font(.largeTitle)
                    .bold()

                // Date of route
                if let date = routeDate {
                    Text(date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Stats (not currently displaying, not sure why)
                if hasAnyStats {
                    HStack(spacing: 16) {
                        if let distance = routeDistance {
                            Label(distance, systemImage: "ruler")
                        }
                        if let duration = routeDuration {
                            Label(duration, systemImage: "clock")
                        }
                    }
                    .font(.body)
                }

                // Map
                if !mapPolyline.isEmpty {
                    Map(initialPosition: .region(region)) {
                        MapPolyline(coordinates: mapPolyline) .stroke(.blue, lineWidth: 4)
                        
                        
                        // Start ping
                        if let start = mapPolyline.first {
                            Annotation("Start", coordinate: start) {
                                ZStack {
                                    
                                    Circle().fill(Color.green).frame(width: 14, height: 14)
                                    Circle().stroke(Color.white, lineWidth: 2).frame(width: 14, height: 14)
                                }
                            }
                        }
                        // End ping
                        if let end = mapPolyline.last {
                            Annotation("End", coordinate: end) {
                                ZStack {
                                    Circle().fill(Color.red).frame(width: 14, height: 14)
                                    Circle().stroke(Color.white, lineWidth: 2).frame(width: 14, height: 14)
                                }
                            }
                        }
                    }
                    
                    
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    // fallback when no coordinates are available
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.15))
                        VStack(spacing: 8) {
                            Image(systemName: "map")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                            Text("No route map available")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: 200)
                }

                Spacer(minLength: 12)
            }
            .padding()
        }
        .navigationTitle("Route Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: configureFromRoute)
    }
}

// -------- HELPERS --------


private extension RouteDetailView {
    var routeName: String {
        // Very defensive way to get routeName since I kept getting errors/crashes doing it normally
        // Hence I am using swift mirror to ensure safety.
        if let mirrorName = Mirror(reflecting: route).children.first(where: { $0.label == "name" })?.value as? String {
            return mirrorName
        }
        return "Route"
    }

    var routeDate: Date? {
        // Read date property defensively
        if let date = Mirror(reflecting: route).children.first(where: { $0.label == "date" })?.value as? Date {
            return date
        }
        return nil
    }

    var routeDistance: String? {
        // Check for typical distance representations (meters/kilometers as Double or Int)
        if let meters = Mirror(reflecting: route).children.first(where: { $0.label == "distance" })?.value as? Double {
            if meters >= 1000 { return String(format: "%.2f km",  meters / 1000.0) }
            return String(format: "%.0f m", meters)
            
        }
        if let metersInt = Mirror(reflecting: route).children.first(where: { $0.label == "distance" })?.value as? Int {
            if metersInt >= 1000 { return String(format: "%.2f km", Double(metersInt) / 1000.0) }
            return "\(metersInt) m"
        }
        return nil
    }

    var routeDuration: String? {
        // Typical duration property in seconds as Double or Int
        if let seconds = Mirror(reflecting: route).children.first(where: { $0.label == "duration" })?.value as? Double {
            return formatTime(seconds: Int(seconds))
        }
        if let secondsInt = Mirror(reflecting: route).children.first(where: { $0.label == "duration" })?.value as? Int {
            return formatTime(seconds: secondsInt)
        }
        return nil
    }

    

    var hasAnyStats: Bool {
        routeDistance != nil || routeDuration != nil
    }

    func configureFromRoute() {
        // Attempt to read an array of coordinates on common property names.
        let children = Array(Mirror(reflecting: route).children)

        // Firestore GeoPoints to CLLocationCoordinate2D
        if let geoPoints = children.first(where: { $0.label == "coordinates" })?.value as? [GeoPoint] {
            let coords = geoPoints.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
            setupMap(with: coords)
            return
        }

        // Native coordinates already in CLLocationCoordinate2D
        if let coords = children.first(where: { $0.label == "coordinates" })?.value as? [CLLocationCoordinate2D] {
            setupMap(with: coords)
            return
        }

        // Array of CLLocation
        if let locations = children.first(where: { $0.label == "locations" })?.value as? [CLLocation] {
            let coords = locations.map { $0.coordinate }
            setupMap(with: coords)
            return
        }

        // Array of dictionaries with lat/lon
        if let points = children.first(where: { $0.label == "coordinates" || $0.label == "points" || $0.label == "path" })?.value as? [[String: Double]] {
            let coords = points.compactMap { dict -> CLLocationCoordinate2D? in
                guard let lat = dict["latitude"], let lon = dict["longitude"] else { return nil }
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
            setupMap(with: coords)
            return
        }

        // Individual start/end lat/longs
        if let startLat = children.first(where: { $0.label == "startLatitude" })?.value as? Double,
           let startLon = children.first(where: { $0.label == "startLongitude" })?.value as? Double,
           let endLat = children.first(where: { $0.label == "endLatitude" })?.value as? Double,
           let endLon = children.first(where: { $0.label == "endLongitude" })?.value as? Double {
            let coords = [CLLocationCoordinate2D(latitude: startLat, longitude: startLon),
                          CLLocationCoordinate2D(latitude: endLat, longitude: endLon)]
            setupMap(with: coords)
            return
        }
    }

    func setupMap(with coords: [CLLocationCoordinate2D]) {
        mapPolyline = coords
        if let first = coords.first {
            var minLat = first.latitude
            var maxLat = first.latitude
            var minLon = first.longitude
            var maxLon = first.longitude
            for c in coords.dropFirst() {
                minLat = min(minLat, c.latitude)
                maxLat = max(maxLat, c.latitude)
                minLon = min(minLon, c.longitude)
                maxLon = max(maxLon, c.longitude)
            }
            let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2.0, longitude: (minLon + maxLon) / 2.0)
            let span = MKCoordinateSpan(latitudeDelta: max(0.01, (maxLat - minLat) * 1.5),
                                        longitudeDelta: max(0.01, (maxLon - minLon) * 1.5))
            region = MKCoordinateRegion(center: center, span: span)
        }
    }

    func formatTime(seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 { return String(format: "%dh %dm %ds", h, m, s) }
        if m > 0 { return String(format: "%dm %ds", m, s) }
        return String(format: "%ds", s)
    }
}

#Preview {
    Text("RouteDetailView can only be seen when you fully run the app/simulator")
}
