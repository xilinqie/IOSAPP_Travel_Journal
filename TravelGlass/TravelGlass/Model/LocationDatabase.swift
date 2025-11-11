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
            // 中国 - China (34 Provincial-level Divisions)
            Country(
                name: "China",
                localName: "中国",
                code: "CN",
                regions: [
                    // 4 Municipalities (直辖市)
                    Region(name: "Beijing", localName: "北京市", cities: [
                        City(name: "Beijing", localName: "北京", latitude: 39.9042, longitude: 116.4074)
                    ]),
                    Region(name: "Shanghai", localName: "上海市", cities: [
                        City(name: "Shanghai", localName: "上海", latitude: 31.2304, longitude: 121.4737)
                    ]),
                    Region(name: "Tianjin", localName: "天津市", cities: [
                        City(name: "Tianjin", localName: "天津", latitude: 39.3434, longitude: 117.3616)
                    ]),
                    Region(name: "Chongqing", localName: "重庆市", cities: [
                        City(name: "Chongqing", localName: "重庆", latitude: 29.4316, longitude: 106.9123)
                    ]),

                    // 23 Provinces (省)
                    // Hebei Province (河北省)
                    Region(name: "Hebei", localName: "河北省", cities: [
                        City(name: "Shijiazhuang", localName: "石家庄", latitude: 38.0428, longitude: 114.5149),
                        City(name: "Tangshan", localName: "唐山", latitude: 39.6304, longitude: 118.1748),
                        City(name: "Qinhuangdao", localName: "秦皇岛", latitude: 39.9398, longitude: 119.6003),
                        City(name: "Handan", localName: "邯郸", latitude: 36.6116, longitude: 114.4894),
                        City(name: "Xingtai", localName: "邢台", latitude: 37.0682, longitude: 114.5042),
                        City(name: "Baoding", localName: "保定", latitude: 38.8738, longitude: 115.4648),
                        City(name: "Zhangjiakou", localName: "张家口", latitude: 40.8108, longitude: 114.8793),
                        City(name: "Chengde", localName: "承德", latitude: 40.9739, longitude: 117.9632),
                        City(name: "Cangzhou", localName: "沧州", latitude: 38.3037, longitude: 116.8389),
                        City(name: "Langfang", localName: "廊坊", latitude: 39.5216, longitude: 116.6838),
                        City(name: "Hengshui", localName: "衡水", latitude: 37.7389, longitude: 115.6701)
                    ]),

                    // Shanxi Province (山西省)
                    Region(name: "Shanxi", localName: "山西省", cities: [
                        City(name: "Taiyuan", localName: "太原", latitude: 37.8706, longitude: 112.5489),
                        City(name: "Datong", localName: "大同", latitude: 40.0769, longitude: 113.2951),
                        City(name: "Yangquan", localName: "阳泉", latitude: 37.8575, longitude: 113.5832),
                        City(name: "Changzhi", localName: "长治", latitude: 36.1953, longitude: 113.1163),
                        City(name: "Jincheng", localName: "晋城", latitude: 35.4973, longitude: 112.8513),
                        City(name: "Shuozhou", localName: "朔州", latitude: 39.3313, longitude: 112.4328),
                        City(name: "Jinzhong", localName: "晋中", latitude: 37.6872, longitude: 112.7525),
                        City(name: "Yuncheng", localName: "运城", latitude: 35.0267, longitude: 111.0037),
                        City(name: "Xinzhou", localName: "忻州", latitude: 38.4167, longitude: 112.7334),
                        City(name: "Linfen", localName: "临汾", latitude: 36.0881, longitude: 111.5189),
                        City(name: "Lüliang", localName: "吕梁", latitude: 37.5177, longitude: 111.1349)
                    ]),

                    // Inner Mongolia (内蒙古自治区)
                    Region(name: "Inner Mongolia", localName: "内蒙古自治区", cities: [
                        City(name: "Hohhot", localName: "呼和浩特", latitude: 40.8414, longitude: 111.7519),
                        City(name: "Baotou", localName: "包头", latitude: 40.6574, longitude: 109.8403),
                        City(name: "Wuhai", localName: "乌海", latitude: 39.6542, longitude: 106.8254),
                        City(name: "Chifeng", localName: "赤峰", latitude: 42.2578, longitude: 118.8872),
                        City(name: "Tongliao", localName: "通辽", latitude: 43.6174, longitude: 122.2632),
                        City(name: "Ordos", localName: "鄂尔多斯", latitude: 39.6086, longitude: 109.7810),
                        City(name: "Hulunbuir", localName: "呼伦贝尔", latitude: 49.2121, longitude: 119.7651),
                        City(name: "Bayannur", localName: "巴彦淖尔", latitude: 40.7574, longitude: 107.4163),
                        City(name: "Ulanqab", localName: "乌兰察布", latitude: 40.9944, longitude: 113.1328)
                    ]),

                    // Liaoning Province (辽宁省)
                    Region(name: "Liaoning", localName: "辽宁省", cities: [
                        City(name: "Shenyang", localName: "沈阳", latitude: 41.8057, longitude: 123.4328),
                        City(name: "Dalian", localName: "大连", latitude: 38.9140, longitude: 121.6147),
                        City(name: "Anshan", localName: "鞍山", latitude: 41.1089, longitude: 122.9945),
                        City(name: "Fushun", localName: "抚顺", latitude: 41.8773, longitude: 123.9572),
                        City(name: "Benxi", localName: "本溪", latitude: 41.2978, longitude: 123.7677),
                        City(name: "Dandong", localName: "丹东", latitude: 40.1290, longitude: 124.3544),
                        City(name: "Jinzhou", localName: "锦州", latitude: 41.0956, longitude: 121.1270),
                        City(name: "Yingkou", localName: "营口", latitude: 40.6676, longitude: 122.2352),
                        City(name: "Fuxin", localName: "阜新", latitude: 42.0118, longitude: 121.6708),
                        City(name: "Liaoyang", localName: "辽阳", latitude: 41.2694, longitude: 123.2373),
                        City(name: "Panjin", localName: "盘锦", latitude: 41.1190, longitude: 122.0704),
                        City(name: "Tieling", localName: "铁岭", latitude: 42.2906, longitude: 123.8449),
                        City(name: "Chaoyang", localName: "朝阳", latitude: 41.5762, longitude: 120.4506),
                        City(name: "Huludao", localName: "葫芦岛", latitude: 40.7110, longitude: 120.8378)
                    ]),

                    // Jilin Province (吉林省)
                    Region(name: "Jilin", localName: "吉林省", cities: [
                        City(name: "Changchun", localName: "长春", latitude: 43.8868, longitude: 125.3245),
                        City(name: "Jilin City", localName: "吉林", latitude: 43.8378, longitude: 126.5494),
                        City(name: "Siping", localName: "四平", latitude: 43.1703, longitude: 124.3505),
                        City(name: "Liaoyuan", localName: "辽源", latitude: 42.9027, longitude: 125.1453),
                        City(name: "Tonghua", localName: "通化", latitude: 41.7212, longitude: 125.9397),
                        City(name: "Baishan", localName: "白山", latitude: 41.9425, longitude: 126.4275),
                        City(name: "Songyuan", localName: "松原", latitude: 45.1411, longitude: 124.8254),
                        City(name: "Baicheng", localName: "白城", latitude: 45.6196, longitude: 122.8407)
                    ]),

                    // Heilongjiang Province (黑龙江省)
                    Region(name: "Heilongjiang", localName: "黑龙江省", cities: [
                        City(name: "Harbin", localName: "哈尔滨", latitude: 45.8038, longitude: 126.5340),
                        City(name: "Qiqihar", localName: "齐齐哈尔", latitude: 47.3543, longitude: 123.9180),
                        City(name: "Jixi", localName: "鸡西", latitude: 45.3000, longitude: 130.9697),
                        City(name: "Hegang", localName: "鹤岗", latitude: 47.3499, longitude: 130.2977),
                        City(name: "Shuangyashan", localName: "双鸭山", latitude: 46.6434, longitude: 131.1571),
                        City(name: "Daqing", localName: "大庆", latitude: 46.5896, longitude: 125.1032),
                        City(name: "Yichun", localName: "伊春", latitude: 47.7279, longitude: 128.8999),
                        City(name: "Jiamusi", localName: "佳木斯", latitude: 46.7995, longitude: 130.3186),
                        City(name: "Qitaihe", localName: "七台河", latitude: 45.7710, longitude: 130.8533),
                        City(name: "Mudanjiang", localName: "牡丹江", latitude: 44.5513, longitude: 129.6333),
                        City(name: "Heihe", localName: "黑河", latitude: 50.2452, longitude: 127.5288),
                        City(name: "Suihua", localName: "绥化", latitude: 46.6374, longitude: 126.9693)
                    ]),

                    // Jiangsu Province (江苏省)
                    Region(name: "Jiangsu", localName: "江苏省", cities: [
                        City(name: "Nanjing", localName: "南京", latitude: 32.0603, longitude: 118.7969),
                        City(name: "Wuxi", localName: "无锡", latitude: 31.4912, longitude: 120.3119),
                        City(name: "Xuzhou", localName: "徐州", latitude: 34.2044, longitude: 117.2844),
                        City(name: "Changzhou", localName: "常州", latitude: 31.8122, longitude: 119.9742),
                        City(name: "Suzhou", localName: "苏州", latitude: 31.2989, longitude: 120.5853),
                        City(name: "Nantong", localName: "南通", latitude: 32.0146, longitude: 120.8944),
                        City(name: "Lianyungang", localName: "连云港", latitude: 34.5969, longitude: 119.2216),
                        City(name: "Huai'an", localName: "淮安", latitude: 33.5904, longitude: 119.1139),
                        City(name: "Yancheng", localName: "盐城", latitude: 33.3476, longitude: 120.1633),
                        City(name: "Yangzhou", localName: "扬州", latitude: 32.3912, longitude: 119.4363),
                        City(name: "Zhenjiang", localName: "镇江", latitude: 32.1880, longitude: 119.4550),
                        City(name: "Taizhou", localName: "泰州", latitude: 32.4849, longitude: 119.9225),
                        City(name: "Suqian", localName: "宿迁", latitude: 33.9630, longitude: 118.2757)
                    ]),

                    // Zhejiang Province (浙江省)
                    Region(name: "Zhejiang", localName: "浙江省", cities: [
                        City(name: "Hangzhou", localName: "杭州", latitude: 30.2741, longitude: 120.1551),
                        City(name: "Ningbo", localName: "宁波", latitude: 29.8683, longitude: 121.5440),
                        City(name: "Wenzhou", localName: "温州", latitude: 28.0001, longitude: 120.6719),
                        City(name: "Jiaxing", localName: "嘉兴", latitude: 30.7468, longitude: 120.7506),
                        City(name: "Huzhou", localName: "湖州", latitude: 30.8941, longitude: 120.0867),
                        City(name: "Shaoxing", localName: "绍兴", latitude: 30.0326, longitude: 120.5820),
                        City(name: "Jinhua", localName: "金华", latitude: 29.0789, longitude: 119.6478),
                        City(name: "Quzhou", localName: "衢州", latitude: 28.9700, longitude: 118.8591),
                        City(name: "Zhoushan", localName: "舟山", latitude: 29.9853, longitude: 122.2072),
                        City(name: "Taizhou", localName: "台州", latitude: 28.6562, longitude: 121.4287),
                        City(name: "Lishui", localName: "丽水", latitude: 28.4675, longitude: 119.9174)
                    ]),

                    // Anhui Province (安徽省)
                    Region(name: "Anhui", localName: "安徽省", cities: [
                        City(name: "Hefei", localName: "合肥", latitude: 31.8206, longitude: 117.2272),
                        City(name: "Wuhu", localName: "芜湖", latitude: 31.3526, longitude: 118.3761),
                        City(name: "Bengbu", localName: "蚌埠", latitude: 32.9397, longitude: 117.3889),
                        City(name: "Huainan", localName: "淮南", latitude: 32.6475, longitude: 116.9998),
                        City(name: "Ma'anshan", localName: "马鞍山", latitude: 31.6707, longitude: 118.5079),
                        City(name: "Huaibei", localName: "淮北", latitude: 33.9717, longitude: 116.7947),
                        City(name: "Tongling", localName: "铜陵", latitude: 30.9299, longitude: 117.8121),
                        City(name: "Anqing", localName: "安庆", latitude: 30.5378, longitude: 117.0430),
                        City(name: "Huangshan", localName: "黄山", latitude: 29.7151, longitude: 118.3377),
                        City(name: "Chuzhou", localName: "滁州", latitude: 32.3173, longitude: 118.3162),
                        City(name: "Fuyang", localName: "阜阳", latitude: 32.8899, longitude: 115.8145),
                        City(name: "Suzhou", localName: "宿州", latitude: 33.6461, longitude: 116.9641),
                        City(name: "Lu'an", localName: "六安", latitude: 31.7529, longitude: 116.5078),
                        City(name: "Bozhou", localName: "亳州", latitude: 33.8712, longitude: 115.7783),
                        City(name: "Chizhou", localName: "池州", latitude: 30.6666, longitude: 117.4898),
                        City(name: "Xuancheng", localName: "宣城", latitude: 30.9406, longitude: 118.7590)
                    ]),

                    // Fujian Province (福建省)
                    Region(name: "Fujian", localName: "福建省", cities: [
                        City(name: "Fuzhou", localName: "福州", latitude: 26.0745, longitude: 119.2965),
                        City(name: "Xiamen", localName: "厦门", latitude: 24.4798, longitude: 118.0894),
                        City(name: "Putian", localName: "莆田", latitude: 25.4540, longitude: 119.0077),
                        City(name: "Sanming", localName: "三明", latitude: 26.2634, longitude: 117.6389),
                        City(name: "Quanzhou", localName: "泉州", latitude: 24.8738, longitude: 118.6754),
                        City(name: "Zhangzhou", localName: "漳州", latitude: 24.5130, longitude: 117.6472),
                        City(name: "Nanping", localName: "南平", latitude: 26.6449, longitude: 118.1772),
                        City(name: "Longyan", localName: "龙岩", latitude: 25.0786, longitude: 117.0172),
                        City(name: "Ningde", localName: "宁德", latitude: 26.6590, longitude: 119.5477)
                    ]),

                    // Jiangxi Province (江西省)
                    Region(name: "Jiangxi", localName: "江西省", cities: [
                        City(name: "Nanchang", localName: "南昌", latitude: 28.6829, longitude: 115.8579),
                        City(name: "Jingdezhen", localName: "景德镇", latitude: 29.2686, longitude: 117.1784),
                        City(name: "Pingxiang", localName: "萍乡", latitude: 27.6229, longitude: 113.8520),
                        City(name: "Jiujiang", localName: "九江", latitude: 29.7051, longitude: 116.0014),
                        City(name: "Xinyu", localName: "新余", latitude: 27.8176, longitude: 114.9167),
                        City(name: "Yingtan", localName: "鹰潭", latitude: 28.2386, longitude: 117.0338),
                        City(name: "Ganzhou", localName: "赣州", latitude: 25.8316, longitude: 114.9336),
                        City(name: "Ji'an", localName: "吉安", latitude: 27.1139, longitude: 114.9926),
                        City(name: "Yichun", localName: "宜春", latitude: 27.8154, longitude: 114.4166),
                        City(name: "Fuzhou", localName: "抚州", latitude: 27.9489, longitude: 116.3583),
                        City(name: "Shangrao", localName: "上饶", latitude: 28.4544, longitude: 117.9434)
                    ]),

                    // Shandong Province (山东省)
                    Region(name: "Shandong", localName: "山东省", cities: [
                        City(name: "Jinan", localName: "济南", latitude: 36.6512, longitude: 117.1205),
                        City(name: "Qingdao", localName: "青岛", latitude: 36.0671, longitude: 120.3826),
                        City(name: "Zibo", localName: "淄博", latitude: 36.8131, longitude: 118.0548),
                        City(name: "Zaozhuang", localName: "枣庄", latitude: 34.8107, longitude: 117.3237),
                        City(name: "Dongying", localName: "东营", latitude: 37.4337, longitude: 118.6751),
                        City(name: "Yantai", localName: "烟台", latitude: 37.4638, longitude: 121.4478),
                        City(name: "Weifang", localName: "潍坊", latitude: 36.7067, longitude: 119.1619),
                        City(name: "Jining", localName: "济宁", latitude: 35.4153, longitude: 116.5874),
                        City(name: "Tai'an", localName: "泰安", latitude: 36.2003, longitude: 117.0874),
                        City(name: "Weihai", localName: "威海", latitude: 37.5130, longitude: 122.1203),
                        City(name: "Rizhao", localName: "日照", latitude: 35.4164, longitude: 119.5269),
                        City(name: "Linyi", localName: "临沂", latitude: 35.1041, longitude: 118.3563),
                        City(name: "Dezhou", localName: "德州", latitude: 37.4355, longitude: 116.3594),
                        City(name: "Liaocheng", localName: "聊城", latitude: 36.4570, longitude: 115.9859),
                        City(name: "Binzhou", localName: "滨州", latitude: 37.3835, longitude: 117.9708),
                        City(name: "Heze", localName: "菏泽", latitude: 35.2333, longitude: 115.4807)
                    ]),

                    // Henan Province (河南省)
                    Region(name: "Henan", localName: "河南省", cities: [
                        City(name: "Zhengzhou", localName: "郑州", latitude: 34.7466, longitude: 113.6253),
                        City(name: "Kaifeng", localName: "开封", latitude: 34.7971, longitude: 114.3074),
                        City(name: "Luoyang", localName: "洛阳", latitude: 34.6196, longitude: 112.4539),
                        City(name: "Pingdingshan", localName: "平顶山", latitude: 33.7352, longitude: 113.1927),
                        City(name: "Anyang", localName: "安阳", latitude: 36.0997, longitude: 114.3932),
                        City(name: "Hebi", localName: "鹤壁", latitude: 35.7479, longitude: 114.2972),
                        City(name: "Xinxiang", localName: "新乡", latitude: 35.3026, longitude: 113.9268),
                        City(name: "Jiaozuo", localName: "焦作", latitude: 35.2158, longitude: 113.2418),
                        City(name: "Puyang", localName: "濮阳", latitude: 35.7625, longitude: 115.0291),
                        City(name: "Xuchang", localName: "许昌", latitude: 34.0356, longitude: 113.8522),
                        City(name: "Luohe", localName: "漯河", latitude: 33.5816, longitude: 114.0460),
                        City(name: "Sanmenxia", localName: "三门峡", latitude: 34.7732, longitude: 111.1941),
                        City(name: "Nanyang", localName: "南阳", latitude: 32.9907, longitude: 112.5282),
                        City(name: "Shangqiu", localName: "商丘", latitude: 34.4144, longitude: 115.6560),
                        City(name: "Xinyang", localName: "信阳", latitude: 32.1470, longitude: 114.0920),
                        City(name: "Zhoukou", localName: "周口", latitude: 33.6257, longitude: 114.6419),
                        City(name: "Zhumadian", localName: "驻马店", latitude: 32.9803, longitude: 114.0221)
                    ]),

                    // Hubei Province (湖北省)
                    Region(name: "Hubei", localName: "湖北省", cities: [
                        City(name: "Wuhan", localName: "武汉", latitude: 30.5928, longitude: 114.3055),
                        City(name: "Huangshi", localName: "黄石", latitude: 30.2000, longitude: 115.0387),
                        City(name: "Shiyan", localName: "十堰", latitude: 32.6292, longitude: 110.7980),
                        City(name: "Yichang", localName: "宜昌", latitude: 30.6927, longitude: 111.2865),
                        City(name: "Xiangyang", localName: "襄阳", latitude: 32.0091, longitude: 112.1226),
                        City(name: "Ezhou", localName: "鄂州", latitude: 30.3915, longitude: 114.8949),
                        City(name: "Jingmen", localName: "荆门", latitude: 31.0354, longitude: 112.1991),
                        City(name: "Xiaogan", localName: "孝感", latitude: 30.9269, longitude: 113.9169),
                        City(name: "Jingzhou", localName: "荆州", latitude: 30.3352, longitude: 112.2410),
                        City(name: "Huanggang", localName: "黄冈", latitude: 30.4535, longitude: 114.8722),
                        City(name: "Xianning", localName: "咸宁", latitude: 29.8416, longitude: 114.3222),
                        City(name: "Suizhou", localName: "随州", latitude: 31.6904, longitude: 113.3826)
                    ]),

                    // Hunan Province (湖南省)
                    Region(name: "Hunan", localName: "湖南省", cities: [
                        City(name: "Changsha", localName: "长沙", latitude: 28.2282, longitude: 112.9388),
                        City(name: "Zhuzhou", localName: "株洲", latitude: 27.8274, longitude: 113.1339),
                        City(name: "Xiangtan", localName: "湘潭", latitude: 27.8296, longitude: 112.9443),
                        City(name: "Hengyang", localName: "衡阳", latitude: 26.8968, longitude: 112.5717),
                        City(name: "Shaoyang", localName: "邵阳", latitude: 27.2390, longitude: 111.4677),
                        City(name: "Yueyang", localName: "岳阳", latitude: 29.3570, longitude: 113.0966),
                        City(name: "Changde", localName: "常德", latitude: 29.0398, longitude: 111.6981),
                        City(name: "Zhangjiajie", localName: "张家界", latitude: 29.1166, longitude: 110.4791),
                        City(name: "Yiyang", localName: "益阳", latitude: 28.5541, longitude: 112.3550),
                        City(name: "Chenzhou", localName: "郴州", latitude: 25.7706, longitude: 113.0144),
                        City(name: "Yongzhou", localName: "永州", latitude: 26.4206, longitude: 111.6132),
                        City(name: "Huaihua", localName: "怀化", latitude: 27.5698, longitude: 109.9783),
                        City(name: "Loudi", localName: "娄底", latitude: 27.6995, longitude: 111.9937)
                    ]),

                    // Guangdong Province (广东省)
                    Region(name: "Guangdong", localName: "广东省", cities: [
                        City(name: "Guangzhou", localName: "广州", latitude: 23.1291, longitude: 113.2644),
                        City(name: "Shaoguan", localName: "韶关", latitude: 24.8101, longitude: 113.5972),
                        City(name: "Shenzhen", localName: "深圳", latitude: 22.5431, longitude: 114.0579),
                        City(name: "Zhuhai", localName: "珠海", latitude: 22.2769, longitude: 113.5678),
                        City(name: "Shantou", localName: "汕头", latitude: 23.3540, longitude: 116.6824),
                        City(name: "Foshan", localName: "佛山", latitude: 23.0218, longitude: 113.1219),
                        City(name: "Jiangmen", localName: "江门", latitude: 22.5790, longitude: 113.0815),
                        City(name: "Zhanjiang", localName: "湛江", latitude: 21.2707, longitude: 110.3577),
                        City(name: "Maoming", localName: "茂名", latitude: 21.6631, longitude: 110.9253),
                        City(name: "Zhaoqing", localName: "肇庆", latitude: 23.0469, longitude: 112.4658),
                        City(name: "Huizhou", localName: "惠州", latitude: 23.1115, longitude: 114.4152),
                        City(name: "Meizhou", localName: "梅州", latitude: 24.2888, longitude: 116.1177),
                        City(name: "Shanwei", localName: "汕尾", latitude: 22.7864, longitude: 115.3647),
                        City(name: "Heyuan", localName: "河源", latitude: 23.7433, longitude: 114.6974),
                        City(name: "Yangjiang", localName: "阳江", latitude: 21.8571, longitude: 111.9827),
                        City(name: "Qingyuan", localName: "清远", latitude: 23.6819, longitude: 113.0562),
                        City(name: "Dongguan", localName: "东莞", latitude: 23.0205, longitude: 113.7518),
                        City(name: "Zhongshan", localName: "中山", latitude: 22.5171, longitude: 113.3926),
                        City(name: "Chaozhou", localName: "潮州", latitude: 23.6567, longitude: 116.6228),
                        City(name: "Jieyang", localName: "揭阳", latitude: 23.5438, longitude: 116.3728),
                        City(name: "Yunfu", localName: "云浮", latitude: 22.9150, longitude: 112.0439)
                    ]),

                    // Guangxi Zhuang Autonomous Region (广西壮族自治区)
                    Region(name: "Guangxi", localName: "广西壮族自治区", cities: [
                        City(name: "Nanning", localName: "南宁", latitude: 22.8170, longitude: 108.3665),
                        City(name: "Liuzhou", localName: "柳州", latitude: 24.3264, longitude: 109.4281),
                        City(name: "Guilin", localName: "桂林", latitude: 25.2736, longitude: 110.2900),
                        City(name: "Wuzhou", localName: "梧州", latitude: 23.4774, longitude: 111.2785),
                        City(name: "Beihai", localName: "北海", latitude: 21.4814, longitude: 109.1200),
                        City(name: "Fangchenggang", localName: "防城港", latitude: 21.6147, longitude: 108.3545),
                        City(name: "Qinzhou", localName: "钦州", latitude: 21.9797, longitude: 108.6540),
                        City(name: "Guigang", localName: "贵港", latitude: 23.1114, longitude: 109.5989),
                        City(name: "Yulin", localName: "玉林", latitude: 22.6542, longitude: 110.1816),
                        City(name: "Baise", localName: "百色", latitude: 23.9023, longitude: 106.6187),
                        City(name: "Hezhou", localName: "贺州", latitude: 24.4038, longitude: 111.5521),
                        City(name: "Hechi", localName: "河池", latitude: 24.6928, longitude: 108.0851),
                        City(name: "Laibin", localName: "来宾", latitude: 23.7509, longitude: 109.2216),
                        City(name: "Chongzuo", localName: "崇左", latitude: 22.3769, longitude: 107.3645)
                    ]),

                    // Hainan Province (海南省)
                    Region(name: "Hainan", localName: "海南省", cities: [
                        City(name: "Haikou", localName: "海口", latitude: 20.0444, longitude: 110.1999),
                        City(name: "Sanya", localName: "三亚", latitude: 18.2528, longitude: 109.5117),
                        City(name: "Sansha", localName: "三沙", latitude: 16.8311, longitude: 112.3386),
                        City(name: "Danzhou", localName: "儋州", latitude: 19.5175, longitude: 109.5767)
                    ]),

                    // Sichuan Province (四川省)
                    Region(name: "Sichuan", localName: "四川省", cities: [
                        City(name: "Chengdu", localName: "成都", latitude: 30.5728, longitude: 104.0668),
                        City(name: "Zigong", localName: "自贡", latitude: 29.3398, longitude: 104.7785),
                        City(name: "Panzhihua", localName: "攀枝花", latitude: 26.5804, longitude: 101.7183),
                        City(name: "Luzhou", localName: "泸州", latitude: 28.8719, longitude: 105.4429),
                        City(name: "Deyang", localName: "德阳", latitude: 31.1270, longitude: 104.3979),
                        City(name: "Mianyang", localName: "绵阳", latitude: 31.4670, longitude: 104.6794),
                        City(name: "Guangyuan", localName: "广元", latitude: 32.4353, longitude: 105.8437),
                        City(name: "Suining", localName: "遂宁", latitude: 30.5327, longitude: 105.5928),
                        City(name: "Neijiang", localName: "内江", latitude: 29.5872, longitude: 105.0584),
                        City(name: "Leshan", localName: "乐山", latitude: 29.5522, longitude: 103.7657),
                        City(name: "Nanchong", localName: "南充", latitude: 30.8378, longitude: 106.1106),
                        City(name: "Meishan", localName: "眉山", latitude: 30.0575, longitude: 103.8487),
                        City(name: "Yibin", localName: "宜宾", latitude: 28.7696, longitude: 104.6430),
                        City(name: "Guang'an", localName: "广安", latitude: 30.4564, longitude: 106.6333),
                        City(name: "Dazhou", localName: "达州", latitude: 31.2090, longitude: 107.4680),
                        City(name: "Ya'an", localName: "雅安", latitude: 29.9800, longitude: 103.0133),
                        City(name: "Bazhong", localName: "巴中", latitude: 31.8691, longitude: 106.7477),
                        City(name: "Ziyang", localName: "资阳", latitude: 30.1221, longitude: 104.6419)
                    ]),

                    // Guizhou Province (贵州省)
                    Region(name: "Guizhou", localName: "贵州省", cities: [
                        City(name: "Guiyang", localName: "贵阳", latitude: 26.6470, longitude: 106.6302),
                        City(name: "Liupanshui", localName: "六盘水", latitude: 26.5948, longitude: 104.8305),
                        City(name: "Zunyi", localName: "遵义", latitude: 27.7256, longitude: 106.9274),
                        City(name: "Anshun", localName: "安顺", latitude: 26.2532, longitude: 105.9476),
                        City(name: "Bijie", localName: "毕节", latitude: 27.2849, longitude: 105.2919),
                        City(name: "Tongren", localName: "铜仁", latitude: 27.7311, longitude: 109.1895)
                    ]),

                    // Yunnan Province (云南省)
                    Region(name: "Yunnan", localName: "云南省", cities: [
                        City(name: "Kunming", localName: "昆明", latitude: 25.0406, longitude: 102.7129),
                        City(name: "Qujing", localName: "曲靖", latitude: 25.4895, longitude: 103.7964),
                        City(name: "Yuxi", localName: "玉溪", latitude: 24.3520, longitude: 102.5432),
                        City(name: "Baoshan", localName: "保山", latitude: 25.1205, longitude: 99.1619),
                        City(name: "Zhaotong", localName: "昭通", latitude: 27.3380, longitude: 103.7173),
                        City(name: "Lijiang", localName: "丽江", latitude: 26.8559, longitude: 100.2271),
                        City(name: "Pu'er", localName: "普洱", latitude: 22.8251, longitude: 100.9664),
                        City(name: "Lincang", localName: "临沧", latitude: 23.8838, longitude: 100.0870)
                    ]),

                    // Tibet Autonomous Region (西藏自治区)
                    Region(name: "Tibet", localName: "西藏自治区", cities: [
                        City(name: "Lhasa", localName: "拉萨", latitude: 29.6500, longitude: 91.1000),
                        City(name: "Shigatse", localName: "日喀则", latitude: 29.2674, longitude: 88.8805),
                        City(name: "Chamdo", localName: "昌都", latitude: 31.1369, longitude: 97.1785),
                        City(name: "Nyingchi", localName: "林芝", latitude: 29.6491, longitude: 94.3618),
                        City(name: "Shannan", localName: "山南", latitude: 29.2370, longitude: 91.7733),
                        City(name: "Nagqu", localName: "那曲", latitude: 31.4806, longitude: 92.0670)
                    ]),

                    // Shaanxi Province (陕西省)
                    Region(name: "Shaanxi", localName: "陕西省", cities: [
                        City(name: "Xi'an", localName: "西安", latitude: 34.3416, longitude: 108.9398),
                        City(name: "Tongchuan", localName: "铜川", latitude: 34.8969, longitude: 108.9450),
                        City(name: "Baoji", localName: "宝鸡", latitude: 34.3610, longitude: 107.1372),
                        City(name: "Xianyang", localName: "咸阳", latitude: 34.3456, longitude: 108.7093),
                        City(name: "Weinan", localName: "渭南", latitude: 34.5205, longitude: 109.5096),
                        City(name: "Yan'an", localName: "延安", latitude: 36.5853, longitude: 109.4897),
                        City(name: "Hanzhong", localName: "汉中", latitude: 33.0677, longitude: 107.0230),
                        City(name: "Yulin", localName: "榆林", latitude: 38.2655, longitude: 109.7341),
                        City(name: "Ankang", localName: "安康", latitude: 32.6850, longitude: 109.0286),
                        City(name: "Shangluo", localName: "商洛", latitude: 33.8682, longitude: 109.9404)
                    ]),

                    // Gansu Province (甘肃省)
                    Region(name: "Gansu", localName: "甘肃省", cities: [
                        City(name: "Lanzhou", localName: "兰州", latitude: 36.0617, longitude: 103.8343),
                        City(name: "Jiayuguan", localName: "嘉峪关", latitude: 39.7727, longitude: 98.2773),
                        City(name: "Jinchang", localName: "金昌", latitude: 38.5204, longitude: 102.1874),
                        City(name: "Baiyin", localName: "白银", latitude: 36.5449, longitude: 104.1389),
                        City(name: "Tianshui", localName: "天水", latitude: 34.5809, longitude: 105.7249),
                        City(name: "Wuwei", localName: "武威", latitude: 37.9282, longitude: 102.6380),
                        City(name: "Zhangye", localName: "张掖", latitude: 38.9259, longitude: 100.4495),
                        City(name: "Pingliang", localName: "平凉", latitude: 35.5430, longitude: 106.6650),
                        City(name: "Jiuquan", localName: "酒泉", latitude: 39.7414, longitude: 98.4942),
                        City(name: "Qingyang", localName: "庆阳", latitude: 35.7095, longitude: 107.6434),
                        City(name: "Dingxi", localName: "定西", latitude: 35.5806, longitude: 104.5860),
                        City(name: "Longnan", localName: "陇南", latitude: 33.4007, longitude: 104.9211)
                    ]),

                    // Qinghai Province (青海省)
                    Region(name: "Qinghai", localName: "青海省", cities: [
                        City(name: "Xining", localName: "西宁", latitude: 36.6171, longitude: 101.7782),
                        City(name: "Haidong", localName: "海东", latitude: 36.5029, longitude: 102.1039)
                    ]),

                    // Ningxia Hui Autonomous Region (宁夏回族自治区)
                    Region(name: "Ningxia", localName: "宁夏回族自治区", cities: [
                        City(name: "Yinchuan", localName: "银川", latitude: 38.4681, longitude: 106.2731),
                        City(name: "Shizuishan", localName: "石嘴山", latitude: 39.0133, longitude: 106.3838),
                        City(name: "Wuzhong", localName: "吴忠", latitude: 37.9974, longitude: 106.1991),
                        City(name: "Guyuan", localName: "固原", latitude: 36.0158, longitude: 106.2427),
                        City(name: "Zhongwei", localName: "中卫", latitude: 37.4993, longitude: 105.1896)
                    ]),

                    // Xinjiang Uyghur Autonomous Region (新疆维吾尔自治区)
                    Region(name: "Xinjiang", localName: "新疆维吾尔自治区", cities: [
                        City(name: "Ürümqi", localName: "乌鲁木齐", latitude: 43.8256, longitude: 87.6168),
                        City(name: "Karamay", localName: "克拉玛依", latitude: 45.5795, longitude: 84.8890),
                        City(name: "Turpan", localName: "吐鲁番", latitude: 42.9513, longitude: 89.1898),
                        City(name: "Hami", localName: "哈密", latitude: 42.8191, longitude: 93.5147)
                    ]),

                    // Hong Kong SAR (香港特别行政区)
                    Region(name: "Hong Kong SAR", localName: "香港特别行政区", cities: [
                        City(name: "Hong Kong", localName: "香港", latitude: 22.3193, longitude: 114.1694)
                    ]),

                    // Macau SAR (澳门特别行政区)
                    Region(name: "Macau SAR", localName: "澳门特别行政区", cities: [
                        City(name: "Macau", localName: "澳门", latitude: 22.1987, longitude: 113.5439)
                    ]),

                    // Taiwan Province (台湾省)
                    Region(name: "Taiwan", localName: "台湾省", cities: [
                        City(name: "Taipei", localName: "台北", latitude: 25.0330, longitude: 121.5654),
                        City(name: "New Taipei", localName: "新北", latitude: 25.0122, longitude: 121.4654),
                        City(name: "Taoyuan", localName: "桃园", latitude: 24.9936, longitude: 121.3010),
                        City(name: "Taichung", localName: "台中", latitude: 24.1477, longitude: 120.6736),
                        City(name: "Tainan", localName: "台南", latitude: 22.9999, longitude: 120.2269),
                        City(name: "Kaohsiung", localName: "高雄", latitude: 22.6273, longitude: 120.3014),
                        City(name: "Keelung", localName: "基隆", latitude: 25.1276, longitude: 121.7392),
                        City(name: "Hsinchu", localName: "新竹", latitude: 24.8138, longitude: 120.9675),
                        City(name: "Chiayi", localName: "嘉义", latitude: 23.4801, longitude: 120.4491),
                        City(name: "Hualien", localName: "花莲", latitude: 23.9871, longitude: 121.6015),
                        City(name: "Yilan", localName: "宜兰", latitude: 24.7021, longitude: 121.7378),
                        City(name: "Miaoli", localName: "苗栗", latitude: 24.5602, longitude: 120.8214),
                        City(name: "Changhua", localName: "彰化", latitude: 24.0518, longitude: 120.5161),
                        City(name: "Nantou", localName: "南投", latitude: 23.9609, longitude: 120.9719),
                        City(name: "Yunlin", localName: "云林", latitude: 23.7092, longitude: 120.4313),
                        City(name: "Pingtung", localName: "屏东", latitude: 22.6820, longitude: 120.4900),
                        City(name: "Taitung", localName: "台东", latitude: 22.7583, longitude: 121.1444),
                        City(name: "Penghu", localName: "澎湖", latitude: 23.5711, longitude: 119.5793)
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
