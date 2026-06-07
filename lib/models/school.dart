/// 学段
enum Stage {
  kindergarten('幼儿园', '🧸'),
  primary('小学', '✏️'),
  junior('初中', '📐'),
  senior('高中', '🎓'),
  university('大学', '🏛️');

  final String label;
  final String emoji;
  const Stage(this.label, this.emoji);

  static Stage fromName(String name) =>
      Stage.values.firstWhere((s) => s.name == name, orElse: () => Stage.primary);
}

/// 一条评论
class Comment {
  final String text;
  final int timestamp; // 毫秒

  const Comment(this.text, this.timestamp);

  Map<String, dynamic> toJson() => {'t': text, 'ts': timestamp};

  factory Comment.fromJson(Map<String, dynamic> j) =>
      Comment(j['t'] as String, j['ts'] as int);
}

/// 学校
class School {
  final String id;
  final String name;
  final String district; // 行政区
  final Stage stage;
  final bool isKey; // 重点学校
  final List<String> tags;
  final String intro;
  final String address;
  final int baseLikes; // 初始点赞基数
  final String? imageUrl; // 学校图片（网络图，可空 -> 用渐变封面）
  final double? lat; // 精确纬度（可空 -> 用所在区中心）
  final double? lng; // 精确经度

  const School({
    required this.id,
    required this.name,
    required this.district,
    required this.stage,
    this.isKey = false,
    this.tags = const [],
    required this.intro,
    this.address = '',
    this.baseLikes = 0,
    this.imageUrl,
    this.lat,
    this.lng,
  });
}
