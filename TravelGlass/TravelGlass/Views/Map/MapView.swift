/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that presents all the landmarks in a global map.
*/

import SwiftUI
import MapKit

/// Map type options
enum MapType: String, CaseIterable, Identifiable {
    case explore = "Explore"
    case driving = "Driving"
    case transit = "Transit"
    case satellite = "Satellite"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .explore: return "map"
        case .driving: return "car.fill"
        case .transit: return "bus.fill"
        case .satellite: return "globe.americas.fill"
        }
    }
}

/// View dimension type (2D/3D)
enum ViewDimension: String, CaseIterable, Identifiable {
    case twoD = "2D"
    case threeD = "3D"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .twoD: return "view.2d"
        case .threeD: return "view.3d"
        }
    }
}

/// A view that presents travel scenes in a global map.
struct MapView: View {
    @Environment(ModelData.self) var modelData

    @State private var selectedScene: TravelScene?
    @State private var showingAddVisitedScene = false
    @State private var showingAddPlannedScene = false
    @State private var mapType: MapType = .explore
    @State private var viewDimension: ViewDimension = .twoD
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        @Bindable var modelData = modelData

        ZStack {
            Map(position: $cameraPosition) {
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
            .mapStyle(mapStyleForType)
            .mapCameraKeyframeAnimator(trigger: viewDimension) { camera in
                KeyframeTrack(\MapCamera.pitch) {
                    CubicKeyframe(viewDimension == .threeD ? 45 : 0, duration: 0.5)
                }
            }
            .onAppear {
                if modelData.locationFinder == nil {
                    modelData.locationFinder = LocationFinder()
                }
            }

            // Map controls in bottom-right corner
            VStack(spacing: 12) {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        // 2D/3D toggle button
                        MapControlButton(
                            icon: viewDimension.iconName,
                            label: viewDimension.rawValue
                        ) {
                            withAnimation {
                                viewDimension = viewDimension == .twoD ? .threeD : .twoD
                            }
                        }

                        // Map type picker button
                        Menu {
                            ForEach(MapType.allCases) { type in
                                Button {
                                    withAnimation {
                                        mapType = type
                                    }
                                } label: {
                                    Label(type.rawValue, systemImage: type.iconName)
                                }
                            }
                        } label: {
                            MapControlButton(
                                icon: mapType.iconName,
                                label: mapType.rawValue,
                                isMenu: true
                            )
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingAddVisitedScene = true
                    } label: {
                        Label("Add Visited Place", systemImage: "checkmark.circle.fill")
                    }

                    Button {
                        showingAddPlannedScene = true
                    } label: {
                        Label("Add Planned Destination", systemImage: "clock.circle.fill")
                    }
                } label: {
                    Label("Add Scene", systemImage: "plus")
                }
            }
        }
        .toolbar(removing: .title)
        .sheet(item: $selectedScene) { scene in
            NavigationStack {
                SceneDetailView(scene: scene)
            }
        }
        .sheet(isPresented: $showingAddVisitedScene) {
            AddSceneView(status: .visited)
        }
        .sheet(isPresented: $showingAddPlannedScene) {
            AddSceneView(status: .planned)
        }
    }

    // Computed property for map style based on selected type
    private var mapStyleForType: MapStyle {
        switch mapType {
        case .explore:
            return .standard(pointsOfInterest: .excludingAll)
        case .driving:
            return .standard(pointsOfInterest: .including([.parking, .gasStation]), showsTraffic: true)
        case .transit:
            return .standard(pointsOfInterest: .including([.publicTransport]))
        case .satellite:
            return .imagery(elevation: .realistic)
        }
    }
}

// MARK: - Map Control Button

/// A glass-effect button for map controls
struct MapControlButton: View {
    let icon: String
    let label: String
    var isMenu: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: {
            action?()
        }) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                .overlay(
                    Circle()
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

#Preview {
    MapView()
        .environment(ModelData())
}
