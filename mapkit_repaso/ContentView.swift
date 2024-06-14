//
//  ContentView.swift
//  mapkit_repaso
//
//  Created by Pedro on 10/6/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var locationViewModel = LocationViewModel()
    @State private var searchQuery: String = ""
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $locationViewModel.userLocation, showsUserLocation: true, annotationItems: locationViewModel.pointsOfInterest) { place in
                MapMarker(coordinate: place.coordinate, tint: .red)
            }
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    TextField("Buscar ubicación", text: $searchQuery, onCommit: {
                        locationViewModel.searchLocation(query: searchQuery)
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(8)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    Button(action: {
                        locationViewModel.searchLocation(query: searchQuery)
                    }) {
                        Image(systemName: "magnifyingglass")
                            .padding(8)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                    }
                    .padding(.trailing)
                }
                .padding(.top, 50) 
                
                Spacer()
                
                if locationViewModel.userHasLocation {
                    VStack {
                        Text("Localización Aceptada ✅")
                            .bold()
                            .padding(.top, 12)
                        Link("Pulsa para cambiar la autorización de Localización", destination: URL(string: UIApplication.openSettingsURLString)!)
                            .padding(32)
                    }
                } else {
                    VStack {
                        Text("Localización NO Aceptada ❌")
                            .bold()
                            .padding(.top, 12)
                        Link("Pulsa para cambiar la autorización de Localización", destination: URL(string: UIApplication.openSettingsURLString)!)
                            .padding(32)
                    }
                }
            }
        }
    }
}

extension MKPointAnnotation: Identifiable {}

#Preview {
    ContentView()
}

