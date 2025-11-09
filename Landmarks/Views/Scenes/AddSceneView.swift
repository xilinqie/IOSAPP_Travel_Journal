/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A view for adding a new travel scene with hierarchical location selection.
*/

import SwiftUI

struct AddSceneView: View {
    @Environment(ModelData.self) private var modelData
    @Environment(\.dismiss) private var dismiss

    let status: SceneStatus

    // Location selection
    @State private var selectedCountry: Country?
    @State private var selectedRegion: Region?
    @State private var selectedCity: City?

    @State private var description = ""
    @State private var visitStartDate = Date()
    @State private var visitEndDate = Date()
    @State private var plannedDate = Date()
    @State private var visitNotes = ""
    @State private var notes = ""
    @State private var selectedLandmarks: Set<Int> = []

    private let locationDB = LocationDatabase.shared

    var body: some View {
        NavigationStack {
            Form {
                Section("Location") {
                    // Country Picker
                    Picker("Country", selection: $selectedCountry) {
                        Text("Select Country").tag(nil as Country?)
                        ForEach(locationDB.countries, id: \.id) { country in
                            Text(country.localName ?? country.name)
                                .tag(country as Country?)
                        }
                    }
                    .onChange(of: selectedCountry) { oldValue, newValue in
                        selectedRegion = nil
                        selectedCity = nil
                    }

                    // Region Picker (only show when country is selected)
                    if let country = selectedCountry {
                        Picker(country.code == "CN" ? "Province/City" : "State/Region", selection: $selectedRegion) {
                            Text("Select Region").tag(nil as Region?)
                            ForEach(country.regions, id: \.id) { region in
                                Text(region.localName ?? region.name)
                                    .tag(region as Region?)
                            }
                        }
                        .onChange(of: selectedRegion) { oldValue, newValue in
                            selectedCity = nil
                        }
                    }

                    // City Picker (only show when region is selected)
                    if let region = selectedRegion {
                        Picker("City", selection: $selectedCity) {
                            Text("Select City").tag(nil as City?)
                            ForEach(region.cities, id: \.id) { city in
                                Text(city.localName ?? city.name)
                                    .tag(city as City?)
                            }
                        }
                    }

                    // Selected location display
                    if let city = selectedCity {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundStyle(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(city.localName ?? city.name)
                                    .font(.headline)
                                if let region = selectedRegion, let country = selectedCountry {
                                    Text("\(region.localName ?? region.name), \(country.localName ?? country.name)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Details") {
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                if status == .visited {
                    Section {
                        DatePicker(
                            "Start Date",
                            selection: $visitStartDate,
                            displayedComponents: .date
                        )

                        DatePicker(
                            "End Date",
                            selection: $visitEndDate,
                            in: visitStartDate...,
                            displayedComponents: .date
                        )

                        TextField("Visit Notes (optional)", text: $visitNotes, axis: .vertical)
                            .lineLimit(2...4)
                    } header: {
                        Text("When Did You Visit?")
                    } footer: {
                        Text("Enter the date range of your visit")
                    }
                } else {
                    Section {
                        DatePicker(
                            "Planned Date",
                            selection: $plannedDate,
                            displayedComponents: .date
                        )
                    } header: {
                        Text("When Do You Plan to Go?")
                    }
                }

                Section("General Notes") {
                    TextField("Your thoughts, tips, or plans...", text: $notes, axis: .vertical)
                        .lineLimit(4...8)
                }

                Section("Associated Landmarks (Optional)") {
                    if modelData.landmarks.isEmpty {
                        Text("No landmarks available")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(modelData.landmarks) { landmark in
                            Toggle(isOn: Binding(
                                get: { selectedLandmarks.contains(landmark.id) },
                                set: { isSelected in
                                    if isSelected {
                                        selectedLandmarks.insert(landmark.id)
                                    } else {
                                        selectedLandmarks.remove(landmark.id)
                                    }
                                }
                            )) {
                                HStack {
                                    Image(landmark.thumbnailImageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))

                                    Text(String(localized: landmark.name))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(status == .visited ? "Add Visited Place" : "Add Dream Destination")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveScene()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        selectedCountry != nil &&
        selectedRegion != nil &&
        selectedCity != nil
    }

    private func saveScene() {
        guard let country = selectedCountry,
              let _ = selectedRegion,
              let city = selectedCity else {
            return
        }

        var visits: [Visit] = []
        var finalPlannedDate: Date? = nil

        if status == .visited {
            // Create initial visit record
            let visit = Visit(
                startDate: visitStartDate,
                endDate: visitEndDate,
                notes: visitNotes
            )
            visits = [visit]
        } else {
            finalPlannedDate = plannedDate
        }

        let scene = TravelScene(
            name: city.localName ?? city.name,
            country: country.localName ?? country.name,
            description: description,
            latitude: city.latitude ?? 0,
            longitude: city.longitude ?? 0,
            status: status,
            visits: visits,
            plannedDate: finalPlannedDate,
            notes: notes,
            associatedLandmarkIds: Array(selectedLandmarks)
        )

        modelData.addTravelScene(scene)
        dismiss()
    }
}

#Preview {
    AddSceneView(status: .visited)
        .environment(ModelData())
}