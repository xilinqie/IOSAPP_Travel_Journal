/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A view that displays all visited travel scenes (Scenes Unlocked).
*/

import SwiftUI
import MapKit

struct ScenesUnlockedView: View {
    @Environment(ModelData.self) private var modelData
    @State private var showingAddScene = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.green)

                        Text("Scenes Unlocked")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }

                    Text("\(modelData.visitedScenes.count) places visited")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)

                // Visited Scenes List
                if modelData.visitedScenes.isEmpty {
                    emptyStateView
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(modelData.visitedScenes) { scene in
                            NavigationLink(value: scene) {
                                SceneCardView(scene: scene)
                            }
                            .buttonStyle(.plain)
                            .transition(.blurReplace)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Scenes Unlocked")
        .navigationDestination(for: TravelScene.self) { scene in
            SceneDetailView(scene: scene)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddScene = true }) {
                    Label("Add Scene", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddScene) {
            AddSceneView(status: .visited)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "globe.americas")
                .font(.system(size: 80))
                .foregroundStyle(.secondary.opacity(0.5))

            VStack(spacing: 8) {
                Text("No Visited Places Yet")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Start your journey by adding places you've already visited!")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button("Add Your First Place") {
                showingAddScene = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

struct SceneCardView: View {
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

                if scene.status == .visited, let latestVisit = scene.latestVisit {
                    Text(latestVisit.startDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
                    Image(systemName: "note.text")
                        .foregroundStyle(.blue)
                        .font(.caption)

                    Text(scene.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct LandmarkMiniCard: View {
    let landmark: Landmark

    var body: some View {
        HStack(spacing: 8) {
            Image(landmark.thumbnailImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(String(localized: landmark.name))
                .font(.caption)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
