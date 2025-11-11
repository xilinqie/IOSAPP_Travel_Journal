/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
The main app entry point for TravelGlass.
*/

import SwiftUI

@main
struct TravelGlassApp: App {
    @State private var modelData = ModelData()

    var body: some Scene {
        WindowGroup {
            LandmarksSplitView()
                .environment(modelData)
                .onGeometryChange(for: CGSize.self) { geometry in
                    geometry.size
                } action: { newSize in
                    modelData.windowSize = newSize
                }
        }
    }
}
