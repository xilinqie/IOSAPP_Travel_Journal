/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A view that shows featured travel scenes and organizes scenes by visit status.
*/

import SwiftUI

/// A view that shows featured travel scenes with a scrollable carousel.
struct LandmarksView: View {
    @Environment(ModelData.self) private var modelData
    @Environment(\.isSearching) private var isSearching
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        @Bindable var modelData = modelData

        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: Constants.standardPadding) {

                // Featured carousel with all scenes
                if !modelData.travelScenes.isEmpty {
                    SceneFeaturedCarouselView(scenes: modelData.travelScenes)
                        .flexibleHeaderContent()
                } else {
                    // Empty state
                    EmptyFeaturedView()
                        .flexibleHeaderContent()
                }

                // Visited Scenes Section
                if !modelData.visitedScenes.isEmpty {
                    Group {
                        SectionTitleView(
                            title: "Places I've Visited",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        SceneHorizontalListView(sceneList: modelData.visitedScenes)
                            .containerRelativeFrame(.vertical) { height, axis in
                                let proposedHeight = height * Constants.landmarkListPercentOfHeight
                                if proposedHeight > Constants.landmarkListMinimumHeight {
                                    return proposedHeight
                                }
                                return Constants.landmarkListMinimumHeight
                            }
                    }
                }

                // Planned Scenes Section
                if !modelData.plannedScenes.isEmpty {
                    Group {
                        SectionTitleView(
                            title: "Places I Plan to Visit",
                            icon: "clock.circle.fill",
                            color: .orange
                        )
                        SceneHorizontalListView(sceneList: modelData.plannedScenes)
                            .containerRelativeFrame(.vertical) { height, axis in
                                let proposedHeight = height * Constants.landmarkListPercentOfHeight
                                if proposedHeight > Constants.landmarkListMinimumHeight {
                                    return proposedHeight
                                }
                                return Constants.landmarkListMinimumHeight
                            }
                    }
                }

                // Empty state if no scenes at all
                if modelData.travelScenes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)

                        Text("No Travel Scenes Yet")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Start adding places you've visited or plan to visit!")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                }
            }
        }
        .flexibleHeaderScrollView()
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { _, newOffset in
            scrollOffset = newOffset
        }
        .ignoresSafeArea(.keyboard)
        .ignoresSafeArea(edges: .top)
        .toolbar(removing: .title)
        .toolbarBackground(scrollOffset < -50 ? .visible : .hidden, for: .navigationBar)
        .navigationDestination(for: TravelScene.self) { scene in
            SceneDetailView(scene: scene)
        }
        .navigationDestination(for: Landmark.self) { landmark in
            LandmarkDetailView(landmark: landmark)
        }
    }
}

private struct SectionTitleView: View {
    var title: String
    var icon: String
    var color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
        }
        .font(.title2)
        .bold()
        .padding(.top, Constants.titleTopPadding)
        .padding(.bottom, Constants.titleBottomPadding)
        .padding(.leading, Constants.leadingContentInset)
    }
}

private struct EmptyFeaturedView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.6), .purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 16) {
                Image(systemName: "airplane.departure")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)

                Text("Start Your Journey")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("Add your first travel destination")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .backgroundExtensionEffect()
    }
}

#Preview {
    @Previewable @State var modelData = ModelData()
    
    LandmarksView()
        .environment(modelData)
        .onGeometryChange(for: CGSize.self) { geometry in
            geometry.size
        } action: {
            modelData.windowSize = $0
        }
}
