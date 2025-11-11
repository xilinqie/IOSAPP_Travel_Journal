/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A class that generates AI-powered travel recommendations for travel scenes.
*/

import Foundation
import FoundationModels
import Observation

@Observable
@MainActor
final class TravelSceneAIAssistant {
    private(set) var recommendation: SceneRecommendation.PartiallyGenerated?
    private var session: LanguageModelSession

    var error: Error?
    let scene: TravelScene
    let modelData: ModelData

    init(scene: TravelScene, modelData: ModelData) {
        self.scene = scene
        self.modelData = modelData

        self.session = LanguageModelSession(
            tools: [],
            instructions: Instructions {
                "You are an expert travel advisor specializing in helping travelers plan amazing trips."

                "Your job is to provide personalized travel recommendations for \(scene.name), \(scene.country)."

                "Always provide specific, actionable advice that will enhance the visitor's experience."

                """
                Here is detailed information about this destination:
                Location: \(scene.name), \(scene.country)
                Status: \(scene.status.rawValue)
                """

                if !scene.description.isEmpty {
                    "Description: \(scene.description)"
                }

                if !scene.notes.isEmpty {
                    "Traveler's notes: \(scene.notes)"
                }

                if scene.status == .visited, let latestVisit = scene.latestVisit {
                    "Previously visited on \(latestVisit.startDate.formatted(date: .long, time: .omitted))"
                    if !latestVisit.notes.isEmpty {
                        "Visit notes: \(latestVisit.notes)"
                    }
                }

                if scene.status == .planned, let plannedDate = scene.plannedDate {
                    "Planned visit date: \(plannedDate.formatted(date: .long, time: .omitted))"
                }
            }
        )
    }

    func generateRecommendation() async throws {
        let stream = session.streamResponse(
            generating: SceneRecommendation.self,
            includeSchemaInPrompt: false,
            options: GenerationOptions(sampling: .greedy)
        ) {
            """
            Generate a comprehensive travel recommendation for \(scene.name), \(scene.country).
            """

            """
            Include the best time to visit, recommended activities, practical travel tips, \
            local cuisine suggestions, and cultural insights.
            """

            "Be specific and engaging. Focus on what makes this destination unique and special."

            "Consider the traveler's status: this is a \(scene.status.rawValue) destination."

            "Here is an example format, but adapt it for this specific destination:"
            SceneRecommendation.example
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

// MARK: - Scene Recommendation Model

@Generable
struct SceneRecommendation: Equatable {
    @Guide(description: "An engaging title for the recommendation.")
    let title: String

    @Guide(description: "A detailed description of why this destination is worth visiting.")
    let description: String

    @Guide(description: "The best time of year to visit (season or months).")
    let bestTimeToVisit: String

    @Guide(description: "Recommended activities or experiences at this destination.")
    @Guide(.count(3...6))
    let activities: [String]

    @Guide(description: "Local cuisine and food specialties to try.")
    @Guide(.count(2...4))
    let localCuisine: [String]

    @Guide(description: "Practical tips for travelers (what to bring, transportation, etc).")
    @Guide(.count(3...5))
    let travelTips: [String]

    @Guide(description: "Cultural insights, customs, and etiquette to be aware of.")
    @Guide(.count(2...4))
    let culturalInsights: [String]

    static let example = SceneRecommendation(
        title: "Discover the Magic of This Destination",
        description: "This destination offers unforgettable experiences, rich culture, and stunning landscapes.",
        bestTimeToVisit: "Spring (April-May) or Fall (September-October) for ideal weather and fewer crowds",
        activities: [
            "Explore the historic old town",
            "Visit local markets and shops",
            "Take a guided food tour",
            "Enjoy scenic viewpoints"
        ],
        localCuisine: [
            "Traditional regional dishes",
            "Street food specialties",
            "Local desserts and beverages"
        ],
        travelTips: [
            "Learn a few local phrases",
            "Use public transportation to experience local life",
            "Book popular attractions in advance"
        ],
        culturalInsights: [
            "Local customs and traditions",
            "Festival seasons and celebrations",
            "Cultural etiquette to observe"
        ]
    )
}
