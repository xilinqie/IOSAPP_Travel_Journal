/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that shows a single landmark, with an image and description.
*/

import SwiftUI
import MapKit
import FoundationModels

/// A view that shows a single landmark, with an image and description.
struct LandmarkDetailView: View {
    @Environment(ModelData.self) private var modelData
    let landmark: Landmark
    @State private var showingAIAssistant = false

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: Constants.landmarkImagePadding) {
                Image(landmark.backgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .backgroundExtensionEffect()
                    .flexibleHeaderContent()

                VStack(alignment: .leading) {
                    Text(landmark.name)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(landmark.description)
                        .textSelection(.enabled)
                }
                .padding(.leading, Constants.leadingContentInset)
                .padding(.trailing, Constants.leadingContentInset * 2)
            }
        }
        .flexibleHeaderScrollView()
        .toolbar {
            ToolbarSpacer(.flexible)

            ToolbarItem {
                ShareLink(item: landmark, preview: landmark.sharePreview)
            }

            ToolbarSpacer(.fixed)

            ToolbarItemGroup {
                LandmarkFavoriteButton(landmark: landmark)

                LandmarkCollectionsMenu(landmark: landmark)
            }

            ToolbarSpacer(.fixed)

            // AI Travel Assistant Button
            ToolbarItem {
                Button("AI Travel Tips", systemImage: "sparkles") {
                    showingAIAssistant = true
                }
                .disabled(SystemLanguageModel.default.availability != .available)
            }

            ToolbarSpacer(.fixed)

            ToolbarItem {
                Button("Info", systemImage: "info") {
                    modelData.selectedLandmark = landmark
                    modelData.isLandmarkInspectorPresented.toggle()
                }
            }
        }
        .toolbar(removing: .title)
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showingAIAssistant) {
            LandmarkAIAssistantView(landmark: landmark)
        }
    }
}

private struct FavoriteButtonLabel: View {
    var isFavorite: Bool
    var body: some View {
        Label(isFavorite ? "Unfavorite" : "Favorite", systemImage: "heart")
            .symbolVariant(isFavorite ? .fill : .none)
    }
}

#Preview {
    @Previewable @State var modelData = ModelData()
    let previewLandmark = modelData.landmarksById[1016] ?? modelData.landmarks.first!

    NavigationSplitView {
        List {
            Section {
                ForEach(NavigationOptions.mainPages) { page in
                    NavigationLink(value: page) {
                        Label(page.name, systemImage: page.symbolName)
                    }
                }
            }
        }
    } detail: {
        LandmarkDetailView(landmark: previewLandmark)
    }
    .inspector(isPresented: $modelData.isLandmarkInspectorPresented) {
        if let landmark = modelData.selectedLandmark {
            LandmarkDetailInspectorView(landmark: landmark, inspectorIsPresented: $modelData.isLandmarkInspectorPresented)
        } else {
            EmptyView()
        }
    }
    .environment(modelData)
    .onGeometryChange(for: CGSize.self) { geometry in
        geometry.size
    } action: {
        modelData.windowSize = $0
    }
}
