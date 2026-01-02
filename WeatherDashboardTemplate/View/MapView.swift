//
//  MapView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData
import MapKit

struct MapView: View {
    @EnvironmentObject var vm: MainAppViewModel
    
    var body: some View {
           VStack(spacing: 0) {
                
               //interactive map shows the pins for the top tourist attractions
               Map(
                   coordinateRegion: $vm.mapRegion,
                   annotationItems: vm.pois
               ) { poi in
                   // map pin
                   MapAnnotation(
                       coordinate: CLLocationCoordinate2D(
                           latitude: poi.latitude,
                           longitude: poi.longitude
                       )
                   ) {
    
                       VStack {
                           Image(systemName: "mappin.circle.fill")
                               .font(.title)
                               .foregroundColor(.red)
                               .onTapGesture {
                                   // Zoom to ~500m region
                                   vm.mapRegion = MKCoordinateRegion(
                                       center: CLLocationCoordinate2D(
                                           latitude: poi.latitude,
                                           longitude: poi.longitude
                                       ),
                                       span: MKCoordinateSpan(
                                           latitudeDelta: 0.005,
                                           longitudeDelta: 0.005
                                       )
                                   )
                               }
                           //open google for long press
                               .onLongPressGesture {
                                   openGoogleSearch(for: poi.name)
                               }
                           // name label for POI
                           Text(poi.name)
                               .font(.caption)
                               .fixedSize()
                       }
                   }
               }
               .frame(height: 320)

               // list of poi
               VStack(alignment: .leading) {
                   //title
                   Text("Top 5 Tourist Attractions in \(vm.activePlaceName)")
                       .font(.headline)
                       .padding(.horizontal)
                       .padding(.top, 8)
                   //scpollable list of pois
                   ScrollView {
                       VStack(spacing: 12) {
                           ForEach(vm.pois) { poi in
                               Button {
                                   // Center map on POI
                                   vm.mapRegion = MKCoordinateRegion(
                                       center: CLLocationCoordinate2D(
                                           latitude: poi.latitude,
                                           longitude: poi.longitude
                                       ),
                                       span: MKCoordinateSpan(
                                           latitudeDelta: 0.005,
                                           longitudeDelta: 0.005
                                       )
                                   )
                               } label: {
                                   HStack {
                                       Image(systemName: "mappin.and.ellipse")
                                           .foregroundColor(.orange)

                                       Text(poi.name)
                                           .font(.body)

                                       Spacer()
                                   }
                                   .padding()
                                   .background(.thinMaterial)
                                   .cornerRadius(12)
                                   .padding(.horizontal)
                               }
                           }
                       }
                       .padding(.bottom)
                   }
               }
           }
           .navigationTitle("Map")
       }

       // MARK: - Helper
       private func openGoogleSearch(for place: String) {
           let query = place.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
           let urlString = "https://www.google.com/search?q=\(query)"
           if let url = URL(string: urlString) {
               UIApplication.shared.open(url)
           }
       }
    
}
#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    MapView()
        .environmentObject(vm)
}
