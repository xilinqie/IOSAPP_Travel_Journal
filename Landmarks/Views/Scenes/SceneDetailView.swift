/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A detailed view for a travel scene.
*/

import SwiftUI
import MapKit
import PhotosUI

struct SceneDetailView: View {
    @Environment(ModelData.self) private var modelData
    let scene: TravelScene

    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var showingAllPhotos = false
    @State private var showingAddVisit = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: scene.status.symbolName)
                            .font(.largeTitle)
                            .foregroundStyle(scene.status.color)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(scene.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            Text(scene.country)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }

                    // Visit Records Badge (for visited scenes)
                    if scene.status == .visited {
                        if scene.visitCount > 0 {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 12) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "calendar")
                                        Text("Visited \(scene.visitCount) time\(scene.visitCount > 1 ? "s" : "")")
                                    }
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.green.opacity(0.1))
                                    .clipShape(Capsule())

                                    HStack(spacing: 4) {
                                        Image(systemName: "clock")
                                        Text("\(scene.totalDaysVisited) day\(scene.totalDaysVisited > 1 ? "s" : "")")
                                    }
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(.blue.opacity(0.1))
                                    .clipShape(Capsule())

                                    Spacer()

                                    Button(action: { showingAddVisit = true }) {
                                        Label("Add Visit", systemImage: "plus.circle.fill")
                                            .font(.caption)
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                    } else if scene.status == .planned, !scene.formattedPlannedDate.isEmpty {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                            Text("Planned for \(scene.formattedPlannedDate)")
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.orange.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                .padding()

                // Map
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: scene.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                ))) {
                    Marker(scene.name, coordinate: scene.coordinate)
                        .tint(scene.status.color)
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                // Description
                if !scene.description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)

                        Text(scene.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }

                // Visit Records (for visited scenes)
                if scene.status == .visited && !scene.visits.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Visit History")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(scene.visits.sorted(by: { $0.startDate > $1.startDate })) { visit in
                            VisitRecordCard(visit: visit, scene: scene)
                                .padding(.horizontal)
                        }
                    }
                }

                // Notes
                if !scene.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: scene.status == .visited ? "note.text" : "star.fill")
                                .foregroundStyle(scene.status.color)
                            Text(scene.status == .visited ? "Travel Notes" : "Why I Want to Go")
                                .font(.headline)
                        }

                        Text(scene.notes)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(scene.status.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }

                // Sets this scene belongs to
                let sets = modelData.sets(for: scene)
                if !sets.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Part of Sets")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(sets) { set in
                                    NavigationLink(value: set) {
                                        SetCardForScene(set: set)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                // Photos Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Photos")
                            .font(.headline)

                        Spacer()

                        if !scene.photos.isEmpty {
                            Button("View All (\(scene.photos.count))") {
                                showingAllPhotos = true
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding(.horizontal)

                    if scene.photos.isEmpty {
                        // Empty state with add button
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)

                            Text("No photos yet")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            PhotosPicker(
                                selection: $selectedPhotoItems,
                                maxSelectionCount: 10,
                                matching: .images
                            ) {
                                Label("Add Photos", systemImage: "plus.circle.fill")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    } else {
                        // Photo grid preview (show first 6)
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 12) {
                                ForEach(scene.photos.prefix(6)) { photo in
                                    if let image = photo.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 120, height: 120)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .onTapGesture {
                                                showingAllPhotos = true
                                            }
                                    }
                                }

                                // Add more button
                                PhotosPicker(
                                    selection: $selectedPhotoItems,
                                    maxSelectionCount: 10,
                                    matching: .images
                                ) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.largeTitle)
                                            .foregroundStyle(.blue)

                                        Text("Add")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(width: 120, height: 120)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .onChange(of: selectedPhotoItems) { oldValue, newValue in
                    Task {
                        await loadPhotos(from: newValue)
                    }
                }

                // Actions
                VStack(spacing: 12) {
                    if scene.status == .planned {
                        Button(action: {
                            markAsVisited()
                        }) {
                            Label("Mark as Visited", systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }

                    Button(role: .destructive, action: {
                        deleteScene()
                    }) {
                        Label("Delete Scene", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
        }
        .navigationTitle(scene.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAllPhotos) {
            ScenePhotosView(scene: scene)
        }
        .sheet(isPresented: $showingAddVisit) {
            AddVisitView(scene: scene)
        }
    }

    private func markAsVisited() {
        withAnimation {
            modelData.updateSceneStatus(scene, to: .visited)
        }
    }

    private func deleteScene() {
        modelData.removeTravelScene(scene)
    }

    private func loadPhotos(from items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                let photo = ScenePhoto(
                    imageData: data,
                    caption: "",
                    createdAt: Date()
                )
                await MainActor.run {
                    scene.photos.append(photo)
                }
            }
        }
        await MainActor.run {
            selectedPhotoItems = []
        }
    }
}

struct LandmarkCardForScene: View {
    let landmark: Landmark

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(landmark.backgroundImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: landmark.name))
                    .font(.headline)
                    .lineLimit(1)

                Text(landmark.continent)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 200)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct SetCardForScene: View {
    let set: SceneSet

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(set.color.gradient)
                    .frame(width: 44, height: 44)

                Image(systemName: set.iconName)
                    .font(.title3)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(set.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                if !set.description.isEmpty {
                    Text(set.description)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(12)
        .frame(width: 200)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Visit Record Card
struct VisitRecordCard: View {
    let visit: Visit
    let scene: TravelScene

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar.badge.checkmark")
                    .foregroundStyle(.green)
                Text(visit.formattedDuration)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(visit.durationInDays) day\(visit.durationInDays > 1 ? "s" : "")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !visit.notes.isEmpty {
                Text(visit.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.green.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.green.opacity(0.2), lineWidth: 1)
        )
        .contextMenu {
            Button(role: .destructive) {
                deleteVisit()
            } label: {
                Label("Delete Visit", systemImage: "trash")
            }
        }
    }

    private func deleteVisit() {
        withAnimation {
            scene.visits.removeAll { $0.id == visit.id }
        }
    }
}

// MARK: - Add Visit View
struct AddVisitView: View {
    @Environment(\.dismiss) private var dismiss
    let scene: TravelScene

    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        "Start Date",
                        selection: $startDate,
                        displayedComponents: .date
                    )

                    DatePicker(
                        "End Date",
                        selection: $endDate,
                        in: startDate...,
                        displayedComponents: .date
                    )
                } header: {
                    Text("When did you visit?")
                } footer: {
                    let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day! + 1
                    Text("Duration: \(days) day\(days > 1 ? "s" : "")")
                }

                Section("Visit Notes (Optional)") {
                    TextField("What did you do? How was it?", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Visit Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveVisit()
                    }
                }
            }
        }
    }

    private func saveVisit() {
        let visit = Visit(
            startDate: startDate,
            endDate: endDate,
            notes: notes
        )

        withAnimation {
            scene.visits.append(visit)
        }

        dismiss()
    }
}
