/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A carousel view that shows featured travel scenes with scrollable images.
*/

import SwiftUI

/// A carousel view that shows featured travel scenes.
struct SceneFeaturedCarouselView: View {
    @Environment(ModelData.self) var modelData
    let scenes: [TravelScene]

    @State private var currentIndex: Int = 0

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(scenes.enumerated()), id: \.element.id) { index, scene in
                SceneFeaturedItemView(scene: scene)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

/// A single featured scene item with image overlay.
struct SceneFeaturedItemView: View {
    @Environment(ModelData.self) var modelData
    let scene: TravelScene

    var body: some View {
        NavigationLink(value: scene) {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        scene.status.color.opacity(0.8),
                        scene.status.color
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Overlay content
                VStack {
                    Spacer()

                    VStack(spacing: 8) {
                        // Status badge
                        HStack(spacing: 6) {
                            Image(systemName: scene.status.symbolName)
                            Text(scene.status.rawValue)
                        }
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())

                        // Scene name
                        Text(scene.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .shadow(radius: 10)

                        // Country
                        Text(scene.country)
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.9))
                            .shadow(radius: 5)

                        // Date info
                        if scene.status == .visited, let latestVisit = scene.latestVisit {
                            Text("Last visited \(latestVisit.startDate, style: .date)")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                        } else if scene.status == .planned, let date = scene.plannedDate {
                            Text("Planned for \(date, style: .date)")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                        }

                        // Learn More button
                        Button("Learn More") {
                            modelData.path.append(scene)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(scene.status.color)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, Constants.learnMoreBottomPadding)
                }
            }
            .backgroundExtensionEffect()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var modelData = ModelData()

    if let scene = modelData.travelScenes.first {
        SceneFeaturedItemView(scene: scene)
            .frame(height: 400)
            .environment(modelData)
    }
}
