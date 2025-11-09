/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A SwiftUI view that displays the AI-generated travel recommendation.
*/

import SwiftUI
import FoundationModels

struct LandmarkRecommendationView: View {
    let recommendation: LandmarkRecommendation.PartiallyGenerated

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Title Section
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.largeTitle)
                        .foregroundStyle(.blue)

                    if let title = recommendation.title {
                        Text(title)
                            .font(.title)
                            .fontWeight(.bold)
                            .contentTransition(.opacity)
                    }
                }

                // Description
                if let description = recommendation.description {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "About This Destination", icon: "info.circle")

                        Text(description)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .contentTransition(.opacity)
                    }
                }

                // Best Time to Visit
                if let bestTime = recommendation.bestTimeToVisit {
                    VStack(alignment: .leading, spacing: 8) {
                        SectionHeader(title: "Best Time to Visit", icon: "calendar")

                        Text(bestTime)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .contentTransition(.opacity)
                    }
                }

                // Activities
                if let activities = recommendation.activities, !activities.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Recommended Activities", icon: "figure.hiking")

                        ForEach(activities, id: \.self) { activity in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.title3)

                                Text(activity)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                            .contentTransition(.opacity)
                        }
                    }
                }

                // Travel Tips
                if let tips = recommendation.travelTips, !tips.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Travel Tips", icon: "lightbulb")

                        ForEach(tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "star.circle.fill")
                                    .foregroundStyle(.orange)
                                    .font(.title3)

                                Text(tip)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                            .contentTransition(.opacity)
                        }
                    }
                }

                // Nearby Attractions
                if let attractions = recommendation.nearbyAttractions, !attractions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Nearby Attractions", icon: "map")

                        ForEach(attractions, id: \.self) { attraction in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.red)
                                    .font(.title3)

                                Text(attraction)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                            .contentTransition(.opacity)
                        }
                    }
                }
            }
            .padding()
        }
        .animation(.easeOut, value: recommendation)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.headline)
        .foregroundStyle(.secondary)
    }
}

// Preview removed due to @Generable macro complexity
// Test in live app instead
