/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A photo stack annotation for displaying scene photos on the map.
*/

import SwiftUI

/// A view that displays a stack of photos with a count badge for map annotations.
struct PhotoStackAnnotationView: View {
    let scene: TravelScene

    private var photoCount: Int {
        scene.photos.count
    }

    private var topPhoto: ScenePhoto? {
        scene.photos.first
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Photo stack layers
            ZStack {
                // Bottom layer (third photo indication)
                if photoCount >= 3 {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white)
                        .frame(width: 56, height: 56)
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                        .offset(x: 6, y: 6)
                }

                // Middle layer (second photo indication)
                if photoCount >= 2 {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white)
                        .frame(width: 56, height: 56)
                        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                        .offset(x: 3, y: 3)
                }

                // Top layer (actual photo or placeholder)
                Group {
                    if let topPhoto = topPhoto, let image = topPhoto.image {
                        // Show actual photo
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        // Placeholder with scene icon
                        RoundedRectangle(cornerRadius: 8)
                            .fill(scene.status.color.gradient)
                            .frame(width: 56, height: 56)
                            .overlay {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                    }
                }
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white, lineWidth: 2)
                )
            }
            .frame(width: 62, height: 62, alignment: .topLeading)

            // Count badge (only show if there are 2+ photos)
            if photoCount >= 2 {
                ZStack {
                    Circle()
                        .fill(.red)
                        .frame(width: 24, height: 24)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

                    Text("\(photoCount)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
                .offset(x: 8, y: -8)
            }
        }
    }
}

/// A compact circular annotation for scenes without photos.
struct SceneCircularAnnotationView: View {
    let scene: TravelScene

    var body: some View {
        ZStack {
            Circle()
                .fill(scene.status.color)
                .frame(width: 36, height: 36)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)

            Image(systemName: scene.status.symbolName)
                .font(.system(size: 18))
                .foregroundStyle(.white)
        }
    }
}

#Preview("With Photos") {
    VStack(spacing: 20) {
        Text("Preview with photos")
            .font(.caption)
    }
    .padding()
}

#Preview("Without Photos") {
    VStack(spacing: 20) {
        Text("Preview without photos")
            .font(.caption)
    }
    .padding()
}
