/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A tool that allows the AI to search and query landmark data.
*/

import FoundationModels
import SwiftUI

@Observable
final class FindLandmarksTool: Tool {
    let name = "findLandmarks"
    let description = "Searches for landmarks based on various criteria such as continent, name, or features."

    let modelData: ModelData

    @MainActor var searchHistory: [Search] = []

    init(modelData: ModelData) {
        self.modelData = modelData
    }

    @Generable
    enum SearchType: String, CaseIterable {
        case byContinent
        case byName
        case nearby
        case all
    }

    @Generable
    struct Arguments {
        @Guide(description: "The type of search to perform.")
        let searchType: SearchType

        @Guide(description: "The search query or criteria (continent name, landmark name, or location).")
        let query: String
    }

    struct Search: Identifiable {
        let id = UUID()
        let arguments: Arguments
    }

    @MainActor func recordSearch(arguments: Arguments) {
        searchHistory.append(Search(arguments: arguments))
    }

    func call(arguments: Arguments) async throws -> String {
        await recordSearch(arguments: arguments)

        let results = await MainActor.run {
            findLandmarks(arguments: arguments)
        }

        return formatResults(results, for: arguments)
    }

    @MainActor
    private func findLandmarks(arguments: Arguments) -> [Landmark] {
        let query = arguments.query.lowercased()

        switch arguments.searchType {
        case .byContinent:
            // Search by continent
            let continent = ModelData.Continent.allCases.first { continent in
                continent.name.lowercased().contains(query) ||
                continent.rawValue.lowercased().contains(query)
            }

            if let continent = continent {
                return modelData.landmarks(in: continent)
            }
            return []

        case .byName:
            // Search by landmark name
            return modelData.landmarks.filter { landmark in
                String(localized: landmark.name).lowercased().contains(query)
            }

        case .nearby:
            // Find landmarks in the same continent as the query
            if let targetLandmark = modelData.landmarks.first(where: {
                String(localized: $0.name).lowercased().contains(query)
            }) {
                return modelData.landmarks.filter { landmark in
                    landmark.continent == targetLandmark.continent && landmark.id != targetLandmark.id
                }
            }
            return []

        case .all:
            // Return all landmarks
            return Array(modelData.landmarks.prefix(10)) // Limit to 10 for brevity
        }
    }

    private func formatResults(_ landmarks: [Landmark], for arguments: Arguments) -> String {
        if landmarks.isEmpty {
            return "No landmarks found matching '\(arguments.query)'."
        }

        let landmarkNames = landmarks.prefix(5).map { landmark in
            String(localized: landmark.name)
        }

        let resultText = landmarkNames.joined(separator: ", ")
        let moreText = landmarks.count > 5 ? " and \(landmarks.count - 5) more" : ""

        return "Found \(landmarks.count) landmark(s): \(resultText)\(moreText). "
    }
}
