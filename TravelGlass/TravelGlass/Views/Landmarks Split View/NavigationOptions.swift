/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
An enumeration of navigation options in the app.
*/

import SwiftUI

/// An enumeration of navigation options in the app.
enum NavigationOptions: Equatable, Hashable, Identifiable {
    /// A case that represents viewing the app's landmarks, organized by continent.
    case landmarks
    /// A case that represents viewing the app's landmarks on a map.
    case map
    /// A case that represents viewing scenes the user has already visited.
    case scenesUnlocked
    /// A case that represents viewing scenes the user plans to visit.
    case scenesToBeUnlocked
    /// A case that represents viewing and managing scene sets/categories.
    case sets

    static let mainPages: [NavigationOptions] = [.landmarks, .map, .scenesUnlocked, .scenesToBeUnlocked, .sets]

    var id: String {
        switch self {
        case .landmarks: return "Landmarks"
        case .map: return "Map"
        case .scenesUnlocked: return "Scenes Unlocked"
        case .scenesToBeUnlocked: return "Scenes to be Unlocked"
        case .sets: return "Sets"
        }
    }

    var name: LocalizedStringResource {
        switch self {
        case .landmarks: LocalizedStringResource("Landmarks", comment: "Title for the Landmarks tab, shown in the sidebar.")
        case .map: LocalizedStringResource("Map", comment: "Title for the Map tab, shown in the sidebar.")
        case .scenesUnlocked: LocalizedStringResource("Scenes Unlocked", comment: "Title for the visited scenes tab, shown in the sidebar.")
        case .scenesToBeUnlocked: LocalizedStringResource("Scenes to be Unlocked", comment: "Title for the planned scenes tab, shown in the sidebar.")
        case .sets: LocalizedStringResource("Sets", comment: "Title for the scene sets/categories tab, shown in the sidebar.")
        }
    }

    var symbolName: String {
        switch self {
        case .landmarks: "building.columns"
        case .map: "map"
        case .scenesUnlocked: "checkmark.circle.fill"
        case .scenesToBeUnlocked: "clock.circle"
        case .sets: "folder.fill"
        }
    }

    /// A view builder that the split view uses to show a view for the selected navigation option.
    @MainActor @ViewBuilder func viewForPage() -> some View {
        switch self {
        case .landmarks: LandmarksView()
        case .map: MapView()
        case .scenesUnlocked: ScenesUnlockedView()
        case .scenesToBeUnlocked: ScenesToBeUnlockedView()
        case .sets: SetsView()
        }

    }
}
