/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A structure that defines a set/category for organizing travel scenes.
*/

import Foundation
import SwiftUI

/// Represents a category/set for organizing travel scenes.
/// Scenes can belong to multiple sets.
@Observable
class SceneSet: Hashable, Identifiable {
    var id: UUID
    var name: String
    var description: String
    var color: Color
    var iconName: String
    var sceneIds: Set<UUID>

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        color: Color = .blue,
        iconName: String = "folder.fill",
        sceneIds: Set<UUID> = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.color = color
        self.iconName = iconName
        self.sceneIds = sceneIds
    }

    static func == (lhs: SceneSet, rhs: SceneSet) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Example Data
extension SceneSet {
    @MainActor static let exampleData: [SceneSet] = [
        // Asia Adventures
        SceneSet(
            name: "Asia Adventures",
            description: "Exploring the wonders of Asia",
            color: .red,
            iconName: "mountain.2.fill",
            sceneIds: [] // Will be populated with Tokyo's ID
        ),

        // European Classics
        SceneSet(
            name: "European Classics",
            description: "Classic European destinations",
            color: .blue,
            iconName: "building.columns.fill",
            sceneIds: [] // Will be populated with Paris's ID
        ),

        // Bucket List
        SceneSet(
            name: "Bucket List",
            description: "Must-visit places before I die",
            color: .purple,
            iconName: "star.fill",
            sceneIds: [] // Will be populated with Sydney and Machu Picchu IDs
        ),

        // Beach & Coastal
        SceneSet(
            name: "Beach & Coastal",
            description: "Beautiful beaches and coastal cities",
            color: .cyan,
            iconName: "beach.umbrella.fill",
            sceneIds: [] // Will be populated with Sydney's ID
        ),

        // Historical Sites
        SceneSet(
            name: "Historical Sites",
            description: "Ancient wonders and historical landmarks",
            color: .orange,
            iconName: "building.2.fill",
            sceneIds: [] // Will be populated with Paris and Machu Picchu IDs
        )
    ]
}
