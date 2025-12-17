//
//  VisitedPLacesView.swift
//  WeatherDashboardTemplate
//
//  Created by girish lukka on 18/10/2025.
//

import SwiftUI
import SwiftData


struct VisitedPlacesView: View {
    @EnvironmentObject var vm: MainAppViewModel
   // @Environment(\.modelContext) private var context // Not used in body, but kept for completeness
    
    // MARK:  add local variables for this view
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                
                // MARK: - Header
                Text("Visited Places 📍")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                
                // MARK: - Empty State
                if vm.visited.isEmpty {
                    Spacer()
                    Text("No places visited yet")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    
                    // MARK: - Places List
                    List {
                        ForEach(vm.visited) { place in
                            Button {
                                Task {
                                    await vm.loadLocation(fromPlace: place)
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(place.name)
                                        .font(.headline)
                                    
                                    Text("Lat: \(place.latitude), Lon: \(place.longitude)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
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
    
    //    var body: some View {
    //        VStack{
    //            Text("Image shows the information to be presented in this view")
    //            Spacer()
    //            Image("places")
    //                .resizable()
    //
    //            Spacer()
    //        }
    //        .frame(height: 600)
    //    }
    //}
}

#Preview {
    let vm = MainAppViewModel(context: ModelContext(ModelContainer.preview))
    VisitedPlacesView()
        .environmentObject(vm)
}
