# Travel Journal / 旅行日记

[English](#english) | [中文](#chinese)

---

<a name="english"></a>
## English

### Overview

**Travel Journal** is a personal travel tracking and planning application for iOS and macOS, reimagined from Apple's open-source [Landmarks sample project](https://developer.apple.com/tutorials/swiftui/creating-and-combining-views). While the original Landmarks app focused on displaying and exploring famous landmarks, this version transforms it into a comprehensive travel journal and trip planning tool.

### ✨ Key Features

#### 🗺️ Travel Scene Management
- **Visited Places**: Record locations you've been to with detailed visit history
- **Planned Destinations**: Keep track of places you want to visit
- **Multiple Visit Records**: Track multiple visits to the same location with date ranges
- **Visit Statistics**: Automatically calculate total days visited and visit counts

#### 📍 Smart Location Selection
- **Hierarchical Selection**: Choose locations through Country → Province/State → City structure
- **15 Countries Supported**: Including China, USA, Japan, UK, France, Australia, and more
- **70+ Cities**: Pre-loaded with accurate coordinates for major cities worldwide
- **Bilingual Support**: Chinese and English localized names

#### 📸 Photo Management
- **Photo Albums**: Add photos from your Photos app to each travel scene
- **Photo Stack Display**: Map annotations show stacked photos with count badges
- **Captions**: Add descriptions to your travel photos
- **Gallery View**: View all photos in a dedicated gallery interface

#### 🗂️ Organization
- **Scene Sets**: Group related destinations (e.g., "European Classics", "Beach & Coastal")
- **Landmark Association**: Link famous landmarks to your travel scenes
- **Flexible Categorization**: Organize trips by themes, regions, or preferences

#### 🗺️ Interactive Map
- **Visual Overview**: See all your visited and planned destinations on an interactive map
- **Photo Previews**: Map markers display photo thumbnails with stacking effect
- **Color-Coded**: Green markers for visited places, orange for planned trips
- **MapKit Integration**: Full-featured maps powered by Apple MapKit

### 🎯 What's Changed from Original Landmarks?

This project extensively modifies Apple's Landmarks sample to focus on personal travel:

| Feature | Original Landmarks | Travel Journal |
|---------|-------------------|----------------|
| **Purpose** | Display famous landmarks | Personal travel tracking |
| **Main View** | Landmark catalog by continent | Travel scenes with carousel |
| **Data Entry** | Pre-loaded landmarks only | User-created travel records |
| **Photos** | Static landmark images | User photos from Photos app |
| **Map Markers** | Landmark pins | Photo stacks with visit info |
| **Organization** | By continent | By visit status + custom sets |
| **Visit Tracking** | None | Multiple visits per location |
| **Location Input** | N/A | Hierarchical country/city picker |

### 📱 Screenshots

*(Add screenshots here when available)*

### 🛠️ Technical Stack

- **Language**: Swift 6.0
- **UI Framework**: SwiftUI with `@Observable` macro (iOS 17+)
- **Map**: MapKit with custom annotations
- **Photos**: PhotosPicker from PhotosUI framework
- **Storage**: Core Data for persistence
- **Minimum Version**: iOS 17.0+ / macOS 14.0+

### 🏗️ Architecture

- **MVVM Pattern**: ModelData as central observable state manager
- **Hierarchical Navigation**: NavigationSplitView with sidebar and detail
- **Reusable Components**: Modular view components for scenes, photos, and maps
- **Location Database**: Structured geographical data with 15 countries
- **Visit Records System**: Date range tracking with automatic duration calculation

### 📂 Project Structure

```
Landmarks/
├── Model/
│   ├── TravelScene.swift          # Travel destination model
│   ├── Visit.swift                # Visit record with date ranges
│   ├── LocationDatabase.swift     # Hierarchical location data
│   ├── ModelData.swift            # Central state management
│   └── SceneSet.swift             # Scene grouping
├── Views/
│   ├── Scenes/                    # Travel scene views
│   │   ├── AddSceneView.swift     # Add new destinations
│   │   ├── SceneDetailView.swift  # Scene details with photos
│   │   ├── SceneFeaturedCarouselView.swift
│   │   ├── ScenePhotosView.swift  # Photo gallery
│   │   └── AddVisitView.swift     # Add visit records
│   ├── Map/
│   │   ├── MapView.swift          # Interactive map
│   │   └── PhotoStackAnnotationView.swift
│   ├── Sets/                      # Scene set management
│   └── Landmarks/                 # Original landmark features
└── Resources/
    ├── Assets.xcassets
    └── Localization files
```

### 🚀 Getting Started

#### Prerequisites
- Xcode 15.0 or later
- macOS 14.0+ (for development)
- iOS 17.0+ device or simulator

#### Installation

1. Clone the repository:
```bash
git clone [repository-url]
cd Landmarks
```

2. Open the project:
```bash
open Landmarks/Landmarks.xcodeproj
```

3. Select your target device/simulator and run:
```bash
# Command line
xcodebuild -project Landmarks.xcodeproj -scheme Landmarks build

# Or press ⌘+R in Xcode
```

### 📖 Usage Guide

#### Adding a Visited Place
1. Tap the "+" button in "Places I've Visited"
2. Select Country → Province/State → City
3. Choose visit dates (start and end)
4. Add optional description and notes
5. Link related landmarks if desired
6. Tap "Save"

#### Adding Photos
1. Open a travel scene detail view
2. Tap "Add Photos" button
3. Select photos from your Photos app (up to 10 at once)
4. Photos appear in the scene gallery
5. View all photos by tapping "View All"

#### Adding Multiple Visits
1. Open a visited scene
2. Tap "Add Visit" button in the visit history section
3. Enter new visit dates and notes
4. Save to add to visit history

#### Creating Scene Sets
1. Navigate to "Sets" tab
2. Tap "+" to create a new set
3. Name your set and add description
4. Add scenes by tapping "Add Scenes"

### 🔮 Future Enhancements

- [ ] Search functionality within cities
- [ ] Recent and favorite locations
- [ ] Manual location input for unlisted cities
- [ ] Export trip data as PDF
- [ ] iCloud sync across devices
- [ ] Weather information integration
- [ ] Budget tracking per trip
- [ ] Travel statistics and insights

### 🙏 Acknowledgments

This project is based on Apple's **Landmarks** sample project from the [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui). The original project demonstrates SwiftUI concepts including:
- Building Lists and Navigation
- Handling User Input
- Drawing Paths and Shapes
- Animating Views and Transitions

We've extensively modified and expanded the original project to create a personal travel journal application while preserving the excellent SwiftUI architecture and patterns demonstrated by Apple.

**Original Landmarks Project**: Copyright © Apple Inc. Licensed under [Apple Sample Code License](https://developer.apple.com/library/archive/documentation/LegalNotices/Acknowledgements/OriginalAppleCode.html)

### 📄 License

This modified version maintains compatibility with the original Apple Sample Code License. See the `LICENSE.txt` file for details.

### 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

### 📧 Contact

For questions or feedback, please open an issue on GitHub.

---

<a name="chinese"></a>
## 中文

### 项目概述

**旅行日记**是一款基于苹果开源的 [Landmarks 示例项目](https://developer.apple.com/tutorials/swiftui/creating-and-combining-views)重新设计的个人旅行追踪和规划应用，适用于 iOS 和 macOS。原始的 Landmarks 应用专注于展示和探索著名地标，而这个版本将其改造成了一个全面的旅行日记和行程规划工具。

### ✨ 核心功能

#### 🗺️ 旅行场景管理
- **去过的地方**：记录您访问过的地点，包含详细的访问历史
- **计划的目的地**：追踪您想要去的地方
- **多次访问记录**：支持同一地点的多次访问，记录日期范围
- **访问统计**：自动计算总访问天数和访问次数

#### 📍 智能地点选择
- **层级选择**：通过"国家 → 省/州 → 城市"的结构选择地点
- **支持15个国家**：包括中国、美国、日本、英国、法国、澳大利亚等
- **70+个城市**：预装全球主要城市的精确坐标
- **双语支持**：中文和英文本地化名称

#### 📸 照片管理
- **相册功能**：从照片应用添加照片到每个旅行场景
- **照片堆叠显示**：地图标注显示堆叠的照片和数量徽章
- **图片说明**：为旅行照片添加描述
- **图库视图**：在专用图库界面查看所有照片

#### 🗂️ 组织管理
- **场景集**：将相关目的地分组（如"欧洲经典"、"海滨度假"）
- **地标关联**：将著名地标链接到您的旅行场景
- **灵活分类**：按主题、地区或个人偏好组织行程

#### 🗺️ 互动地图
- **可视化概览**：在互动地图上查看所有已访问和计划的目的地
- **照片预览**：地图标记显示照片缩略图和堆叠效果
- **颜色编码**：已访问地点显示绿色标记，计划行程显示橙色
- **MapKit集成**：由 Apple MapKit 驱动的全功能地图

### 🎯 与原始 Landmarks 项目的区别

本项目对苹果的 Landmarks 示例进行了大量修改，专注于个人旅行追踪：

| 功能 | 原始 Landmarks | 旅行日记 |
|------|---------------|---------|
| **用途** | 展示著名地标 | 个人旅行追踪 |
| **主视图** | 按大洲分类的地标目录 | 带轮播的旅行场景 |
| **数据录入** | 仅预加载地标 | 用户创建的旅行记录 |
| **照片** | 静态地标图片 | 来自相册的用户照片 |
| **地图标记** | 地标图钉 | 带访问信息的照片堆叠 |
| **组织方式** | 按大洲 | 按访问状态 + 自定义集合 |
| **访问追踪** | 无 | 每个地点支持多次访问 |
| **地点输入** | 不适用 | 分层级的国家/城市选择器 |

### 📱 应用截图

*（可用时添加截图）*

### 🛠️ 技术栈

- **语言**：Swift 6.0
- **UI框架**：SwiftUI 与 `@Observable` 宏（iOS 17+）
- **地图**：带自定义标注的 MapKit
- **照片**：PhotosUI 框架的 PhotosPicker
- **存储**：Core Data 持久化
- **最低版本**：iOS 17.0+ / macOS 14.0+

### 🏗️ 架构设计

- **MVVM模式**：ModelData 作为中央可观察状态管理器
- **层级导航**：使用侧边栏和详情视图的 NavigationSplitView
- **可复用组件**：用于场景、照片和地图的模块化视图组件
- **地点数据库**：包含15个国家的结构化地理数据
- **访问记录系统**：日期范围追踪，自动计算持续时间

### 📂 项目结构

```
Landmarks/
├── Model/
│   ├── TravelScene.swift          # 旅行目的地模型
│   ├── Visit.swift                # 带日期范围的访问记录
│   ├── LocationDatabase.swift     # 层级地点数据
│   ├── ModelData.swift            # 中央状态管理
│   └── SceneSet.swift             # 场景分组
├── Views/
│   ├── Scenes/                    # 旅行场景视图
│   │   ├── AddSceneView.swift     # 添加新目的地
│   │   ├── SceneDetailView.swift  # 场景详情及照片
│   │   ├── SceneFeaturedCarouselView.swift  # 特色轮播
│   │   ├── ScenePhotosView.swift  # 照片图库
│   │   └── AddVisitView.swift     # 添加访问记录
│   ├── Map/
│   │   ├── MapView.swift          # 互动地图
│   │   └── PhotoStackAnnotationView.swift  # 照片堆叠标注
│   ├── Sets/                      # 场景集管理
│   └── Landmarks/                 # 原始地标功能
└── Resources/
    ├── Assets.xcassets            # 资源文件
    └── 本地化文件
```

### 🚀 快速开始

#### 环境要求
- Xcode 15.0 或更高版本
- macOS 14.0+（用于开发）
- iOS 17.0+ 设备或模拟器

#### 安装步骤

1. 克隆仓库：
```bash
git clone [仓库地址]
cd Landmarks
```

2. 打开项目：
```bash
open Landmarks/Landmarks.xcodeproj
```

3. 选择目标设备/模拟器并运行：
```bash
# 命令行构建
xcodebuild -project Landmarks.xcodeproj -scheme Landmarks build

# 或在 Xcode 中按 ⌘+R
```

### 📖 使用指南

#### 添加已访问的地点
1. 在"去过的地方"中点击"+"按钮
2. 依次选择国家 → 省/州 → 城市
3. 选择访问日期（开始和结束）
4. 添加可选的描述和笔记
5. 如需要，关联相关地标
6. 点击"保存"

#### 添加照片
1. 打开旅行场景详情视图
2. 点击"添加照片"按钮
3. 从相册中选择照片（一次最多10张）
4. 照片显示在场景图库中
5. 点击"查看全部"查看所有照片

#### 添加多次访问
1. 打开已访问的场景
2. 在访问历史部分点击"添加访问"按钮
3. 输入新的访问日期和笔记
4. 保存以添加到访问历史

#### 创建场景集
1. 导航到"场景集"标签
2. 点击"+"创建新集合
3. 为集合命名并添加描述
4. 通过点击"添加场景"来添加场景

### 🔮 未来增强功能

- [ ] 城市内搜索功能
- [ ] 最近访问和收藏地点
- [ ] 手动输入未列出的城市
- [ ] 导出行程数据为 PDF
- [ ] iCloud 跨设备同步
- [ ] 天气信息集成
- [ ] 每次旅行的预算追踪
- [ ] 旅行统计和洞察

### 🙏 致谢

本项目基于苹果的 **Landmarks** 示例项目，来自 [SwiftUI 教程](https://developer.apple.com/tutorials/swiftui)。原始项目演示了 SwiftUI 的核心概念，包括：
- 构建列表和导航
- 处理用户输入
- 绘制路径和形状
- 动画视图和过渡效果

我们对原始项目进行了大量修改和扩展，创建了这个个人旅行日记应用，同时保留了苹果展示的优秀 SwiftUI 架构和设计模式。

**原始 Landmarks 项目**：版权所有 © Apple Inc. 根据 [Apple 示例代码许可证](https://developer.apple.com/library/archive/documentation/LegalNotices/Acknowledgements/OriginalAppleCode.html)授权

### 📄 许可证

此修改版本与原始 Apple 示例代码许可证保持兼容。详情请参阅 `LICENSE.txt` 文件。

### 🤝 贡献

欢迎贡献！请随时提交 issue 和 pull request。

### 📧 联系方式

如有问题或反馈，请在 GitHub 上提交 issue。

---

**Note / 注意**: This project is for educational and personal use. / 本项目仅供教育和个人使用。
