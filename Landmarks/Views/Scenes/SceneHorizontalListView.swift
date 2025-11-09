/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A view that scrolls a list of travel scenes horizontally.
*/

import SwiftUI

/// A view that scrolls a list of travel scenes horizontally.
struct SceneHorizontalListView: View {
    let sceneList: [TravelScene]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: Constants.standardPadding) {
                Spacer()
                    .frame(width: Constants.standardPadding)
                ForEach(sceneList) { scene in
                    NavigationLink(value: scene) {
                        SceneListItemView(scene: scene)
                            .aspectRatio(Constants.landmarkListItemAspectRatio, contentMode: .fill)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

/// A single scene item in the horizontal list.
struct SceneListItemView: View {
    @Environment(ModelData.self) var modelData
    let scene: TravelScene

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image (from associated landmark if available)
            if let firstLandmarkId = scene.associatedLandmarkIds.first,
               let landmark = modelData.landmarksById[firstLandmarkId] {
                Image(landmark.backgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // Fallback gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        scene.status.color.opacity(0.6),
                        scene.status.color
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }

            // Overlay with scene info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: scene.status.symbolName)
                        .font(.caption)

                    if scene.status == .visited, let latestVisit = scene.latestVisit {
                        Text(latestVisit.startDate, style: .date)
                            .font(.caption2)
                    } else if scene.status == .planned, let date = scene.plannedDate {
                        Text(date, style: .date)
                            .font(.caption2)
                    }
                }
                .foregroundStyle(.white.opacity(0.9))

                Text(scene.name)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(scene.country)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 5)
    }
}

#Preview {
    @Previewable @State var modelData = ModelData()

    if !modelData.travelScenes.isEmpty {
        SceneHorizontalListView(sceneList: modelData.travelScenes)
            .frame(height: 180)
            .environment(modelData)
    }
}
