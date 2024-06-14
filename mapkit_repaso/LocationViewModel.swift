//
//  LocationViewModel.swift
//  mapkit_repaso
//
//  Created by Pedro on 10/6/24.
//

import Foundation
import CoreLocation
import MapKit

final class LocationViewModel: NSObject, ObservableObject {
    private struct DefaultRegion {
        static let latitude = 37.7666 
        static let longitude = -3.9088
    }
    
    private struct Span {
        static let delta = 0.1
    }
    
    @Published var userHasLocation: Bool = false
    @Published var userLocation: MKCoordinateRegion = .init(
        center: CLLocationCoordinate2D(latitude: DefaultRegion.latitude, longitude: DefaultRegion.longitude),
        span: MKCoordinateSpan(latitudeDelta: Span.delta, longitudeDelta: Span.delta)
    )
    @Published var pointsOfInterest: [MKPointAnnotation] = []
    
    private let locationManager: CLLocationManager = .init()
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    private func updateAuthorizationStatus(status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .notDetermined, .restricted, .denied:
                self.userHasLocation = false
            case .authorizedAlways, .authorizedWhenInUse:
                self.userHasLocation = true
            @unknown default:
                print("Unhandled state")
            }
        }
    }

    private func updateUserLocation(location: CLLocation) {
        DispatchQueue.main.async {
            self.userLocation = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: Span.delta, longitudeDelta: Span.delta)
            )
        }
    }

    func searchLocation(query: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query

        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard let response = response else {
                print("Error: \(String(describing: error))")
                return
            }
            
            if let item = response.mapItems.first {
                let coordinate = item.placemark.coordinate
                DispatchQueue.main.async {
                    self.userLocation = MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: Span.delta, longitudeDelta: Span.delta)
                    )
                }
            }
        }
    }
    
    func searchPointsOfInterest() {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "restaurant"
        searchRequest.region = userLocation
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard let response = response else {
                print("Error: \(String(describing: error))")
                return
            }
            
            let annotations = response.mapItems.map { item -> MKPointAnnotation in
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                annotation.subtitle = item.placemark.title
                return annotation
            }
            
            DispatchQueue.main.async {
                self.pointsOfInterest = annotations
            }
        }
    }
}

extension LocationViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Location \(location)")
        updateUserLocation(location: location)
        searchPointsOfInterest()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        updateAuthorizationStatus(status: status)
    }
}

