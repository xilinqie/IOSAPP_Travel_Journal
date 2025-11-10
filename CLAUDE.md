# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Travel Journal** iOS/macOS app built with SwiftUI, based on Apple's Landmarks sample project but extensively modified for personal travel tracking and planning. The app allows users to:
- Track visited destinations with multiple visit records and photos
- Plan future trips with dates and notes
- Organize travel scenes into custom sets
- View all destinations on an interactive map with photo annotations
- Link famous landmarks to personal travel records

**Key Transformation**: The original Landmarks app was a static landmark viewer organized by continent. This version is a personal travel journal with user-created content, hierarchical location selection, photo management, and visit tracking.

## Building and Running

### Development Requirements
- **Xcode**: 15.0 or later
- **Swift**: 6.0
- **Deployment Targets**: iOS 26.0+ / macOS 26.0+ (as configured, though iOS 17.0+ / macOS 14.0+ mentioned in README)
- **Scheme**: `Landmarks`

### Build Commands
```bash
# Open the project
open Landmarks.xcodeproj

# Build from command line
xcodebuild -project Landmarks.xcodeproj -scheme Landmarks build

# Build and run
xcodebuild -project Landmarks.xcodeproj -scheme Landmarks -destination 'platform=iOS Simulator,name=iPhone 15' build

# Clean build folder
xcodebuild -project Landmarks.xcodeproj -scheme Landmarks clean
```

### Running
- Press `⌘+R` in Xcode to build and run
- Select iOS Simulator or macOS target as needed
- The app requires Photos framework permissions for adding travel photos

## Architecture

### Core Design Pattern: MVVM with Observable State

The app uses **MVVM** with SwiftUI's modern `@Observable` macro (iOS 17+) for reactive state management:

- **ModelData** (`Landmarks/Model/ModelData.swift`): Central observable state manager that holds all app data and serves as the single source of truth. Injected via SwiftUI environment.
- **Models**: `@Observable` classes (TravelScene, Landmark, etc.) for reactive updates
- **Views**: SwiftUI views that observe ModelData and model changes
- **Navigation**: NavigationSplitView with sidebar for main navigation

### Key Architectural Components

1. **ModelData** - The Hub
   - Manages landmarks, travel scenes, scene sets, and collections
   - Provides computed properties for filtered data (visitedScenes, plannedScenes)
   - Handles CRUD operations for all entities
   - Manages MapKit integration and map item fetching
   - Initialized in `LandmarksApp.swift` and passed via `.environment(modelData)`

2. **Hierarchical Location System**
   - `LocationDatabase` singleton with 15 countries, 70+ cities
   - Structure: Country → Region (Province/State) → City
   - Each city has precise coordinates (CLLocationCoordinate2D)
   - Bilingual support: English names + localName (Chinese)

3. **Travel Scene System**
   - `TravelScene`: User-created destination records
   - `Visit`: Date-range based visit records (startDate, endDate, notes)
   - `ScenePhoto`: Photos with captions from Photos app
   - Status-based organization: `.visited` or `.planned`
   - Multiple visits per scene supported

4. **Photo Management**
   - Uses `PhotosPicker` from PhotosUI framework
   - Photos stored as `Data` (imageData) in ScenePhoto
   - Displayed on map as stacked annotations
   - Up to 10 photos can be selected at once

5. **Core Data Integration**
   - `PersistenceController` manages Core Data stack
   - Model: `LandmarksModel.xcdatamodeld` (if exists)
   - Entities: SceneSetEntity, TravelSceneEntity, ScenePhotoEntity
   - Used for persistent storage of user data

6. **AI-Powered Recommendations** (Apple Intelligence)
   - Uses `FoundationModels` framework (new in iOS 18+)
   - `LandmarkAIAssistant`: Generates travel recommendations using SystemLanguageModel
   - `FindLandmarksTool`: Tool for finding nearby landmarks
   - `LandmarkRecommendation`: Structured output format
   - Check `isAvailable` before using AI features

### Directory Structure

```
Landmarks/
├── Model/
│   ├── ModelData.swift              # Central state manager
│   ├── TravelScene.swift            # Travel destination model with Visit records
│   ├── LocationDatabase.swift       # Hierarchical location data (15 countries)
│   ├── SceneSet.swift               # Scene grouping/collections
│   ├── Persistence.swift            # Core Data controller
│   ├── LandmarkData.swift           # Landmark model
│   ├── AI/                          # AI assistance features
│   │   ├── LandmarkAIAssistant.swift
│   │   ├── FindLandmarksTool.swift
│   │   └── LandmarkRecommendation.swift
│   └── CoreData/                    # Core Data entity classes
├── Views/
│   ├── Scenes/                      # Travel scene views (main feature)
│   │   ├── AddSceneView.swift       # Location picker: Country → Region → City
│   │   ├── SceneDetailView.swift   # Scene details with photo gallery
│   │   ├── SceneFeaturedCarouselView.swift
│   │   ├── ScenePhotosView.swift   # Photo gallery view
│   │   └── AddVisitView.swift      # Add new visit record
│   ├── Map/
│   │   ├── MapView.swift            # MapKit integration
│   │   └── PhotoStackAnnotationView.swift  # Photo stack markers
│   ├── Sets/                        # Scene set management
│   ├── Landmarks/                   # Original landmark features (preserved)
│   ├── Collections/                 # Landmark collections
│   ├── Badges/                      # Badge/achievement system
│   └── Landmarks Split View/        # Main navigation structure
├── Resources/
│   ├── Assets.xcassets
│   └── *.xcstrings                  # Localization files (bilingual)
├── LandmarksApp.swift               # App entry point
└── Landmarks.entitlements
```

## Important Development Notes

### State Management
- **Never** create new ModelData instances; always use the one from environment
- ModelData is `@MainActor` isolated - all UI updates must be on main thread
- TravelScene is `@Observable` - direct property mutations trigger UI updates
- Use `modelData.addTravelScene()`, `modelData.updateSceneStatus()` etc. for modifications

### Location Selection Flow
1. User selects Country from `LocationDatabase.shared.countries`
2. User selects Region from `country.regions`
3. User selects City from `region.cities`
4. City provides `coordinate: CLLocationCoordinate2D?`
5. Create TravelScene with city's name, country, and coordinates

### Photo Handling
- Photos selected via `PhotosPicker` return `PhotosPickerItem`
- Convert to `Data` using `item.loadTransferable(type: Data.self)`
- Store as `ScenePhoto(imageData: data, caption: "", createdAt: Date())`
- Display using `Image(uiImage: UIImage(data: imageData))` on iOS
- Cross-platform: Check `#if os(iOS)` vs `#if os(macOS)`

### MapKit Integration
- Map shows both landmarks (from original app) and travel scenes
- Travel scenes use custom `PhotoStackAnnotationView` showing photo count
- Green markers = visited, Orange = planned
- MapItems fetched asynchronously in ModelData init

### AI Features (Optional)
- Check `LandmarkAIAssistant.isAvailable` before using
- Requires FoundationModels framework (iOS 18+)
- Prewarm with `assistant.prewarm()` for better performance
- Stream responses with `session.streamResponse(generating:)`

### Bilingual Support
- Use `String(localized:)` for all user-facing strings
- LocationDatabase has both `name` and `localName` properties
- Localization files: `*.xcstrings` in Resources/
- Primary languages: English and Chinese

### Core Data Persistence
- Access via `PersistenceController.shared.container.viewContext`
- Entity names: SceneSetEntity, TravelSceneEntity, ScenePhotoEntity
- Always save after modifications: `PersistenceController.shared.save()`
- Merge policy: `.mergeByPropertyObjectTrump`

## Common Patterns

### Adding a New Travel Scene
```swift
let scene = TravelScene(
    name: city.name,
    country: country.name,
    latitude: city.latitude ?? 0,
    longitude: city.longitude ?? 0,
    status: .visited,
    visits: [Visit(startDate: startDate, endDate: endDate, notes: notes)]
)
modelData.addTravelScene(scene)
```

### Adding Photos to Scene
```swift
// In view with PhotosPicker
@State private var selectedItems: [PhotosPickerItem] = []

// Convert and add
for item in selectedItems {
    if let data = try? await item.loadTransferable(type: Data.self) {
        let photo = ScenePhoto(imageData: data, caption: "", createdAt: Date())
        scene.photos.append(photo)
    }
}
```

### Organizing Scenes into Sets
```swift
let sceneSet = SceneSet(name: "European Classics", description: "...", sceneIds: [])
modelData.addSceneSet(sceneSet)
modelData.addScene(parisScene, to: sceneSet)
```

## Testing Notes

- No formal test suite found in codebase
- Manual testing recommended: Add scenes, upload photos, create sets
- Test location picker with different countries/cities
- Test photo limit (10 photos per selection)
- Verify map annotations display correctly
- Test visit tracking with multiple visits

## Original Apple Sample Code

This project is based on Apple's Landmarks tutorial. Key original features preserved:
- Landmark data with continents, elevation, coordinates
- Badge system (partially integrated)
- Collection management for landmarks
- MapKit integration patterns

Modified/replaced features:
- Main navigation (now focuses on Travel Scenes)
- Data entry (user-created vs. pre-loaded)
- Photo system (user photos vs. static assets)
- Organization (status-based vs. continent-based)

## Future Development Areas (from README)

- Search within cities
- Recent/favorite locations cache
- Manual location input for unlisted cities
- PDF export of trip data
- iCloud sync
- Weather integration
- Budget tracking
- Travel statistics dashboard
