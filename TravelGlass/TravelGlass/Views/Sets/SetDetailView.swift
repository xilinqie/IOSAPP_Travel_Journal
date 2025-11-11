/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A detailed view for a scene set showing all its scenes.
*/

import SwiftUI
import MapKit

struct SetDetailView: View {
    @Environment(ModelData.self) private var modelData
    @Environment(\.dismiss) private var dismiss
    let set: SceneSet

    @State private var showingSceneSelection = false
    @State private var isEditing = false

    var body: some View {
        List {
            // Set Info Section
            Section {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(set.color.gradient)
                            .frame(width: 80, height: 80)

                        Image(systemName: set.iconName)
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(set.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        if !set.description.isEmpty {
                            Text(set.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        let sceneCount = modelData.scenes(for: set).count
                        Text("^[\(sceneCount) scene](inflect: true)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }

            // Scenes in this set
            let scenes = modelData.scenes(for: set)
            if scenes.isEmpty {
                Section {
                    ContentUnavailableView {
                        Label("No Scenes in This Set", systemImage: "tray")
                    } description: {
                        Text("Add scenes to this set to organize your travels")
                    } actions: {
                        Button("Add Scenes") {
                            showingSceneSelection = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            } else {
                Section("Scenes") {
                    ForEach(scenes) { scene in
                        NavigationLink(value: scene) {
                            SceneRowForSet(scene: scene)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    modelData.removeScene(scene, from: set)
                                }
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
            }

            // Actions
            Section {
                Button(action: { showingSceneSelection = true }) {
                    Label("Add Scenes to Set", systemImage: "plus.circle.fill")
                }

                Button(role: .destructive, action: deleteSet) {
                    Label("Delete Set", systemImage: "trash")
                }
            }
        }
        .navigationTitle(set.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $showingSceneSelection) {
            SceneSelectionView(set: set)
        }
    }

    private func deleteSet() {
        modelData.removeSceneSet(set)
        dismiss()
    }
}

struct SceneRowForSet: View {
    let scene: TravelScene

    var body: some View {
        HStack(spacing: 12) {
            // Status icon
            Image(systemName: scene.status.symbolName)
                .font(.title2)
                .foregroundStyle(scene.status.color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(scene.name)
                    .font(.headline)

                Text(scene.country)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if scene.status == .visited, let latestVisit = scene.latestVisit {
                    Text("Visited \(latestVisit.startDate, style: .date)")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else if scene.status == .planned, !scene.formattedPlannedDate.isEmpty {
                    Text("Planned for \(scene.formattedPlannedDate)")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct SceneSelectionView: View {
    @Environment(ModelData.self) private var modelData
    @Environment(\.dismiss) private var dismiss
    let set: SceneSet

    var body: some View {
        NavigationStack {
            List {
                ForEach(modelData.travelScenes) { scene in
                    Toggle(isOn: Binding(
                        get: { set.sceneIds.contains(scene.id) },
                        set: { isSelected in
                            withAnimation {
                                if isSelected {
                                    modelData.addScene(scene, to: set)
                                } else {
                                    modelData.removeScene(scene, from: set)
                                }
                            }
                        }
                    )) {
                        HStack(spacing: 12) {
                            Image(systemName: scene.status.symbolName)
                                .foregroundStyle(scene.status.color)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(scene.name)
                                    .font(.headline)
                                Text(scene.country)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .toggleStyle(.switch)
                }
            }
            .navigationTitle("Select Scenes")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var modelData = ModelData()

    NavigationStack {
        if let set = modelData.sceneSets.first {
            SetDetailView(set: set)
                .environment(modelData)
        }
    }
}
