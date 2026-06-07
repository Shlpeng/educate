import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/school.dart';

/// 全局状态：当前筛选条件 + 用户的点赞/收藏/评论（本地持久化）。
class AppState extends ChangeNotifier {
  static const _kLikes = 'liked_ids';
  static const _kFavs = 'favorite_ids';
  static const _kComments = 'comments_json';
  static const _kFavGroup = 'fav_group_json'; // schoolId -> 分组名
  static const _kFavGroups = 'fav_groups'; // 自定义分组顺序

  static const String kUngrouped = '未分组';
  static const List<String> _defaultGroups = ['想去', '保底', '再看看'];

  late SharedPreferences _prefs;

  // 筛选：null 表示"全部"
  String? selectedDistrict;
  Stage? selectedStage;
  String keyword = '';
  bool onlyKey = false; // 只看重点

  final Set<String> _likedIds = {};
  final Set<String> _favoriteIds = {};
  final Map<String, List<Comment>> _comments = {};
  final Map<String, String> _favGroup = {}; // schoolId -> 分组名
  final List<String> _favGroups = [..._defaultGroups]; // 可自定义的分组

  // 对比（仅会话内，不持久化）
  final Set<String> _compareIds = {};
  static const int compareLimit = 4;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _likedIds.addAll(_prefs.getStringList(_kLikes) ?? const []);
    _favoriteIds.addAll(_prefs.getStringList(_kFavs) ?? const []);
    final raw = _prefs.getString(_kComments);
    if (raw != null && raw.isNotEmpty) {
      final Map<String, dynamic> m = jsonDecode(raw) as Map<String, dynamic>;
      m.forEach((k, v) {
        _comments[k] = (v as List)
            .map((e) => Comment.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    }
    // 收藏分组
    final fg = _prefs.getString(_kFavGroup);
    if (fg != null && fg.isNotEmpty) {
      final Map<String, dynamic> m = jsonDecode(fg) as Map<String, dynamic>;
      m.forEach((k, v) => _favGroup[k] = v as String);
    }
    final savedGroups = _prefs.getStringList(_kFavGroups);
    if (savedGroups != null && savedGroups.isNotEmpty) {
      _favGroups
        ..clear()
        ..addAll(savedGroups);
    }
    notifyListeners();
  }

  // ---- 筛选 ----
  void setDistrict(String? d) {
    selectedDistrict = d;
    notifyListeners();
  }

  void setStage(Stage? s) {
    selectedStage = s;
    notifyListeners();
  }

  void setKeyword(String k) {
    keyword = k.trim();
    notifyListeners();
  }

  void toggleOnlyKey() {
    onlyKey = !onlyKey;
    notifyListeners();
  }

  // ---- 点赞 ----
  bool isLiked(String id) => _likedIds.contains(id);

  int likeCount(School s) => s.baseLikes + (isLiked(s.id) ? 1 : 0);

  void toggleLike(String id) {
    if (!_likedIds.add(id)) _likedIds.remove(id);
    _prefs.setStringList(_kLikes, _likedIds.toList());
    notifyListeners();
  }

  // ---- 收藏 ----
  bool isFavorite(String id) => _favoriteIds.contains(id);

  Set<String> get favoriteIds => _favoriteIds;

  void toggleFavorite(String id) {
    if (_favoriteIds.add(id)) {
      _favGroup[id] = kUngrouped; // 新收藏默认未分组
    } else {
      _favoriteIds.remove(id);
      _favGroup.remove(id);
    }
    _prefs.setStringList(_kFavs, _favoriteIds.toList());
    _persistFavGroup();
    notifyListeners();
  }

  // ---- 收藏分组 ----
  /// 所有分组（自定义分组 + 末尾的"未分组"）。
  List<String> get favGroups => [..._favGroups, kUngrouped];

  String groupOf(String id) => _favGroup[id] ?? kUngrouped;

  void setFavGroup(String id, String group) {
    if (!_favoriteIds.contains(id)) return;
    _favGroup[id] = group;
    _persistFavGroup();
    notifyListeners();
  }

  void addFavGroup(String name) {
    final n = name.trim();
    if (n.isEmpty || n == kUngrouped || _favGroups.contains(n)) return;
    _favGroups.add(n);
    _prefs.setStringList(_kFavGroups, _favGroups);
    notifyListeners();
  }

  void removeFavGroup(String name) {
    if (!_favGroups.remove(name)) return;
    // 该分组下的收藏退回"未分组"
    for (final e in _favGroup.entries.toList()) {
      if (e.value == name) _favGroup[e.key] = kUngrouped;
    }
    _prefs.setStringList(_kFavGroups, _favGroups);
    _persistFavGroup();
    notifyListeners();
  }

  /// 按分组返回收藏的学校（只返回非空分组），保持 favGroups 的顺序。
  Map<String, List<School>> favoritesByGroup(List<School> all) {
    final byId = {for (final s in all) s.id: s};
    final result = <String, List<School>>{};
    for (final g in favGroups) {
      final list = <School>[];
      for (final id in _favoriteIds) {
        if (groupOf(id) == g && byId.containsKey(id)) list.add(byId[id]!);
      }
      if (list.isNotEmpty) result[g] = list;
    }
    return result;
  }

  void _persistFavGroup() => _prefs.setString(_kFavGroup, jsonEncode(_favGroup));

  // ---- 对比 ----
  bool isComparing(String id) => _compareIds.contains(id);
  int get compareCount => _compareIds.length;
  Set<String> get compareIds => _compareIds;

  /// 切换对比；超出上限返回 false（供 UI 提示）。
  bool toggleCompare(String id) {
    if (_compareIds.contains(id)) {
      _compareIds.remove(id);
      notifyListeners();
      return true;
    }
    if (_compareIds.length >= compareLimit) return false;
    _compareIds.add(id);
    notifyListeners();
    return true;
  }

  void clearCompare() {
    _compareIds.clear();
    notifyListeners();
  }

  List<School> compareSchools(List<School> all) =>
      all.where((s) => _compareIds.contains(s.id)).toList();

  // ---- 评论 ----
  List<Comment> commentsOf(String id) => _comments[id] ?? const [];

  int commentCount(String id) => _comments[id]?.length ?? 0;

  void addComment(String id, String text, int nowMs) {
    final t = text.trim();
    if (t.isEmpty) return;
    (_comments[id] ??= []).insert(0, Comment(t, nowMs));
    _persistComments();
    notifyListeners();
  }

  void deleteComment(String id, int index) {
    final list = _comments[id];
    if (list == null || index < 0 || index >= list.length) return;
    list.removeAt(index);
    _persistComments();
    notifyListeners();
  }

  void _persistComments() {
    final m = _comments.map(
      (k, v) => MapEntry(k, v.map((c) => c.toJson()).toList()),
    );
    _prefs.setString(_kComments, jsonEncode(m));
  }

  // ---- 筛选执行 ----
  List<School> filter(List<School> all) {
    return all.where((s) {
      if (selectedDistrict != null && s.district != selectedDistrict) {
        return false;
      }
      if (selectedStage != null && s.stage != selectedStage) return false;
      if (onlyKey && !s.isKey) return false;
      if (keyword.isNotEmpty) {
        final hay = '${s.name}${s.district}${s.intro}${s.tags.join()}';
        if (!hay.contains(keyword)) return false;
      }
      return true;
    }).toList();
  }
}
