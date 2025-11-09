/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A view for managing photos in a travel scene.
*/

import SwiftUI
import PhotosUI

struct ScenePhotosView: View {
    @Environment(\.dismiss) private var dismiss
    let scene: TravelScene

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isAddingPhotos = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Photos")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("\(scene.photos.count) photo(s)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Add Photos Button
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 10,
                        matching: .images
                    ) {
                        Label("Add Photos", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .onChange(of: selectedItems) { oldValue, newValue in
                        Task {
                            await loadPhotos(from: newValue)
                        }
                    }
                }
                .padding()

                // Photos Grid
                if scene.photos.isEmpty {
                    ContentUnavailableView {
                        Label("No Photos Yet", systemImage: "photo.on.rectangle.angled")
                    } description: {
                        Text("Add photos from your photo library to remember this place")
                    }
                    .frame(height: 300)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 16)
                    ], spacing: 16) {
                        ForEach(scene.photos) { photo in
                            PhotoGridItem(photo: photo, scene: scene)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle(scene.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func loadPhotos(from items: [PhotosPickerItem]) async {
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                let photo = ScenePhoto(
                    imageData: data,
                    caption: "",
                    createdAt: Date()
                )
                await MainActor.run {
                    scene.photos.append(photo)
                }
            }
        }
        await MainActor.run {
            selectedItems = []
        }
    }
}

struct PhotoGridItem: View {
    let photo: ScenePhoto
    let scene: TravelScene

    @State private var showingDetail = false
    @State private var showingCaptionEditor = false

    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(alignment: .leading, spacing: 8) {
                if let image = photo.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(.gray)
                        }
                }

                if !photo.caption.isEmpty {
                    Text(photo.caption)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                showingCaptionEditor = true
            } label: {
                Label("Edit Caption", systemImage: "pencil")
            }

            Button(role: .destructive) {
                deletePhoto()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingDetail) {
            PhotoDetailView(photo: photo, scene: scene)
        }
        .sheet(isPresented: $showingCaptionEditor) {
            PhotoCaptionEditor(photo: photo, scene: scene)
        }
    }

    private func deletePhoto() {
        withAnimation {
            scene.photos.removeAll { $0.id == photo.id }
        }
    }
}

struct PhotoDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let photo: ScenePhoto
    let scene: TravelScene

    var body: some View {
        NavigationStack {
            VStack {
                if let image = photo.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Text("Image not available")
                        .foregroundStyle(.secondary)
                }

                if !photo.caption.isEmpty {
                    Text(photo.caption)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding()
                }

                Spacer()
            }
            .navigationTitle(scene.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct PhotoCaptionEditor: View {
    @Environment(\.dismiss) private var dismiss
    let photo: ScenePhoto
    let scene: TravelScene

    @State private var caption: String

    init(photo: ScenePhoto, scene: TravelScene) {
        self.photo = photo
        self.scene = scene
        self._caption = State(initialValue: photo.caption)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Caption") {
                    TextField("Add a caption for this photo", text: $caption, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Caption")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCaption()
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveCaption() {
        if let index = scene.photos.firstIndex(where: { $0.id == photo.id }) {
            scene.photos[index].caption = caption
        }
    }
}

#Preview {
    @Previewable @State var modelData = ModelData()

    if let scene = modelData.travelScenes.first {
        NavigationStack {
            ScenePhotosView(scene: scene)
        }
    }
}
