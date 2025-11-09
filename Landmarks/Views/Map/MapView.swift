/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that presents all the landmarks in a global map.
*/

import SwiftUI
import MapKit

/// A view that presents travel scenes in a global map.
struct MapView: View {
    @Environment(ModelData.self) var modelData

    @State private var selectedScene: TravelScene?

    var body: some View {
        @Bindable var modelData = modelData

        Map {
            // Travel scene markers - Visited
            ForEach(modelData.visitedScenes) { scene in
                Annotation(scene.name, coordinate: scene.coordinate) {
                    if scene.photos.isEmpty {
                        // Show circular icon for scenes without photos
                        SceneCircularAnnotationView(scene: scene)
                            .onTapGesture {
                                selectedScene = scene
                            }
                    } else {
                        // Show photo stack for scenes with photos
                        PhotoStackAnnotationView(scene: scene)
                            .onTapGesture {
                                selectedScene = scene
                            }
                    }
                }
                .annotationTitles(.hidden)
            }

            // Travel scene markers - Planned
            ForEach(modelData.plannedScenes) { scene in
                Annotation(scene.name, coordinate: scene.coordinate) {
                    if scene.photos.isEmpty {
                        // Show circular icon for scenes without photos
                        SceneCircularAnnotationView(scene: scene)
                            .onTapGesture {
                                selectedScene = scene
                            }
                    } else {
                        // Show photo stack for scenes with photos
                        PhotoStackAnnotationView(scene: scene)
                            .onTapGesture {
                                selectedScene = scene
                            }
                    }
                }
                .annotationTitles(.hidden)
            }

            if modelData.locationFinder?.currentLocation != nil {
                UserAnnotation()
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .onAppear {
            if modelData.locationFinder == nil {
                modelData.locationFinder = LocationFinder()
            }
        }
        .toolbar(removing: .title)
        .sheet(item: $selectedScene) { scene in
            NavigationStack {
                SceneDetailView(scene: scene)
            }
        }
    }
}

#Preview {
    MapView()
        .environment(ModelData())
}
