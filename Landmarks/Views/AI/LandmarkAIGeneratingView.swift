/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A SwiftUI view that shows a placeholder animation while generating AI recommendations.
*/

import SwiftUI

struct LandmarkAIGeneratingView: View {
    let landmark: Landmark
    let assistant: LandmarkAIAssistant
    @State private var show = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.largeTitle)
                    .symbolEffect(.breathe, isActive: true)

                Text("Generating Travel Recommendations...")
                    .font(.title2)
                    .fontWeight(.bold)
                    .opacity(show ? 1 : 0)

                Text("for \(String(localized: landmark.name))")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 40)

            // Search history
            if !assistant.searchTool.searchHistory.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(assistant.searchTool.searchHistory) { search in
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(searchTypeDescription(search.arguments.searchType))
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                Text("Searching: \(search.arguments.query)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .transition(.blurReplace)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .animation(.default, value: assistant.searchTool.searchHistory.count)
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                show = true
            }
        }
    }

    private func searchTypeDescription(_ type: FindLandmarksTool.SearchType) -> String {
        switch type {
        case .byContinent:
            return "Searching by continent"
        case .byName:
            return "Searching by name"
        case .nearby:
            return "Finding nearby attractions"
        case .all:
            return "Browsing all landmarks"
        }
    }
}
