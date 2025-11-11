/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
View modifiers that stretch a view in a scroll view when a person scrolls beyond the top bounds.
*/

import SwiftUI

@Observable private class FlexibleHeaderGeometry {
    var offset: CGFloat = 0
}

/// A view modifer that stretches content when the containing geometry offset changes.
private struct FlexibleHeaderContentModifier: ViewModifier {
    @Environment(ModelData.self) private var modelData
    @Environment(FlexibleHeaderGeometry.self) private var geometry

    func body(content: Content) -> some View {
        // Calculate base height as half of window height, with minimum fallback
        let baseHeight = modelData.windowSize.height > 0
            ? modelData.windowSize.height / 2
            : 400 // Fallback height if windowSize not set

        // Adjust height based on scroll offset (offset is negative when scrolling up)
        let calculatedHeight = baseHeight - geometry.offset

        // Ensure height stays within reasonable bounds
        let minHeight: CGFloat = 300
        let maxHeight: CGFloat = baseHeight * 1.5
        let height = max(minHeight, min(maxHeight, calculatedHeight))

        content
            .frame(height: height)
            .padding(.bottom, geometry.offset)
            .offset(y: geometry.offset)
    }
}

/// A view modifier that tracks scroll view geometry to stretch a view with ``FlexibleHeaderContentModifier``.
private struct FlexibleHeaderScrollViewModifier: ViewModifier {
    @State private var geometry = FlexibleHeaderGeometry()

    func body(content: Content) -> some View {
        content
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                min(geometry.contentOffset.y + geometry.contentInsets.top, 0)
            } action: { _, offset in
                geometry.offset = offset
            }
            .environment(geometry)
    }
}

// MARK: - View Extensions

extension ScrollView {
    /// A function that returns a view after it applies `FlexibleHeaderScrollViewModifier` to it.
    @MainActor func flexibleHeaderScrollView() -> some View {
        modifier(FlexibleHeaderScrollViewModifier())
    }
}

extension View {
    /// A function that returns a view after it applies `FlexibleHeaderContentModifier` to it.
    func flexibleHeaderContent() -> some View {
        modifier(FlexibleHeaderContentModifier())
    }
}
