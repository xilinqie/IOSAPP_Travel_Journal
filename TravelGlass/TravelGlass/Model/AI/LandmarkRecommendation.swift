/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A Generable structure that defines AI-generated landmark recommendations and travel suggestions.
*/

import Foundation
import FoundationModels

@Generable
struct LandmarkRecommendation: Equatable {
    @Guide(description: "An engaging title for the recommendation.")
    let title: String

    @Guide(description: "A detailed description of why this landmark is worth visiting.")
    let description: String

    @Guide(description: "The best time of year to visit this landmark (season or months).")
    let bestTimeToVisit: String

    @Guide(description: "Recommended activities or experiences at this landmark.")
    @Guide(.count(3...5))
    let activities: [String]

    @Guide(description: "Practical tips for visitors (what to bring, how to get there, etc).")
    @Guide(.count(2...4))
    let travelTips: [String]

    @Guide(description: "Nearby landmarks or places of interest to visit as well.")
    @Guide(.count(2...3))
    let nearbyAttractions: [String]
}

@Generable
struct LandmarkComparison: Equatable {
    @Guide(description: "A summary comparing the two landmarks.")
    let summary: String

    @Guide(description: "Key differences between the two landmarks.")
    @Guide(.count(3))
    let differences: [String]

    @Guide(description: "Similarities between the two landmarks.")
    @Guide(.count(2))
    let similarities: [String]

    @Guide(description: "Which landmark is better for specific types of travelers (families, adventurers, photographers, etc).")
    let recommendations: String
}
