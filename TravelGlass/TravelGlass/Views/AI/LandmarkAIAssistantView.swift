/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
The main AI assistant view that coordinates the recommendation generation and display.
*/

import SwiftUI
import FoundationModels

struct LandmarkAIAssistantView: View {
    @Environment(ModelData.self) private var modelData
    @Environment(\.dismiss) private var dismiss

    let landmark: Landmark

    @State private var assistant: LandmarkAIAssistant?
    @State private var isGenerating = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Group {
                if let assistant = assistant {
                    if isGenerating {
                        // Show generating view
                        LandmarkAIGeneratingView(landmark: landmark, assistant: assistant)
                    } else if let recommendation = assistant.recommendation, recommendation.title != nil {
                        // Show completed recommendation (check if at least title is available)
                        LandmarkRecommendationView(recommendation: recommendation)
                    } else {
                        // Initial state
                        startView
                    }
                } else {
                    // Not available
                    unavailableView
                }
            }
            .navigationTitle("AI Travel Assistant")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }

                if let assistant = assistant, assistant.recommendation?.title != nil, !isGenerating {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Regenerate", systemImage: "arrow.clockwise") {
                            regenerate()
                        }
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .onAppear {
            setupAssistant()
        }
    }

    private var startView: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundStyle(.blue)
                .symbolEffect(.breathe)

            VStack(spacing: 8) {
                Text("AI Travel Recommendations")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("for \(String(localized: landmark.name))")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Text("Get personalized travel advice, activity suggestions, and insider tips powered by AI.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: startGeneration) {
                Label("Generate Recommendations", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: 300)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 16)
        }
        .padding()
    }

    private var unavailableView: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 64))
                .foregroundStyle(.orange)

            Text("AI Not Available")
                .font(.title2)
                .fontWeight(.bold)

            Text("Apple Intelligence is required to use this feature. Please ensure you have iOS 18.2+ or macOS 15.2+ and Apple Intelligence is enabled.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
    }

    private func setupAssistant() {
        if SystemLanguageModel.default.availability == .available {
            let newAssistant = LandmarkAIAssistant(landmark: landmark, modelData: modelData)
            newAssistant.prewarm()
            assistant = newAssistant
        }
    }

    private func startGeneration() {
        guard let assistant = assistant else { return }

        isGenerating = true

        Task {
            do {
                try await assistant.generateRecommendation()
                await MainActor.run {
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    isGenerating = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func regenerate() {
        assistant?.resetRecommendation()
        startGeneration()
    }
}
