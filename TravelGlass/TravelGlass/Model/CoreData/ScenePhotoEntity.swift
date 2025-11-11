/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Core Data entity for scene photos.
*/

import Foundation
import CoreData
import SwiftUI

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

@objc(ScenePhotoEntity)
public class ScenePhotoEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var imageData: Data
    @NSManaged public var caption: String
    @NSManaged public var createdAt: Date
    @NSManaged public var orderIndex: Int16

    // Relationship
    @NSManaged public var scene: TravelSceneEntity?

    #if os(iOS)
    var image: UIImage? {
        UIImage(data: imageData)
    }
    #elseif os(macOS)
    var image: NSImage? {
        NSImage(data: imageData)
    }
    #endif

    /// Create a new photo entity
    static func create(from imageData: Data, caption: String = "", in context: NSManagedObjectContext) -> ScenePhotoEntity {
        let photo = ScenePhotoEntity(context: context)
        photo.id = UUID()
        photo.imageData = imageData
        photo.caption = caption
        photo.createdAt = Date()
        photo.orderIndex = 0
        return photo
    }
}

// MARK: - Fetch Request
extension ScenePhotoEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScenePhotoEntity> {
        return NSFetchRequest<ScenePhotoEntity>(entityName: "ScenePhotoEntity")
    }
}
