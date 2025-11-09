/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A class that generates AI-powered travel recommendations for landmarks.
*/

import FoundationModels
import Observation

@Observable
@MainActor
final class LandmarkAIAssistant {
    private(set) var recommendation: LandmarkRecommendation.PartiallyGenerated?
    private(set) var searchTool: FindLandmarksTool
    private var session: LanguageModelSession

    var error: Error?
    let landmark: Landmark
    let modelData: ModelData

    init(landmark: Landmark, modelData: ModelData) {
        self.landmark = landmark
        self.modelData = modelData

        let searchTool = FindLandmarksTool(modelData: modelData)
        self.session = LanguageModelSession(
            tools: [searchTool],
            instructions: Instructions {
                "You are an expert travel advisor specializing in helping visitors plan trips to amazing landmarks around the world."

                "Your job is to provide personalized travel recommendations for \(String(localized: landmark.name))."

                """
                Use the findLandmarks tool to search for nearby attractions or similar landmarks \
                that visitors might also enjoy.
                """

                "Always provide specific, actionable advice that will enhance the visitor's experience."

                """
                Here is detailed information about \(String(localized: landmark.name)):
                Location: \(landmark.continent)
                Description: \(String(localized: landmark.description))
                """

                if landmark.location != nil {
                    "Region: \(landmark.formattedLocation)"
                }

                if landmark.elevation != nil {
                    "Elevation: \(landmark.formattedElevation)"
                }

                if landmark.totalArea != nil {
                    "Area: \(landmark.formattedTotalArea)"
                }
            }
        )
        self.searchTool = searchTool
    }

    func generateRecommendation() async throws {
        let stream = session.streamResponse(
            generating: LandmarkRecommendation.self,
            includeSchemaInPrompt: false,
            options: GenerationOptions(sampling: .greedy)
        ) {
            """
            Generate a comprehensive travel recommendation for \(String(localized: landmark.name)).
            """

            """
            Include the best time to visit, recommended activities, practical travel tips, \
            and nearby attractions that complement this destination.
            """

            "Be specific and engaging. Focus on what makes this landmark unique and special."

            "Here is an example format, but adapt it for this specific landmark:"
            LandmarkRecommendation.example
        }

        for try await partialResponse in stream {
            recommendation = partialResponse.content
        }
    }

    func prewarm() {
        session.prewarm()
    }

    func resetRecommendation() {
        recommendation = nil
    }

    var isAvailable: Bool {
        SystemLanguageModel.default.availability == .available
    }
}

extension LandmarkRecommendation {
    static let example = LandmarkRecommendation(
        title: "Experience the Majesty of This Natural Wonder",
        description: "This landmark offers breathtaking views and unforgettable experiences for all types of travelers.",
        bestTimeToVisit: "Spring (April-May) or Fall (September-October) for ideal weather and fewer crowds",
        activities: [
            "Sunrise photography from the viewpoint",
            "Guided nature walks with local experts",
            "Cultural tours of nearby villages",
            "Adventure hiking on marked trails"
        ],
        travelTips: [
            "Arrive early to avoid crowds and catch the best light",
            "Wear comfortable hiking shoes and bring layers",
            "Book accommodations in advance during peak season"
        ],
        nearbyAttractions: [
            "Historic temple complex 15 km away",
            "Traditional craft village",
            "Scenic mountain viewpoint"
        ]
    )
}
