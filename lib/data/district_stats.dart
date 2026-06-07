/// 各行政区中考升学数据。
///
/// 重要的结构性事实（务必理解，否则数据会误导）：
/// 杭州中考**主城区"市区"是统一招生**——2024 年官方口径的"市区"包含
/// 上城区、拱墅区、西湖区、滨江区、钱塘区（及西湖风景名胜区），这些区
/// **共用同一套招生与录取**，普高率/前八所上线率是**市区一个整体数字**，
/// 并不存在"每个区各自的普高率"。
/// 萧山、余杭、临平、富阳、临安等为**独立招生区域**，各自有数据。
///
/// 因此本表分两类：
///  1) 市区统一口径（5 个主城区共享一条数据）；
///  2) 其余区——目前缺少经核实的逐区公开数据，按"暂无公开数据"如实展示。
///
/// 已核实数据来源：杭州市教育局 / 杭州市人民政府门户网站 / 杭州本地宝（转引市教育局）2024。
/// 数值仍建议以官方公告为准复核。
class DistrictStats {
  final String scope; // 展示用范围名，如"杭州市区（统一招生）"
  final int year;
  final double? puGaoRate; // 普高率 %（null=暂无公开数据）
  final double? eliteRate; // 重高/优高/前八所上线率 %（null=暂无）
  final int? examTakers; // 中考报考/初中毕业生人数（约）
  final int? puGaoPlan; // 普高招生计划人数（约）
  final int? minLine; // 第一批集中统一招生最低控制线
  final String source; // 来源（空=无可靠来源）
  final String note;

  const DistrictStats({
    required this.scope,
    required this.year,
    this.puGaoRate,
    this.eliteRate,
    this.examTakers,
    this.puGaoPlan,
    this.minLine,
    this.source = '',
    this.note = '',
  });

  bool get hasData => puGaoRate != null || examTakers != null;
}

/// 属于"市区统一招生"口径的主城区（2024 官方口径）。
const Set<String> kUnifiedDistricts = {
  '上城区',
  '拱墅区',
  '西湖区',
  '滨江区',
  '钱塘区',
};

/// 市区统一口径数据（2024，已核实）。
const DistrictStats kHangzhouCityStats = DistrictStats(
  scope: '杭州市区（统一招生）',
  year: 2024,
  puGaoRate: 70.12, // 市区普高率，较 2023 提升约 3.5 个百分点
  examTakers: 38000, // 市区初中毕业生约 3.8 万，较上年增约 1500
  puGaoPlan: 23000, // 市区普通高中计划招生约 2.3 万，较上年增约 1000
  minLine: 568, // 第一批集中统一招生 / 名额分配基础控制线
  source: '杭州市教育局 · 2024',
  note: '含上城、拱墅、西湖、滨江、钱塘（及西湖景区），统一招生、统一口径。前三所：杭二中滨江623 / 学军西溪622 / 杭高贡院619。',
);

/// 独立招生区域：暂无经核实的逐区公开数据，如实标注。
const Map<String, DistrictStats> kIndependentStats = {
  '萧山区': DistrictStats(
      scope: '萧山区（独立招生）',
      year: 2024,
      note: '萧山区为独立招生区域，区内以萧山中学为龙头；暂无经核实的逐区普高率公开数据。'),
  '余杭区': DistrictStats(
      scope: '余杭区（独立招生）',
      year: 2024,
      note: '余杭区独立招生，未来科技城带动教育扩容；暂无经核实的逐区普高率公开数据。'),
  '临平区': DistrictStats(
      scope: '临平区（独立招生）',
      year: 2024,
      note: '临平区 2021 年由原余杭东部析出，独立招生；暂无经核实的逐区普高率公开数据。'),
  '富阳区': DistrictStats(
      scope: '富阳区（独立招生）',
      year: 2024,
      note: '富阳区独立招生，区内以富阳中学为标杆；暂无经核实的逐区普高率公开数据。'),
  '临安区': DistrictStats(
      scope: '临安区（独立招生）',
      year: 2024,
      note: '临安区撤市设区后融杭加速，独立招生；暂无经核实的逐区普高率公开数据。'),
};

/// 返回某行政区应展示的中考数据。
/// - 主城区 -> 市区统一口径（共享同一条）；
/// - 独立招生区 -> 各自条目（多为"暂无公开数据"）。
DistrictStats? statsOf(String? district) {
  if (district == null) return null;
  if (kUnifiedDistricts.contains(district)) return kHangzhouCityStats;
  return kIndependentStats[district];
}

/// 该区是否走"市区统一招生"口径（用于 UI 提示）。
bool isUnifiedDistrict(String? d) =>
    d != null && kUnifiedDistricts.contains(d);
