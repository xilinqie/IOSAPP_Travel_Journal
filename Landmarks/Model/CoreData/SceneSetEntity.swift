/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Core Data entity for SceneSet.
*/

import Foundation
import CoreData
import SwiftUI

@objc(SceneSetEntity)
public class SceneSetEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var setDescription: String
    @NSManaged public var colorHex: String
    @NSManaged public var iconName: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date

    // Relationship
    @NSManaged public var scenes: NSSet?

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    /// Convert to SceneSet model
    func toSceneSet() -> SceneSet {
        let sceneIds = scenesArray.map { $0.id }
        return SceneSet(
            id: id,
            name: name,
            description: setDescription,
            color: color,
            iconName: iconName,
            sceneIds: Set(sceneIds)
        )
    }

    /// Create or update from SceneSet model
    @discardableResult
    static func createOrUpdate(from set: SceneSet, in context: NSManagedObjectContext) -> SceneSetEntity {
        let request: NSFetchRequest<SceneSetEntity> = SceneSetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", set.id as CVarArg)

        let entity: SceneSetEntity
        if let existing = try? context.fetch(request).first {
            entity = existing
        } else {
            entity = SceneSetEntity(context: context)
            entity.id = set.id
            entity.createdAt = Date()
        }

        entity.name = set.name
        entity.setDescription = set.description
        entity.colorHex = set.color.toHex() ?? "#007AFF"
        entity.iconName = set.iconName
        entity.updatedAt = Date()

        return entity
    }

    var scenesArray: [TravelSceneEntity] {
        let set = scenes as? Set<TravelSceneEntity> ?? []
        return Array(set)
    }
}

// MARK: - Fetch Request
extension SceneSetEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SceneSetEntity> {
        return NSFetchRequest<SceneSetEntity>(entityName: "SceneSetEntity")
    }

    static func fetchAll(in context: NSManagedObjectContext) -> [SceneSetEntity] {
        let request = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SceneSetEntity.name, ascending: true)]
        return (try? context.fetch(request)) ?? []
    }
}

// MARK: - Color Extension for Hex Conversion
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String? {
        #if os(iOS)
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "#%02lX%02lX%02lX",
                      lroundf(r * 255),
                      lroundf(g * 255),
                      lroundf(b * 255))
        #else
        return nil
        #endif
    }
}
