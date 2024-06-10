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
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $locationViewModel.userLocation, showsUserLocation: true)
                .ignoresSafeArea()
            if locationViewModel.userHasLocation {
                Text("Localización Aceptada ✅")
                    .bold()
                    .padding(.top, 12)
                Link("Pulsa para cambiar la autorización de Localización", destination: URL(string: UIApplication.openSettingsURLString)!)
                    .padding(32)
            } else {
                Text("Localización NO Aceptada ❌")
                    .bold()
                    .padding(.top, 12)
                Link("Pulsa para cambiar la autorización de Localización", destination: URL(string: UIApplication.openSettingsURLString)!)
                    .padding(32)
            }
        }
    }
}
    
    #Preview {
        ContentView()
    }
