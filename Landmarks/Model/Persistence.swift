/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Core Data persistence controller for the Landmarks app.
*/

import CoreData
import SwiftUI

/// A singleton controller that manages the Core Data stack.
@MainActor
class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "LandmarksModel")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data store failed to load: \(error.localizedDescription)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    /// Preview instance with sample data for SwiftUI previews
    static var preview: PersistenceController {
        let controller = PersistenceController(inMemory: true)
        // Sample data can be added here if needed
        return controller
    }

    /// Saves the view context if there are changes
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save Core Data context: \(error.localizedDescription)")
            }
        }
    }
}
