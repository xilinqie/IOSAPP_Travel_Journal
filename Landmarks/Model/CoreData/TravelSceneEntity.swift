/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Core Data entity for TravelScene with photo and note support.
*/

import Foundation
import CoreData
import SwiftUI

@objc(TravelSceneEntity)
public class TravelSceneEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var country: String
    @NSManaged public var sceneDescription: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var status: String // "visited" or "planned"
    @NSManaged public var visitDate: Date?
    @NSManaged public var plannedDate: Date?
    @NSManaged public var notes: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // Relationships
    @NSManaged public var photos: NSSet?
    @NSManaged public var sets: NSSet?

    /// Convert to TravelScene model
    func toTravelScene() -> TravelScene {
        // Convert old visitDate to Visit if it exists
        var visits: [Visit] = []
        if let visitDate = visitDate {
            visits = [Visit(startDate: visitDate, endDate: visitDate, notes: "")]
        }

        return TravelScene(
            id: id,
            name: name,
            country: country,
            description: sceneDescription,
            latitude: latitude,
            longitude: longitude,
            status: SceneStatus(rawValue: status) ?? .planned,
            visits: visits,
            plannedDate: plannedDate,
            notes: notes
        )
    }

    /// Create or update from TravelScene model
    @discardableResult
    static func createOrUpdate(from scene: TravelScene, in context: NSManagedObjectContext) -> TravelSceneEntity {
        let request: NSFetchRequest<TravelSceneEntity> = TravelSceneEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", scene.id as CVarArg)

        let entity: TravelSceneEntity
        if let existing = try? context.fetch(request).first {
            entity = existing
        } else {
            entity = TravelSceneEntity(context: context)
            entity.id = scene.id
            entity.createdAt = Date()
        }

        entity.name = scene.name
        entity.country = scene.country
        entity.sceneDescription = scene.description
        entity.latitude = scene.latitude
        entity.longitude = scene.longitude
        entity.status = scene.status.rawValue
        // Store latest visit date for backward compatibility
        entity.visitDate = scene.latestVisit?.startDate
        entity.plannedDate = scene.plannedDate
        entity.notes = scene.notes
        entity.updatedAt = Date()

        return entity
    }
}

// MARK: - Fetch Request
extension TravelSceneEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TravelSceneEntity> {
        return NSFetchRequest<TravelSceneEntity>(entityName: "TravelSceneEntity")
    }

    static func fetchAll(in context: NSManagedObjectContext) -> [TravelSceneEntity] {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TravelSceneEntity.updatedAt, ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
}

// MARK: - Photo Management
extension TravelSceneEntity {
    var photosArray: [ScenePhotoEntity] {
        let set = photos as? Set<ScenePhotoEntity> ?? []
        return set.sorted { $0.createdAt < $1.createdAt }
    }

    func addPhoto(_ photo: ScenePhotoEntity) {
        let items = self.photos?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
        items.add(photo)
        self.photos = items.copy() as? NSSet
    }

    func removePhoto(_ photo: ScenePhotoEntity) {
        let items = self.photos?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
        items.remove(photo)
        self.photos = items.copy() as? NSSet
    }
}

// MARK: - Set Management
extension TravelSceneEntity {
    var setsArray: [SceneSetEntity] {
        let set = sets as? Set<SceneSetEntity> ?? []
        return set.sorted { $0.name < $1.name }
    }
}
