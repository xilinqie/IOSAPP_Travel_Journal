/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A class the app uses to store and manage model data.
*/

import Foundation
import SwiftUI
import MapKit
import CoreLocation

/// A class the app uses to store and manage model data.
@Observable @MainActor
class ModelData {
    var landmarks: [Landmark] = []
    var landmarksByContinent: [Continent: [Landmark]] = [:]
    var featuredLandmark: Landmark?
    var selectedLandmark: Landmark? = nil
    var isLandmarkInspectorPresented: Bool = false

    var favoritesCollection: LandmarkCollection!
    var userCollections: [LandmarkCollection] = []

    var landmarksById: [Int: Landmark] = [:]
    var mapItemsByLandmarkId: [Int: MKMapItem] = [:]
    var mapItemsForLandmarks: [MKMapItem] {
        guard let mapItems = mapItemsByLandmarkId.values.map(\.self) as? [MKMapItem] else {
            return []
        }
        return mapItems
    }

    var locationFinder: LocationFinder?

    // Travel Scenes
    var travelScenes: [TravelScene] = []
    var visitedScenes: [TravelScene] {
        travelScenes.filter { $0.status == .visited }.sorted {
            ($0.latestVisit?.startDate ?? Date.distantPast) > ($1.latestVisit?.startDate ?? Date.distantPast)
        }
    }
    var plannedScenes: [TravelScene] {
        travelScenes.filter { $0.status == .planned }.sorted {
            ($0.plannedDate ?? Date.distantFuture) < ($1.plannedDate ?? Date.distantFuture)
        }
    }

    // Scene Sets
    var sceneSets: [SceneSet] = []

    var searchString: String = ""
    var path: NavigationPath = NavigationPath() {
        didSet {
            // Check if the person navigates away from a view that's showing the inspector.
            if path.count < oldValue.count && isLandmarkInspectorPresented == true {
                // Dismiss the inspector.
                isLandmarkInspectorPresented = false
            }
        }
    }
    
    var earnedBadges: [Badge] {
        let badges = landmarks.compactMap { landmark in
            if landmark.badge != nil,
                let progress = landmark.badgeProgress,
                progress.earned == true {
                return landmark.badge
            }
            return nil
        }
        return badges
    }

    var windowSize: CGSize = .zero

    init() {
        loadLandmarks()
        loadCollections()
        loadTravelScenes()
        loadSceneSets()

        Task {
            do {
                let fetched = try await fetchMapItems(for: landmarks)

                await MainActor.run {
                    self.mapItemsByLandmarkId = fetched
                }
            } catch {
                print("Couldn't fetch map items: \(error.localizedDescription)")
            }
        }
    }

    func loadLandmarks() {
        landmarks = Landmark.exampleData
        landmarksByContinent = landmarksByContinent(from: landmarks)

        for landmark in landmarks {
            landmarksById[landmark.id] = landmark
        }

        if let fujiLandmark = landmarksById[1016] {
            featuredLandmark = fujiLandmark
        }
    }

    func loadTravelScenes() {
        travelScenes = TravelScene.exampleData
    }
    
    func isFavorite(_ landmark: Landmark) -> Bool {
        var isFavorite: Bool = false
        
        if favoritesCollection.landmarks.firstIndex(of: landmark) != nil {
            isFavorite = true
        }
        
        return isFavorite
    }

    func toggleFavorite(_ landmark: Landmark) {
        if isFavorite(landmark) {
            removeFavorite(landmark)
        } else {
            addFavorite(landmark)
        }
    }

    func addFavorite(_ landmark: Landmark) {
        favoritesCollection.landmarks.append(landmark)
    }

    func removeFavorite(_ landmark: Landmark) {
        if let landmarkIndex = favoritesCollection.landmarks.firstIndex(of: landmark) {
            favoritesCollection.landmarks.remove(at: landmarkIndex)
        }
    }

    func loadCollections() {
        let collectionList: [LandmarkCollection] = LandmarkCollection.exampleData

        for collection in collectionList {
            let landmarks = landmarks(for: collection.landmarkIds)
            collection.landmarks = landmarks
        }
        
        guard let favorites = collectionList.first(where: { $0.id == 1001 }) else {
            fatalError("Favorites collection missing from example data.")
        }
        favoritesCollection = favorites

        userCollections = collectionList.filter { collection in
            return collection.id != 1001
        }
    }
    
    func addUserCollection() -> LandmarkCollection {
        var nextUserCollectionId: Int = 1002
        if let lastUserCollectionId = userCollections.sorted(by: { lhs, rhs in lhs.id > rhs.id }).first?.id {
            nextUserCollectionId = lastUserCollectionId + 1
        }
        
        let newCollection = LandmarkCollection(id: nextUserCollectionId,
                                               name: String(localized: "New Collection"),
                                               description: String(localized: "Add a description for your collection here…"),
                                               landmarkIds: [],
                                               landmarks: [])
        userCollections.append(newCollection)
        return newCollection
    }

    func remove(_ collection: LandmarkCollection) {
        if let indexInUserCollections = userCollections.firstIndex(of: collection) {
            userCollections.remove(at: indexInUserCollections)
        }
    }
    
    func collection(_ collection: LandmarkCollection, contains landmark: Landmark) -> Bool {
        var collectionContainsLandmark: Bool = false
        
        if collection.landmarks.firstIndex(of: landmark) != nil {
            collectionContainsLandmark = true
        }
        
        return collectionContainsLandmark
    }

    func collectionsContaining(_ landmark: Landmark) -> [LandmarkCollection] {
        return userCollections.filter { collection in
            self.collection(collection, contains: landmark)
        }
    }

    func add(_ landmark: Landmark, to collection: LandmarkCollection) {
        if collection.landmarks.firstIndex(of: landmark) != nil {
            return
        }

        collection.landmarks.append(landmark)
    }
    
    func remove(_ landmark: Landmark, from collection: LandmarkCollection) {
        guard let index = collection.landmarks.firstIndex(of: landmark) else {
            return
        }

        collection.landmarks.remove(at: index)
    }

    // MARK: - Travel Scene Management

    func addTravelScene(_ scene: TravelScene) {
        travelScenes.append(scene)
    }

    func removeTravelScene(_ scene: TravelScene) {
        travelScenes.removeAll { $0.id == scene.id }
    }

    func updateSceneStatus(_ scene: TravelScene, to status: SceneStatus) {
        scene.status = status
        if status == .visited {
            // Add a new visit record with today's date
            let visit = Visit(startDate: Date(), endDate: Date(), notes: "")
            scene.visits.append(visit)
            scene.plannedDate = nil
        } else {
            scene.plannedDate = Date()
            scene.visits.removeAll()
        }
    }

    // MARK: - Scene Set Management

    func loadSceneSets() {
        sceneSets = SceneSet.exampleData

        // Populate sets with scene IDs based on example data structure
        if let tokyoScene = travelScenes.first(where: { $0.name == "Tokyo" }),
           let parisScene = travelScenes.first(where: { $0.name == "Paris" }),
           let sydneyScene = travelScenes.first(where: { $0.name == "Sydney" }),
           let machuPicchuScene = travelScenes.first(where: { $0.name == "Machu Picchu" }) {

            // Asia Adventures
            if let asiaSet = sceneSets.first(where: { $0.name == "Asia Adventures" }) {
                asiaSet.sceneIds.insert(tokyoScene.id)
            }

            // European Classics
            if let europeSet = sceneSets.first(where: { $0.name == "European Classics" }) {
                europeSet.sceneIds.insert(parisScene.id)
            }

            // Bucket List
            if let bucketListSet = sceneSets.first(where: { $0.name == "Bucket List" }) {
                bucketListSet.sceneIds.insert(sydneyScene.id)
                bucketListSet.sceneIds.insert(machuPicchuScene.id)
            }

            // Beach & Coastal
            if let beachSet = sceneSets.first(where: { $0.name == "Beach & Coastal" }) {
                beachSet.sceneIds.insert(sydneyScene.id)
            }

            // Historical Sites
            if let historicalSet = sceneSets.first(where: { $0.name == "Historical Sites" }) {
                historicalSet.sceneIds.insert(parisScene.id)
                historicalSet.sceneIds.insert(machuPicchuScene.id)
            }
        }
    }

    func addSceneSet(_ set: SceneSet) {
        sceneSets.append(set)
    }

    func removeSceneSet(_ set: SceneSet) {
        sceneSets.removeAll { $0.id == set.id }
    }

    func scenes(for set: SceneSet) -> [TravelScene] {
        travelScenes.filter { set.sceneIds.contains($0.id) }
    }

    func sets(for scene: TravelScene) -> [SceneSet] {
        sceneSets.filter { $0.sceneIds.contains(scene.id) }
    }

    func addScene(_ scene: TravelScene, to set: SceneSet) {
        set.sceneIds.insert(scene.id)
    }

    func removeScene(_ scene: TravelScene, from set: SceneSet) {
        set.sceneIds.remove(scene.id)
    }

    func toggleScene(_ scene: TravelScene, in set: SceneSet) {
        if set.sceneIds.contains(scene.id) {
            set.sceneIds.remove(scene.id)
        } else {
            set.sceneIds.insert(scene.id)
        }
    }

    func landmarks(in continent: Continent) -> [Landmark] {
        let landmarks = landmarksByContinent[continent] ?? []
        return landmarks.sorted { String(localized: $0.name) < String(localized: $1.name) }
    }
    
    private func landmarksByContinent(from landmarks: [Landmark]) -> [Continent: [Landmark]] {
        var landmarksByContinent: [Continent: [Landmark]] = [:]
        
        for landmark in landmarks {
            guard let continent = Continent(rawValue: landmark.continent) else { continue }

            if landmarksByContinent[continent] == nil {
                landmarksByContinent[continent] = [landmark]
            } else {
                landmarksByContinent[continent]?.append(landmark)
            }
        }

        return landmarksByContinent
    }
    
    private func landmarks(for landmarkIds: [Int]) -> [Landmark] {
        var landmarks: [Landmark] = []
        for landmarkId in landmarkIds {
            if let landmark = landmarksById[landmarkId] {
                landmarks.append(landmark)
            }
        }
        return landmarks
    }
    
    nonisolated private func fetchMapItems(for landmarks: [Landmark]) async throws -> [Int: MKMapItem] {
        var fetchedMapItemsByLandmarkId: [Int: MKMapItem] = [:]
        
        for landmark in landmarks {
            guard let placeID = landmark.placeID else { continue }
            
            guard let identifier = MKMapItem.Identifier(rawValue: placeID) else { continue }
            let request = MKMapItemRequest(mapItemIdentifier: identifier)
            if let mapItem = try? await request.mapItem {
                fetchedMapItemsByLandmarkId[landmark.id] = mapItem
            }
        }
        
        return fetchedMapItemsByLandmarkId
    }
}

extension ModelData {
    enum Continent: String, CaseIterable {
        case africa = "Africa"
        case antarctica = "Antarctica"
        case asia = "Asia"
        case australiaOceania = "Australia/Oceania"
        case europe = "Europe"
        case northAmerica = "North America"
        case southAmerica = "South America"
        
        var name: String {
            switch self {
            case .africa: String(localized: "Africa", comment: "The name of a continent.")
            case .antarctica: String(localized: "Antarctica", comment: "The name of a continent.")
            case .asia: String(localized: "Asia", comment: "The name of a continent.")
            case .australiaOceania: String(localized: "Australia/Oceania", comment: "The name of a continent.")
            case .europe: String(localized: "Europe", comment: "The name of a continent.")
            case .northAmerica: String(localized: "North America", comment: "The name of a continent.")
            case .southAmerica: String(localized: "South America", comment: "The name of a continent.")
            }
        }
    }
    
    static let orderedContinents: [Continent] = [.asia, .africa, .antarctica, .australiaOceania, .europe, .northAmerica, .southAmerica]
}
