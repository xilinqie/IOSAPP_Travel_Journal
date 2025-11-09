/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A structure that defines a travel scene (city/destination).
*/

import Foundation
import CoreLocation
import SwiftUI

/// A photo associated with a travel scene.
struct ScenePhoto: Identifiable, Hashable {
    var id: UUID = UUID()
    var imageData: Data
    var caption: String
    var createdAt: Date

    var image: Image? {
        #if os(iOS)
        if let uiImage = UIImage(data: imageData) {
            return Image(uiImage: uiImage)
        }
        #elseif os(macOS)
        if let nsImage = NSImage(data: imageData) {
            return Image(nsImage: nsImage)
        }
        #endif
        return nil
    }
}

/// A visit record for a travel scene.
struct Visit: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var startDate: Date
    var endDate: Date
    var notes: String

    var formattedDuration: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
            // Single day
            return formatter.string(from: startDate)
        } else {
            // Date range
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }
    }

    var durationInDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1
    }
}

/// Represents a travel destination/city that the user has visited or plans to visit.
@Observable
class TravelScene: Hashable, Identifiable {
    var id: UUID
    var name: String
    var country: String
    var description: String
    var latitude: Double
    var longitude: Double
    var status: SceneStatus
    var visits: [Visit] // Multiple visit records
    var plannedDate: Date?
    var notes: String
    var associatedLandmarkIds: [Int]
    var photos: [ScenePhoto]

    init(
        id: UUID = UUID(),
        name: String,
        country: String,
        description: String = "",
        latitude: Double,
        longitude: Double,
        status: SceneStatus,
        visits: [Visit] = [],
        plannedDate: Date? = nil,
        notes: String = "",
        associatedLandmarkIds: [Int] = [],
        photos: [ScenePhoto] = []
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.status = status
        self.visits = visits
        self.plannedDate = plannedDate
        self.notes = notes
        self.associatedLandmarkIds = associatedLandmarkIds
        self.photos = photos
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // Most recent visit
    var latestVisit: Visit? {
        visits.max(by: { $0.startDate < $1.startDate })
    }

    // Total days visited
    var totalDaysVisited: Int {
        visits.reduce(0) { $0 + $1.durationInDays }
    }

    // Number of times visited
    var visitCount: Int {
        visits.count
    }

    var formattedPlannedDate: String {
        guard let date = plannedDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    static func == (lhs: TravelScene, rhs: TravelScene) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// The status of a travel scene.
enum SceneStatus: String, Codable, CaseIterable {
    case visited = "Visited"
    case planned = "Planned"

    var symbolName: String {
        switch self {
        case .visited:
            return "checkmark.circle.fill"
        case .planned:
            return "clock.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .visited:
            return .green
        case .planned:
            return .orange
        }
    }
}

// MARK: - Example Data
extension TravelScene {
    @MainActor static let exampleData: [TravelScene] = [
        // Visited Scenes
        TravelScene(
            name: "Tokyo",
            country: "Japan",
            description: "Amazing city with blend of traditional and modern culture",
            latitude: 35.6762,
            longitude: 139.6503,
            status: .visited,
            visits: [
                Visit(
                    startDate: Date(timeIntervalSinceNow: -86400 * 35), // 35 days ago
                    endDate: Date(timeIntervalSinceNow: -86400 * 30),   // 30 days ago
                    notes: "Spring trip - visited Mount Fuji, enjoyed incredible sushi!"
                ),
                Visit(
                    startDate: Date(timeIntervalSinceNow: -86400 * 200), // 200 days ago
                    endDate: Date(timeIntervalSinceNow: -86400 * 197),   // 197 days ago
                    notes: "Quick business trip"
                )
            ],
            notes: "Love this city! Want to visit again.",
            associatedLandmarkIds: [1016] // Mount Fuji
        ),
        TravelScene(
            name: "Paris",
            country: "France",
            description: "The City of Light with iconic landmarks",
            latitude: 48.8566,
            longitude: 2.3522,
            status: .visited,
            visits: [
                Visit(
                    startDate: Date(timeIntervalSinceNow: -86400 * 67), // 67 days ago
                    endDate: Date(timeIntervalSinceNow: -86400 * 60),   // 60 days ago
                    notes: "Week-long vacation - Eiffel Tower at sunset was breathtaking"
                )
            ],
            notes: "Romantic city with amazing food and architecture",
            associatedLandmarkIds: [1015] // Eiffel Tower
        ),

        // Planned Scenes
        TravelScene(
            name: "Sydney",
            country: "Australia",
            description: "Beautiful harbor city with iconic opera house",
            latitude: -33.8688,
            longitude: 151.2093,
            status: .planned,
            plannedDate: Date(timeIntervalSinceNow: 86400 * 60), // 60 days from now
            notes: "Want to see Opera House and Bondi Beach",
            associatedLandmarkIds: [1005] // Sydney Opera House
        ),
        TravelScene(
            name: "Machu Picchu",
            country: "Peru",
            description: "Ancient Incan city in the Andes",
            latitude: -13.1631,
            longitude: -72.5450,
            status: .planned,
            plannedDate: Date(timeIntervalSinceNow: 86400 * 120), // 120 days from now
            notes: "Need to book hiking permits in advance",
            associatedLandmarkIds: [1014] // Machu Picchu
        )
    ]
}
