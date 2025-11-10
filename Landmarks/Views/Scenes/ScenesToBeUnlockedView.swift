/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A view that displays all planned travel scenes (Scenes to be Unlocked).
*/

import SwiftUI
import MapKit

struct ScenesToBeUnlockedView: View {
    @Environment(ModelData.self) private var modelData
    @State private var showingAddScene = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "clock.circle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)

                        Text("Scenes to be Unlocked")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }

                    Text("\(modelData.plannedScenes.count) places on your bucket list")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)

                // Planned Scenes List
                if modelData.plannedScenes.isEmpty {
                    emptyStateView
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(modelData.plannedScenes) { scene in
                            PlannedSceneCardView(scene: scene)
                                .transition(.blurReplace)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddScene = true }) {
                    Label("Add Scene", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddScene) {
            AddSceneView(status: .planned)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "map")
                .font(.system(size: 80))
                .foregroundStyle(.secondary.opacity(0.5))

            VStack(spacing: 8) {
                Text("No Planned Adventures Yet")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Start dreaming! Add places you want to visit in the future.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("Add Your Dream Destination") {
                showingAddScene = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

struct PlannedSceneCardView: View {
    @Environment(ModelData.self) private var modelData
    let scene: TravelScene

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with status indicator
            HStack {
                Image(systemName: scene.status.symbolName)
                    .foregroundStyle(scene.status.color)

                VStack(alignment: .leading, spacing: 4) {
                    Text(scene.name)
                        .font(.title3)
                        .fontWeight(.bold)

                    Text(scene.country)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if scene.status == .planned, !scene.formattedPlannedDate.isEmpty {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Planned for")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text(scene.formattedPlannedDate)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                    }
                }
            }

            // Description
            if !scene.description.isEmpty {
                Text(scene.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            // Notes
            if !scene.notes.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)

                    Text(scene.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            // Action buttons
            HStack(spacing: 12) {
                Button(action: {
                    markAsVisited(scene)
                }) {
                    Label("Mark as Visited", systemImage: "checkmark.circle")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(.green)

                Spacer()
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private func markAsVisited(_ scene: TravelScene) {
        withAnimation {
            modelData.updateSceneStatus(scene, to: .visited)
        }
    }
}
