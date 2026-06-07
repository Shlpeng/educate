import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/districts.dart';
import '../models/school.dart';
import '../state/app_state.dart';
import '../widgets/school_cover.dart';
import '../widgets/school_map.dart';

class SchoolDetailPage extends StatefulWidget {
  final School school;
  const SchoolDetailPage({super.key, required this.school});

  @override
  State<SchoolDetailPage> createState() => _SchoolDetailPageState();
}

class _SchoolDetailPageState extends State<SchoolDetailPage> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submit(AppState s) {
    final text = _commentCtrl.text;
    if (text.trim().isEmpty) return;
    s.addComment(
        widget.school.id, text, DateTime.now().millisecondsSinceEpoch);
    _commentCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  String _fmt(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final school = widget.school;
    final color = Color(districtColor(school.district));
    final comments = s.commentsOf(school.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(school.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: '加入对比',
            icon: Icon(s.isComparing(school.id)
                ? Icons.compare_arrows
                : Icons.compare_arrows_outlined),
            onPressed: () {
              final ok = s.toggleCompare(school.id);
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('最多对比 ${AppState.compareLimit} 所学校'),
                      duration: const Duration(seconds: 2)),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(
              s.isFavorite(school.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: s.isFavorite(school.id) ? Colors.redAccent : null,
            ),
            onPressed: () => s.toggleFavorite(school.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // 封面图
          SchoolCover(school: school, height: 170, showLabel: true),
          const SizedBox(height: 14),
          // 头部
          Row(
            children: [
              Expanded(
                child: Text(school.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              if (school.isKey) _keyTag(),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(Icons.location_city, school.district, color),
              _chip(Icons.school, '${school.stage.emoji} ${school.stage.label}',
                  Colors.blueGrey),
              ...school.tags.map((t) => _chip(Icons.tag, t, Colors.indigo)),
            ],
          ),
          const SizedBox(height: 16),
          // 简介
          _sectionTitle('学校简介'),
          const SizedBox(height: 6),
          Text(school.intro,
              style: const TextStyle(fontSize: 15, height: 1.6)),
          if (school.address.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place_outlined,
                    size: 18, color: Colors.black45),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(school.address,
                        style: const TextStyle(color: Colors.black54))),
              ],
            ),
          ],
          const SizedBox(height: 18),
          // 地图定位
          _sectionTitle('地图定位'),
          const SizedBox(height: 8),
          SchoolMap(school: school),
          const SizedBox(height: 16),
          // 点赞按钮
          _LikeBar(school: school),
          const SizedBox(height: 20),
          // 评论
          _sectionTitle('评论 (${comments.length})'),
          const SizedBox(height: 8),
          _CommentInput(controller: _commentCtrl, onSubmit: () => _submit(s)),
          const SizedBox(height: 12),
          if (comments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('还没有评论，来抢沙发吧～',
                    style: TextStyle(color: Colors.black38)),
              ),
            )
          else
            ...List.generate(comments.length, (i) {
              final c = comments[i];
              return _CommentTile(
                text: c.text,
                time: _fmt(c.timestamp),
                onDelete: () => s.deleteComment(school.id, i),
              );
            }),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Row(
        children: [
          Container(width: 4, height: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(t, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      );

  Widget _chip(IconData icon, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 13)),
          ],
        ),
      );

  Widget _keyTag() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade400),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 16, color: Colors.amber.shade800),
            const SizedBox(width: 3),
            Text('重点学校',
                style: TextStyle(
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      );
}

class _LikeBar extends StatelessWidget {
  final School school;
  const _LikeBar({required this.school});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final liked = s.isLiked(school.id);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => s.toggleLike(school.id),
            icon: Icon(liked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                color: liked ? Theme.of(context).colorScheme.primary : null),
            label: Text('点赞  ${s.likeCount(school)}'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor:
                  liked ? Theme.of(context).colorScheme.primary : Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => s.toggleFavorite(school.id),
            icon: Icon(
                s.isFavorite(school.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: s.isFavorite(school.id) ? Colors.redAccent : null),
            label: Text(s.isFavorite(school.id) ? '已收藏' : '收藏'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              foregroundColor:
                  s.isFavorite(school.id) ? Colors.redAccent : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  const _CommentInput({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '说说你对这所学校的看法…',
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: onSubmit,
          style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14)),
          child: const Text('发布'),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  final String text;
  final String time;
  final VoidCallback onDelete;
  const _CommentTile(
      {required this.text, required this.time, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 13,
                child: Icon(Icons.person, size: 16),
              ),
              const SizedBox(width: 8),
              const Text('我', style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(time,
                  style: const TextStyle(color: Colors.black38, fontSize: 12)),
              InkWell(
                onTap: onDelete,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.delete_outline,
                      size: 18, color: Colors.black38),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(fontSize: 14.5, height: 1.5)),
        ],
      ),
    );
  }
}
