//
//  VisitedPLacesView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData

// shows previously searched locations
struct VisitedPlacesView: View {
    @EnvironmentObject var vm: MainAppViewModel
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                
                // title
                Text("Visited Places")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                
                // empty state shown when the user has not searched any places
                if vm.visited.isEmpty {
                    Spacer()
                    Text("No places visited yet")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    
                    // saved places list show all previous search
                    List {
                        ForEach(vm.visited) { place in
                            // tap to reload location
                            Button {
                                Task {
                                    await vm.loadLocation(fromPlace: place)
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    //name of location
                                    Text(place.name)
                                        .font(.headline)
                                    // coordinates of place
                                    Text("Lat: \(place.latitude), Lon: \(place.longitude)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        //swipe to delete permenantly 
                        .onDelete { indexSet in
                            indexSet.forEach {
                                vm.delete(place: vm.visited[$0])
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Saved Places")
        }
    }
    
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    VisitedPlacesView()
        .environmentObject(vm)
}
