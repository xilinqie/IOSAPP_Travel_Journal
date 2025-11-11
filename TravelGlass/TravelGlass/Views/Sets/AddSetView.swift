/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A view for adding a new scene set.
*/

import SwiftUI

struct AddSetView: View {
    @Environment(ModelData.self) private var modelData
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var selectedColor: Color = .blue
    @State private var selectedIcon = "folder.fill"

    private let availableColors: [Color] = [
        .blue, .red, .green, .orange, .purple, .pink,
        .yellow, .cyan, .indigo, .mint, .teal, .brown
    ]

    private let availableIcons = [
        "folder.fill", "star.fill", "heart.fill", "flag.fill",
        "map.fill", "globe", "airplane", "mountain.2.fill",
        "beach.umbrella.fill", "building.2.fill", "building.columns.fill",
        "camera.fill", "photo.fill", "book.fill", "bookmark.fill"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Set Name", text: $name)
                        #if os(iOS)
                        .textInputAutocapitalization(.words)
                        #endif

                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button(action: { selectedIcon = icon }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedIcon == icon ? selectedColor : Color.gray.opacity(0.2))
                                        .frame(width: 60, height: 60)

                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundStyle(selectedIcon == icon ? .white : .secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Color") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 16) {
                        ForEach(availableColors, id: \.description) { color in
                            Button(action: { selectedColor = color }) {
                                ZStack {
                                    Circle()
                                        .fill(color.gradient)
                                        .frame(width: 50, height: 50)

                                    if selectedColor.description == color.description {
                                        Image(systemName: "checkmark")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Preview") {
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedColor.gradient)
                                .frame(width: 56, height: 56)

                            Image(systemName: selectedIcon)
                                .font(.title2)
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(name.isEmpty ? "Set Name" : name)
                                .font(.headline)

                            if !description.isEmpty {
                                Text(description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New Set")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSet()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func saveSet() {
        let newSet = SceneSet(
            name: name,
            description: description,
            color: selectedColor,
            iconName: selectedIcon,
            sceneIds: []
        )

        modelData.addSceneSet(newSet)
        dismiss()
    }
}

#Preview {
    AddSetView()
        .environment(ModelData())
}
