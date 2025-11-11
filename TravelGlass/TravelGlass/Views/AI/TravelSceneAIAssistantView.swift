/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
The main AI assistant view for travel scenes.
*/

import SwiftUI
import FoundationModels

struct TravelSceneAIAssistantView: View {
    @Environment(ModelData.self) private var modelData
    @Environment(\.dismiss) private var dismiss

    let scene: TravelScene

    @State private var assistant: TravelSceneAIAssistant?
    @State private var isGenerating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showContent = false

    var body: some View {
        NavigationStack {
            Group {
                if let assistant = assistant {
                    if isGenerating {
                        // Show generating view
                        TravelSceneAIGeneratingView(scene: scene, assistant: assistant)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                    } else if let recommendation = assistant.recommendation, recommendation.title != nil {
                        // Show completed recommendation
                        TravelSceneRecommendationView(recommendation: recommendation, scene: scene)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .opacity
                            ))
                    } else {
                        // Initial state
                        startView
                            .transition(.opacity)
                    }
                } else {
                    // Not available
                    unavailableView
                        .transition(.opacity)
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isGenerating)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: assistant?.recommendation?.title)
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
            withAnimation(.easeInOut(duration: 0.4).delay(0.1)) {
                showContent = true
            }
        }
    }

    private var startView: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer()
                    .frame(height: 40)

                // Animated icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)

                    Image(systemName: "sparkles")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolEffect(.pulse, options: .repeating)
                        .shadow(color: .blue.opacity(0.3), radius: 20)
                }
                .scaleEffect(showContent ? 1 : 0.5)
                .opacity(showContent ? 1 : 0)

                VStack(spacing: 12) {
                    Text("AI Travel Recommendations")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    Text("for \(scene.name)")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                }

                Text("Get personalized travel advice, activity suggestions, local cuisine tips, and cultural insights powered by Apple Intelligence.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                Button(action: startGeneration) {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.headline)
                        Text("Generate Recommendations")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: .blue.opacity(0.4), radius: 12, y: 6)
                }
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)
                .padding(.top, 8)

                Spacer()
            }
            .padding()
        }
        .background(
            ZStack {
                Color.clear

                // Animated gradient background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.blue.opacity(0.1), .clear],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 400
                        )
                    )
                    .offset(x: -100, y: -100)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.purple.opacity(0.1), .clear],
                            center: .bottomTrailing,
                            startRadius: 0,
                            endRadius: 400
                        )
                    )
                    .offset(x: 100, y: 100)
            }
        )
    }

    private var unavailableView: some View {
        VStack(spacing: 32) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.bounce, options: .repeating.speed(0.5))

            VStack(spacing: 12) {
                Text("AI Not Available")
                    .font(.title2.bold())

                Text("Apple Intelligence is required to use this feature. Please ensure you have iOS 18.2+ or macOS 15.2+ and Apple Intelligence is enabled.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding()
    }

    private func setupAssistant() {
        if SystemLanguageModel.default.availability == .available {
            let newAssistant = TravelSceneAIAssistant(scene: scene, modelData: modelData)
            newAssistant.prewarm()
            assistant = newAssistant
        }
    }

    private func startGeneration() {
        guard let assistant = assistant else { return }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            isGenerating = true
        }

        Task {
            do {
                try await assistant.generateRecommendation()
                await MainActor.run {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isGenerating = false
                    }
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

// MARK: - Generating View

struct TravelSceneAIGeneratingView: View {
    let scene: TravelScene
    let assistant: TravelSceneAIAssistant

    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var showPreview = false

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 60)

                // Animated generating icon
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(rotationAngle))
                        .onAppear {
                            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                                rotationAngle = 360
                            }
                        }

                    // Middle ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.purple, .blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-rotationAngle * 1.5))

                    // Center icon
                    Image(systemName: "sparkles")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(pulseScale)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                pulseScale = 1.2
                            }
                        }
                }
                .shadow(color: .blue.opacity(0.3), radius: 20)

                VStack(spacing: 16) {
                    Text("Generating Recommendations...")
                        .font(.title2.bold())

                    Text("for \(scene.name)")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    // Animated dots
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(.blue)
                                .frame(width: 8, height: 8)
                                .scaleEffect(pulseScale)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.2),
                                    value: pulseScale
                                )
                        }
                    }
                    .padding(.top, 4)
                }

                // Preview card with animation
                if let recommendation = assistant.recommendation {
                    VStack(alignment: .leading, spacing: 16) {
                        if let title = recommendation.title {
                            HStack(spacing: 12) {
                                Image(systemName: "sparkle")
                                    .foregroundStyle(.blue)
                                    .font(.title3)

                                Text(title)
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                            }
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        }

                        if let description = recommendation.description {
                            Text(description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .transition(.move(edge: .leading).combined(with: .opacity))
                        }

                        // Progress indicators
                        VStack(alignment: .leading, spacing: 8) {
                            ProgressRow(
                                icon: "calendar.badge.clock",
                                label: "Best Time",
                                isComplete: recommendation.bestTimeToVisit != nil
                            )
                            ProgressRow(
                                icon: "figure.walk",
                                label: "Activities",
                                isComplete: recommendation.activities != nil
                            )
                            ProgressRow(
                                icon: "fork.knife",
                                label: "Cuisine",
                                isComplete: recommendation.localCuisine != nil
                            )
                            ProgressRow(
                                icon: "lightbulb.fill",
                                label: "Tips",
                                isComplete: recommendation.travelTips != nil
                            )
                            ProgressRow(
                                icon: "book.fill",
                                label: "Culture",
                                isComplete: recommendation.culturalInsights != nil
                            )
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                    .padding(.horizontal, 20)
                    .transition(.scale.combined(with: .opacity))
                    .onAppear {
                        showPreview = true
                    }
                }

                Spacer()
            }
        }
        .background(
            ZStack {
                Color.clear

                // Animated gradient background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.blue.opacity(0.15), .clear],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 400
                        )
                    )
                    .offset(x: -100, y: -100)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.purple.opacity(0.15), .clear],
                            center: .bottomTrailing,
                            startRadius: 0,
                            endRadius: 400
                        )
                    )
                    .offset(x: 100, y: 100)
            }
        )
    }
}

// Progress indicator row
struct ProgressRow: View {
    let icon: String
    let label: String
    let isComplete: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(isComplete ? .green : .secondary)
                .frame(width: 20)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                    .transition(.scale.combined(with: .opacity))
            } else {
                ProgressView()
                    .scaleEffect(0.7)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isComplete)
    }
}

// MARK: - Recommendation View

struct TravelSceneRecommendationView: View {
    let recommendation: SceneRecommendation.PartiallyGenerated
    let scene: TravelScene

    @State private var showCards = false
    @Namespace private var animation

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header card
                if let title = recommendation.title {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.title2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(title)
                                    .font(.title2.bold())
                                    .foregroundStyle(.primary)

                                Text(scene.name)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }

                        if let description = recommendation.description {
                            Text(description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .lineSpacing(4)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .scaleEffect(showCards ? 1 : 0.9)
                    .opacity(showCards ? 1 : 0)
                }

                // Best Time to Visit
                if let bestTime = recommendation.bestTimeToVisit {
                    RecommendationCard(
                        title: "Best Time to Visit",
                        icon: "calendar.badge.clock",
                        color: .blue
                    ) {
                        Text(bestTime)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .lineSpacing(4)
                    }
                    .scaleEffect(showCards ? 1 : 0.9)
                    .opacity(showCards ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: showCards)
                }

                // Activities
                if let activities = recommendation.activities, !activities.isEmpty {
                    RecommendationCard(
                        title: "Recommended Activities",
                        icon: "figure.walk",
                        color: .green
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(activities.enumerated()), id: \.offset) { index, activity in
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(.green.opacity(0.15))
                                            .frame(width: 28, height: 28)

                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.green)
                                    }

                                    Text(activity)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .lineSpacing(4)
                                }
                            }
                        }
                    }
                    .scaleEffect(showCards ? 1 : 0.9)
                    .opacity(showCards ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: showCards)
                }

                // Local Cuisine
                if let cuisine = recommendation.localCuisine, !cuisine.isEmpty {
                    RecommendationCard(
                        title: "Local Cuisine",
                        icon: "fork.knife",
                        color: .orange
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(cuisine.enumerated()), id: \.offset) { index, dish in
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(.orange.opacity(0.15))
                                            .frame(width: 28, height: 28)

                                        Image(systemName: "star.fill")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(.orange)
                                    }

                                    Text(dish)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .lineSpacing(4)
                                }
                            }
                        }
                    }
                    .scaleEffect(showCards ? 1 : 0.9)
                    .opacity(showCards ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: showCards)
                }

                // Travel Tips
                if let tips = recommendation.travelTips, !tips.isEmpty {
                    RecommendationCard(
                        title: "Travel Tips",
                        icon: "lightbulb.fill",
                        color: .yellow
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(tips.enumerated()), id: \.offset) { index, tip in
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(.yellow.opacity(0.15))
                                            .frame(width: 28, height: 28)

                                        Image(systemName: "lightbulb")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(.yellow)
                                    }

                                    Text(tip)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .lineSpacing(4)
                                }
                            }
                        }
                    }
                    .scaleEffect(showCards ? 1 : 0.9)
                    .opacity(showCards ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: showCards)
                }

                // Cultural Insights
                if let insights = recommendation.culturalInsights, !insights.isEmpty {
                    RecommendationCard(
                        title: "Cultural Insights",
                        icon: "book.fill",
                        color: .purple
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(insights.enumerated()), id: \.offset) { index, insight in
                                HStack(alignment: .top, spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(.purple.opacity(0.15))
                                            .frame(width: 28, height: 28)

                                        Image(systemName: "sparkle")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(.purple)
                                    }

                                    Text(insight)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                        .lineSpacing(4)
                                }
                            }
                        }
                    }
                    .scaleEffect(showCards ? 1 : 0.9)
                    .opacity(showCards ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: showCards)
                }

                Spacer()
                    .frame(height: 20)
            }
        }
        .background(
            ZStack {
                Color.clear

                // Subtle gradient background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.blue.opacity(0.08), .clear],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 500
                        )
                    )
                    .offset(x: -150, y: -150)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.purple.opacity(0.08), .clear],
                            center: .bottomTrailing,
                            startRadius: 0,
                            endRadius: 500
                        )
                    )
                    .offset(x: 150, y: 150)
            }
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showCards = true
            }
        }
    }
}

// MARK: - Recommendation Card Component

struct RecommendationCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(color)
                }

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()
            }

            // Card content
            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
        .padding(.horizontal, 20)
    }
}

