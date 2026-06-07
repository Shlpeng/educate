import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/schools.dart';
import '../models/school.dart';
import '../state/app_state.dart';
import '../widgets/school_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final grouped = s.favoritesByGroup(kSchools);
    final total = s.favoriteIds.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('我的收藏 ($total)'),
        actions: [
          IconButton(
            tooltip: '新建分组',
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: () => _newGroupDialog(context, s),
          ),
        ],
      ),
      body: total == 0
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.black26),
                  SizedBox(height: 12),
                  Text('还没有收藏的学校', style: TextStyle(color: Colors.black45)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              children: [
                for (final entry in grouped.entries) ...[
                  _GroupHeader(name: entry.key, count: entry.value.length),
                  ...entry.value.map((sc) => _FavItem(school: sc, state: s)),
                ],
              ],
            ),
    );
  }

  void _newGroupDialog(BuildContext context, AppState s) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('新建分组'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '例如：冲刺、保底、家附近'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              s.addFavGroup(ctrl.text);
              Navigator.pop(context);
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String name;
  final int count;
  const _GroupHeader({required this.name, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
      child: Row(
        children: [
          Icon(Icons.folder_outlined,
              size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(name,
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

class _FavItem extends StatelessWidget {
  final School school;
  final AppState state;
  const _FavItem({required this.school, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SchoolCard(school: school),
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Row(
            children: [
              const Icon(Icons.drive_file_move_outline,
                  size: 15, color: Colors.black38),
              const SizedBox(width: 4),
              const Text('分组：',
                  style: TextStyle(fontSize: 12, color: Colors.black45)),
              InkWell(
                onTap: () => _pickGroup(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.groupOf(school.id),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      const Icon(Icons.arrow_drop_down, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _pickGroup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Consumer<AppState>(
          builder: (ctx, s, _) {
            final current = s.groupOf(school.id);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('「${school.name}」移动到分组',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final g in s.favGroups)
                          ChoiceChip(
                            selected: current == g,
                            label: Text(g),
                            onSelected: (_) {
                              s.setFavGroup(school.id, g);
                              Navigator.pop(ctx);
                            },
                          ),
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 16),
                          label: const Text('新建分组'),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _newGroupAndAssign(context, s);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _newGroupAndAssign(BuildContext context, AppState s) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('新建分组并移入'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '分组名'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                s.addFavGroup(name);
                s.setFavGroup(school.id, name);
              }
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
