/// 杭州各行政区（含主城区与区县市），顺序按主城优先
const List<String> kDistricts = [
  '上城区',
  '拱墅区',
  '西湖区',
  '滨江区',
  '萧山区',
  '余杭区',
  '临平区',
  '钱塘区',
  '富阳区',
  '临安区',
];

/// 每个区的主题色（用于区分），ARGB
const Map<String, int> kDistrictColors = {
  '上城区': 0xFF1565C0,
  '拱墅区': 0xFF00897B,
  '西湖区': 0xFF2E7D32,
  '滨江区': 0xFF6A1B9A,
  '萧山区': 0xFFC62828,
  '余杭区': 0xFFEF6C00,
  '临平区': 0xFFAD1457,
  '钱塘区': 0xFF00838F,
  '富阳区': 0xFF558B2F,
  '临安区': 0xFF4E342E,
};

int districtColor(String d) => kDistrictColors[d] ?? 0xFF455A64;

/// 各行政区中心点的近似坐标 [纬度, 经度]，用于学校未提供精确坐标时的地图回退。
const Map<String, List<double>> kDistrictCenter = {
  '上城区': [30.2424, 120.1700],
  '拱墅区': [30.3193, 120.1417],
  '西湖区': [30.2595, 120.1300],
  '滨江区': [30.2084, 120.2117],
  '萧山区': [30.1838, 120.2644],
  '余杭区': [30.2906, 119.9700],
  '临平区': [30.4193, 120.2983],
  '钱塘区': [30.3000, 120.3400],
  '富阳区': [30.0490, 119.9600],
  '临安区': [30.2335, 119.7240],
};

/// 杭州市大致中心（西湖一带），用于"全杭州"视图。
const List<double> kHangzhouCenter = [30.2595, 120.1551];

List<double> districtCenter(String d) => kDistrictCenter[d] ?? kHangzhouCenter;
