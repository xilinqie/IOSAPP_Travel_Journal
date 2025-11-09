/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Geographic location data structure for hierarchical location selection.
*/

import Foundation
import CoreLocation

/// A geographic location with hierarchical structure
struct GeoLocation: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let localName: String? // 本地语言名称
    let coordinate: CLLocationCoordinate2D?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: GeoLocation, rhs: GeoLocation) -> Bool {
        lhs.id == rhs.id
    }
}

/// Country with provinces/states and cities
struct Country: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let localName: String?
    let code: String // ISO country code
    let regions: [Region]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Country, rhs: Country) -> Bool {
        lhs.id == rhs.id
    }
}

/// Region (Province/State/District)
struct Region: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let localName: String?
    let cities: [City]

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Region, rhs: Region) -> Bool {
        lhs.id == rhs.id
    }
}

/// City
struct City: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let localName: String?
    let latitude: Double?
    let longitude: Double?

    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lon = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: City, rhs: City) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Location Database
class LocationDatabase {
    @MainActor static let shared = LocationDatabase()

    let countries: [Country]

    private init() {
        self.countries = Self.loadCountries()
    }

    private static func loadCountries() -> [Country] {
        return [
            // 中国
            Country(
                name: "China",
                localName: "中国",
                code: "CN",
                regions: [
                    Region(name: "Beijing", localName: "北京市", cities: [
                        City(name: "Beijing", localName: "北京", latitude: 39.9042, longitude: 116.4074)
                    ]),
                    Region(name: "Shanghai", localName: "上海市", cities: [
                        City(name: "Shanghai", localName: "上海", latitude: 31.2304, longitude: 121.4737)
                    ]),
                    Region(name: "Guangdong", localName: "广东省", cities: [
                        City(name: "Guangzhou", localName: "广州", latitude: 23.1291, longitude: 113.2644),
                        City(name: "Shenzhen", localName: "深圳", latitude: 22.5431, longitude: 114.0579),
                        City(name: "Zhuhai", localName: "珠海", latitude: 22.2769, longitude: 113.5678)
                    ]),
                    Region(name: "Zhejiang", localName: "浙江省", cities: [
                        City(name: "Hangzhou", localName: "杭州", latitude: 30.2741, longitude: 120.1551),
                        City(name: "Ningbo", localName: "宁波", latitude: 29.8683, longitude: 121.5440)
                    ]),
                    Region(name: "Jiangsu", localName: "江苏省", cities: [
                        City(name: "Nanjing", localName: "南京", latitude: 32.0603, longitude: 118.7969),
                        City(name: "Suzhou", localName: "苏州", latitude: 31.2989, longitude: 120.5853)
                    ]),
                    Region(name: "Sichuan", localName: "四川省", cities: [
                        City(name: "Chengdu", localName: "成都", latitude: 30.5728, longitude: 104.0668)
                    ]),
                    Region(name: "Chongqing", localName: "重庆市", cities: [
                        City(name: "Chongqing", localName: "重庆", latitude: 29.4316, longitude: 106.9123)
                    ]),
                    Region(name: "Hubei", localName: "湖北省", cities: [
                        City(name: "Wuhan", localName: "武汉", latitude: 30.5928, longitude: 114.3055)
                    ]),
                    Region(name: "Shaanxi", localName: "陕西省", cities: [
                        City(name: "Xi'an", localName: "西安", latitude: 34.3416, longitude: 108.9398)
                    ]),
                    Region(name: "Tianjin", localName: "天津市", cities: [
                        City(name: "Tianjin", localName: "天津", latitude: 39.3434, longitude: 117.3616)
                    ])
                ]
            ),

            // 美国
            Country(
                name: "United States",
                localName: "美国",
                code: "US",
                regions: [
                    Region(name: "California", localName: "加利福尼亚州", cities: [
                        City(name: "Los Angeles", localName: "洛杉矶", latitude: 34.0522, longitude: -118.2437),
                        City(name: "San Francisco", localName: "旧金山", latitude: 37.7749, longitude: -122.4194),
                        City(name: "San Diego", localName: "圣地亚哥", latitude: 32.7157, longitude: -117.1611)
                    ]),
                    Region(name: "New York", localName: "纽约州", cities: [
                        City(name: "New York City", localName: "纽约", latitude: 40.7128, longitude: -74.0060)
                    ]),
                    Region(name: "Florida", localName: "佛罗里达州", cities: [
                        City(name: "Miami", localName: "迈阿密", latitude: 25.7617, longitude: -80.1918),
                        City(name: "Orlando", localName: "奥兰多", latitude: 28.5383, longitude: -81.3792)
                    ]),
                    Region(name: "Nevada", localName: "内华达州", cities: [
                        City(name: "Las Vegas", localName: "拉斯维加斯", latitude: 36.1699, longitude: -115.1398)
                    ]),
                    Region(name: "Washington", localName: "华盛顿州", cities: [
                        City(name: "Seattle", localName: "西雅图", latitude: 47.6062, longitude: -122.3321)
                    ]),
                    Region(name: "Illinois", localName: "伊利诺伊州", cities: [
                        City(name: "Chicago", localName: "芝加哥", latitude: 41.8781, longitude: -87.6298)
                    ])
                ]
            ),

            // 日本
            Country(
                name: "Japan",
                localName: "日本",
                code: "JP",
                regions: [
                    Region(name: "Tokyo", localName: "东京都", cities: [
                        City(name: "Tokyo", localName: "东京", latitude: 35.6762, longitude: 139.6503)
                    ]),
                    Region(name: "Osaka", localName: "大阪府", cities: [
                        City(name: "Osaka", localName: "大阪", latitude: 34.6937, longitude: 135.5023)
                    ]),
                    Region(name: "Kyoto", localName: "京都府", cities: [
                        City(name: "Kyoto", localName: "京都", latitude: 35.0116, longitude: 135.7681)
                    ]),
                    Region(name: "Hokkaido", localName: "北海道", cities: [
                        City(name: "Sapporo", localName: "札幌", latitude: 43.0642, longitude: 141.3469)
                    ])
                ]
            ),

            // 英国
            Country(
                name: "United Kingdom",
                localName: "英国",
                code: "GB",
                regions: [
                    Region(name: "England", localName: "英格兰", cities: [
                        City(name: "London", localName: "伦敦", latitude: 51.5074, longitude: -0.1278),
                        City(name: "Manchester", localName: "曼彻斯特", latitude: 53.4808, longitude: -2.2426)
                    ]),
                    Region(name: "Scotland", localName: "苏格兰", cities: [
                        City(name: "Edinburgh", localName: "爱丁堡", latitude: 55.9533, longitude: -3.1883)
                    ])
                ]
            ),

            // 法国
            Country(
                name: "France",
                localName: "法国",
                code: "FR",
                regions: [
                    Region(name: "Île-de-France", localName: "法兰西岛", cities: [
                        City(name: "Paris", localName: "巴黎", latitude: 48.8566, longitude: 2.3522)
                    ]),
                    Region(name: "Provence-Alpes-Côte d'Azur", localName: "普罗旺斯", cities: [
                        City(name: "Nice", localName: "尼斯", latitude: 43.7102, longitude: 7.2620)
                    ])
                ]
            ),

            // 澳大利亚
            Country(
                name: "Australia",
                localName: "澳大利亚",
                code: "AU",
                regions: [
                    Region(name: "New South Wales", localName: "新南威尔士州", cities: [
                        City(name: "Sydney", localName: "悉尼", latitude: -33.8688, longitude: 151.2093)
                    ]),
                    Region(name: "Victoria", localName: "维多利亚州", cities: [
                        City(name: "Melbourne", localName: "墨尔本", latitude: -37.8136, longitude: 144.9631)
                    ])
                ]
            ),

            // 意大利
            Country(
                name: "Italy",
                localName: "意大利",
                code: "IT",
                regions: [
                    Region(name: "Lazio", localName: "拉齐奥", cities: [
                        City(name: "Rome", localName: "罗马", latitude: 41.9028, longitude: 12.4964)
                    ]),
                    Region(name: "Lombardy", localName: "伦巴第", cities: [
                        City(name: "Milan", localName: "米兰", latitude: 45.4642, longitude: 9.1900)
                    ]),
                    Region(name: "Veneto", localName: "威尼托", cities: [
                        City(name: "Venice", localName: "威尼斯", latitude: 45.4408, longitude: 12.3155)
                    ])
                ]
            ),

            // 西班牙
            Country(
                name: "Spain",
                localName: "西班牙",
                code: "ES",
                regions: [
                    Region(name: "Community of Madrid", localName: "马德里自治区", cities: [
                        City(name: "Madrid", localName: "马德里", latitude: 40.4168, longitude: -3.7038)
                    ]),
                    Region(name: "Catalonia", localName: "加泰罗尼亚", cities: [
                        City(name: "Barcelona", localName: "巴塞罗那", latitude: 41.3851, longitude: 2.1734)
                    ])
                ]
            ),

            // 德国
            Country(
                name: "Germany",
                localName: "德国",
                code: "DE",
                regions: [
                    Region(name: "Bavaria", localName: "巴伐利亚", cities: [
                        City(name: "Munich", localName: "慕尼黑", latitude: 48.1351, longitude: 11.5820)
                    ]),
                    Region(name: "Berlin", localName: "柏林", cities: [
                        City(name: "Berlin", localName: "柏林", latitude: 52.5200, longitude: 13.4050)
                    ])
                ]
            ),

            // 韩国
            Country(
                name: "South Korea",
                localName: "韩国",
                code: "KR",
                regions: [
                    Region(name: "Seoul", localName: "首尔特别市", cities: [
                        City(name: "Seoul", localName: "首尔", latitude: 37.5665, longitude: 126.9780)
                    ]),
                    Region(name: "Busan", localName: "釜山广域市", cities: [
                        City(name: "Busan", localName: "釜山", latitude: 35.1796, longitude: 129.0756)
                    ])
                ]
            ),

            // 泰国
            Country(
                name: "Thailand",
                localName: "泰国",
                code: "TH",
                regions: [
                    Region(name: "Bangkok", localName: "曼谷", cities: [
                        City(name: "Bangkok", localName: "曼谷", latitude: 13.7563, longitude: 100.5018)
                    ]),
                    Region(name: "Phuket", localName: "普吉", cities: [
                        City(name: "Phuket", localName: "普吉", latitude: 7.8804, longitude: 98.3923)
                    ])
                ]
            ),

            // 新加坡
            Country(
                name: "Singapore",
                localName: "新加坡",
                code: "SG",
                regions: [
                    Region(name: "Singapore", localName: "新加坡", cities: [
                        City(name: "Singapore", localName: "新加坡", latitude: 1.3521, longitude: 103.8198)
                    ])
                ]
            ),

            // 加拿大
            Country(
                name: "Canada",
                localName: "加拿大",
                code: "CA",
                regions: [
                    Region(name: "Ontario", localName: "安大略省", cities: [
                        City(name: "Toronto", localName: "多伦多", latitude: 43.6532, longitude: -79.3832)
                    ]),
                    Region(name: "Quebec", localName: "魁北克省", cities: [
                        City(name: "Montreal", localName: "蒙特利尔", latitude: 45.5017, longitude: -73.5673)
                    ]),
                    Region(name: "British Columbia", localName: "不列颠哥伦比亚省", cities: [
                        City(name: "Vancouver", localName: "温哥华", latitude: 49.2827, longitude: -123.1207)
                    ])
                ]
            )
        ]
    }

    func findCountry(byName name: String) -> Country? {
        countries.first { $0.name == name || $0.localName == name }
    }
}
