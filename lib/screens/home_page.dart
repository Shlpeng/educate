import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/districts.dart';
import '../data/district_stats.dart';
import '../data/schools.dart';
import '../models/school.dart';
import '../state/app_state.dart';
import '../widgets/school_card.dart';
import 'favorites_page.dart';
import 'compare_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openDistrictPicker(AppState s) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => _DistrictPicker(state: s),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final results = s.filter(kSchools);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        // 左上角：切换地址
        title: _DistrictButton(
          district: s.selectedDistrict,
          onTap: () => _openDistrictPicker(s),
        ),
        actions: [
          IconButton(
            tooltip: '我的收藏',
            icon: Badge(
              isLabelVisible: s.favoriteIds.isNotEmpty,
              label: Text('${s.favoriteIds.length}'),
              child: const Icon(Icons.favorite_border),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FavoritesPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(controller: _searchCtrl, onChanged: s.setKeyword),
          _StageFilter(selected: s.selectedStage, onSelect: s.setStage),
          if (statsOf(s.selectedDistrict) != null)
            _DistrictStatsCard(
                district: s.selectedDistrict!,
                stats: statsOf(s.selectedDistrict)!),
          _OptionsRow(state: s, count: results.length),
          const Divider(height: 1),
          Expanded(
            child: results.isEmpty
                ? const _EmptyView()
                : _SchoolList(schools: results, groupByStage: s.selectedStage == null),
          ),
        ],
      ),
      bottomNavigationBar: s.compareCount == 0 ? null : _CompareBar(state: s),
    );
  }
}

// ---------- 底部对比栏 ----------
class _CompareBar extends StatelessWidget {
  final AppState state;
  const _CompareBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        child: Row(
          children: [
            Icon(Icons.compare_arrows, color: primary),
            const SizedBox(width: 8),
            Text('已选 ${state.compareCount} / ${AppState.compareLimit} 所',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            TextButton(
              onPressed: () => state.clearCompare(),
              child: const Text('清空'),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: state.compareCount < 2
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ComparePage()),
                      ),
              icon: const Icon(Icons.table_chart_outlined, size: 18),
              label: Text(state.compareCount < 2 ? '至少选2所' : '开始对比'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- 左上角行政区按钮 ----------
class _DistrictButton extends StatelessWidget {
  final String? district;
  final VoidCallback onTap;
  const _DistrictButton({required this.district, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = district ?? '全杭州';
    final color = district == null
        ? Theme.of(context).colorScheme.primary
        : Color(districtColor(district!));
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: color, size: 22),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('当前地区',
                    style: TextStyle(fontSize: 10, color: Colors.black54)),
                Row(
                  children: [
                    Text(label,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color)),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- 行政区选择面板 ----------
class _DistrictPicker extends StatelessWidget {
  final AppState state;
  const _DistrictPicker({required this.state});

  int _countIn(String? d) =>
      kSchools.where((s) => d == null || s.district == d).length;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择行政区',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _chip(context, null),
                ...kDistricts.map((d) => _chip(context, d)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String? d) {
    final selected = state.selectedDistrict == d;
    final color = d == null
        ? Theme.of(context).colorScheme.primary
        : Color(districtColor(d));
    return ChoiceChip(
      selected: selected,
      onSelected: (_) {
        state.setDistrict(d);
        Navigator.pop(context);
      },
      avatar: CircleAvatar(backgroundColor: color, radius: 7),
      label: Text('${d ?? '全杭州'} · ${_countIn(d)}'),
      selectedColor: color.withValues(alpha: 0.18),
      side: BorderSide(color: selected ? color : Colors.black12),
      labelStyle: TextStyle(
        color: selected ? color : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

// ---------- 搜索框 ----------
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          isDense: true,
          hintText: '搜索学校名称 / 标签 / 简介',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ---------- 学段筛选 ----------
class _StageFilter extends StatelessWidget {
  final Stage? selected;
  final ValueChanged<Stage?> onSelect;
  const _StageFilter({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _item(context, null, '全部', null),
          ...Stage.values.map(
              (st) => _item(context, st, '${st.emoji} ${st.label}', st)),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, Stage? st, String label, Stage? value) {
    final isSel = selected == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
      child: ChoiceChip(
        selected: isSel,
        label: Text(label),
        onSelected: (_) => onSelect(value),
      ),
    );
  }
}

// ---------- 选项行（只看重点 + 计数） ----------
class _OptionsRow extends StatelessWidget {
  final AppState state;
  final int count;
  const _OptionsRow({required this.state, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 12, 6),
      child: Row(
        children: [
          Text('共 $count 所',
              style: const TextStyle(color: Colors.black54, fontSize: 13)),
          const Spacer(),
          FilterChip(
            selected: state.onlyKey,
            avatar: Icon(Icons.star,
                size: 18,
                color: state.onlyKey ? Colors.amber[800] : Colors.grey),
            label: const Text('只看重点'),
            onSelected: (_) => state.toggleOnlyKey(),
          ),
        ],
      ),
    );
  }
}

// ---------- 学校列表 ----------
class _SchoolList extends StatelessWidget {
  final List<School> schools;
  final bool groupByStage;
  const _SchoolList({required this.schools, required this.groupByStage});

  @override
  Widget build(BuildContext context) {
    if (!groupByStage) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        itemCount: schools.length,
        itemBuilder: (_, i) => SchoolCard(school: schools[i]),
      );
    }
    // 按学段分组展示
    final widgets = <Widget>[];
    for (final stage in Stage.values) {
      final group = schools.where((s) => s.stage == stage).toList();
      if (group.isEmpty) continue;
      widgets.add(_StageHeader(stage: stage, count: group.length));
      widgets.addAll(group.map((s) => SchoolCard(school: s)));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      children: widgets,
    );
  }
}

class _StageHeader extends StatelessWidget {
  final Stage stage;
  final int count;
  const _StageHeader({required this.stage, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
      child: Row(
        children: [
          Text('${stage.emoji} ${stage.label}',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Text('$count',
              style: const TextStyle(color: Colors.black45, fontSize: 13)),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_outlined, size: 64, color: Colors.black26),
          SizedBox(height: 12),
          Text('没有符合条件的学校', style: TextStyle(color: Colors.black45)),
        ],
      ),
    );
  }
}

// ---------- 按区中考升学率数据卡片 ----------
class _DistrictStatsCard extends StatelessWidget {
  final String district; // 用户选中的区
  final DistrictStats stats;
  const _DistrictStatsCard({required this.district, required this.stats});

  @override
  Widget build(BuildContext context) {
    final color = Color(districtColor(district));
    final unified = isUnifiedDistrict(district);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.03)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text('${stats.scope} · ${stats.year}中考升学',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 14.5)),
              ),
              if (stats.source.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('官方数据',
                      style:
                          TextStyle(fontSize: 10.5, color: Colors.green)),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('暂无公开数据',
                      style:
                          TextStyle(fontSize: 10.5, color: Colors.black54)),
                ),
            ],
          ),
          if (unified) ...[
            const SizedBox(height: 4),
            Text('「$district」属杭州市区统一招生口径，以下为市区整体数据',
                style: TextStyle(fontSize: 11.5, color: color)),
          ],
          if (stats.puGaoRate != null) ...[
            const SizedBox(height: 10),
            _bar('普高率', stats.puGaoRate!, color),
          ],
          if (stats.eliteRate != null) ...[
            const SizedBox(height: 8),
            _bar('前八所/优高率', stats.eliteRate!, color),
          ],
          if (stats.hasData) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                if (stats.examTakers != null)
                  _fact(Icons.groups_2_outlined,
                      '毕业生约 ${stats.examTakers} 人'),
                if (stats.puGaoPlan != null)
                  _fact(Icons.event_seat_outlined,
                      '普高计划约 ${stats.puGaoPlan} 人'),
                if (stats.minLine != null)
                  _fact(Icons.straighten, '第一批控制线 ${stats.minLine} 分'),
              ],
            ),
          ],
          if (stats.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(stats.note,
                style: const TextStyle(
                    fontSize: 11.5, color: Colors.black54, height: 1.4)),
          ],
          if (stats.source.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('来源：${stats.source}（数值以官方公告为准）',
                style: const TextStyle(fontSize: 10.5, color: Colors.black38)),
          ],
        ],
      ),
    );
  }

  Widget _fact(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black45),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _bar(String label, double pct, Color color) {
    return Row(
      children: [
        SizedBox(
            width: 84,
            child: Text(label,
                style: const TextStyle(fontSize: 12.5, color: Colors.black87))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.black.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${pct.toStringAsFixed(2)}%',
            style: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
