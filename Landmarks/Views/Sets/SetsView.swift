/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
A view that displays all scene sets/categories.
*/

import SwiftUI

struct SetsView: View {
    @Environment(ModelData.self) private var modelData
    @State private var showingAddSet = false

    var body: some View {
        List {
            if modelData.sceneSets.isEmpty {
                ContentUnavailableView {
                    Label("No Sets Yet", systemImage: "folder.badge.plus")
                } description: {
                    Text("Create sets to organize your travel scenes into categories like \"Beach Destinations\", \"Historical Sites\", or \"Bucket List\".")
                } actions: {
                    Button("Create Your First Set") {
                        showingAddSet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                ForEach(modelData.sceneSets) { set in
                    NavigationLink(value: set) {
                        SetRowView(set: set)
                    }
                }
            }
        }
        .navigationTitle("Sets")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddSet = true }) {
                    Label("Add Set", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSet) {
            AddSetView()
        }
    }
}

struct SetRowView: View {
    @Environment(ModelData.self) private var modelData
    let set: SceneSet

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(set.color.gradient)
                    .frame(width: 56, height: 56)

                Image(systemName: set.iconName)
                    .font(.title2)
                    .foregroundStyle(.white)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(set.name)
                    .font(.headline)

                if !set.description.isEmpty {
                    Text(set.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                // Scene count
                let sceneCount = modelData.scenes(for: set).count
                Text("^[\(sceneCount) scene](inflect: true)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        SetsView()
            .environment(ModelData())
    }
}
