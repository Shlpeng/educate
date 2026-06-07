import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/districts.dart';
import '../data/schools.dart';
import '../models/school.dart';
import '../state/app_state.dart';
import '../widgets/school_cover.dart';

/// 学校对比页：所选学校并排，逐项对比。
class ComparePage extends StatelessWidget {
  const ComparePage({super.key});

  static const double _labelW = 64;
  static const double _colW = 158;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final schools = s.compareSchools(kSchools);

    return Scaffold(
      appBar: AppBar(
        title: Text('学校对比 (${schools.length})'),
        actions: [
          if (schools.isNotEmpty)
            TextButton(
              onPressed: () => s.clearCompare(),
              child: const Text('清空'),
            ),
        ],
      ),
      body: schools.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.compare_arrows, size: 64, color: Colors.black26),
                  SizedBox(height: 12),
                  Text('还没有加入对比的学校\n在学校卡片点 ⇄ 图标加入',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black45)),
                ],
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: _buildTable(context, s, schools),
              ),
            ),
    );
  }

  Widget _buildTable(BuildContext context, AppState s, List<School> schools) {
    final rows = <Widget>[
      _coverRow(context, s, schools),
      _row('行政区', schools, (sc) => _districtCell(sc), shaded: true),
      _row('学段', schools, (sc) => Text('${sc.stage.emoji} ${sc.stage.label}')),
      _row('重点', schools,
          (sc) => sc.isKey
              ? const Text('⭐ 重点', style: TextStyle(color: Color(0xFFB8860B), fontWeight: FontWeight.bold))
              : const Text('—', style: TextStyle(color: Colors.black38)),
          shaded: true),
      _row('点赞', schools, (sc) => Text('${s.likeCount(sc)}')),
      _row('评论', schools, (sc) => Text('${s.commentCount(sc.id)}'), shaded: true),
      _row('标签', schools,
          (sc) => Text(sc.tags.isEmpty ? '—' : sc.tags.map((t) => '#$t').join(' '),
              style: const TextStyle(fontSize: 12))),
      _row('地址', schools,
          (sc) => Text(sc.address.isEmpty ? '—' : sc.address,
              style: const TextStyle(fontSize: 12)),
          shaded: true),
      _row('简介', schools,
          (sc) => Text(sc.intro, style: const TextStyle(fontSize: 12, height: 1.4))),
    ];
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  // 顶部：封面 + 校名 + 移除按钮
  Widget _coverRow(BuildContext context, AppState s, List<School> schools) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: _labelW),
        ...schools.map((sc) => SizedBox(
              width: _colW,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SchoolCover(school: sc, height: 84),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: InkWell(
                            onTap: () => s.toggleCompare(sc.id),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.all(2),
                              child: const Icon(Icons.close,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(sc.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13.5)),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _districtCell(School sc) {
    final color = Color(districtColor(sc.district));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(backgroundColor: color, radius: 5),
        const SizedBox(width: 4),
        Text(sc.district, style: TextStyle(color: color)),
      ],
    );
  }

  Widget _row(String label, List<School> schools, Widget Function(School) cell,
      {bool shaded = false}) {
    return Container(
      color: shaded ? Colors.black.withValues(alpha: 0.03) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _labelW,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12.5,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          ...schools.map((sc) => Container(
                width: _colW,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                child: DefaultTextStyle.merge(
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  child: cell(sc),
                ),
              )),
        ],
      ),
    );
  }
}
