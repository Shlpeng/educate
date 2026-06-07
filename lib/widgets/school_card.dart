import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/districts.dart';
import '../models/school.dart';
import '../state/app_state.dart';
import '../screens/school_detail_page.dart';
import 'school_cover.dart';

class SchoolCard extends StatelessWidget {
  final School school;
  const SchoolCard({super.key, required this.school});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final color = Color(districtColor(school.district));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: school.isKey ? Colors.amber.shade300 : Colors.black12,
          width: school.isKey ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SchoolDetailPage(school: school)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧封面缩略图
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: SchoolCover(
                      school: school,
                      height: 56,
                      radius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                school.name,
                                style: const TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (school.isKey) const _KeyBadge(),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            _Pill(
                                text: school.district,
                                color: color,
                                filled: true),
                            const SizedBox(width: 6),
                            _Pill(
                                text:
                                    '${school.stage.emoji} ${school.stage.label}',
                                color: Colors.blueGrey),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: '加入对比',
                    icon: Icon(
                      s.isComparing(school.id)
                          ? Icons.compare_arrows
                          : Icons.compare_arrows_outlined,
                      color: s.isComparing(school.id)
                          ? color
                          : Colors.black26,
                    ),
                    onPressed: () {
                      final ok = s.toggleCompare(school.id);
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('最多对比 ${AppState.compareLimit} 所学校'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      s.isFavorite(school.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: s.isFavorite(school.id)
                          ? Colors.redAccent
                          : Colors.black38,
                    ),
                    onPressed: () => s.toggleFavorite(school.id),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                school.intro,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.black54, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _stat(Icons.thumb_up_alt_outlined, s.likeCount(school)),
                  const SizedBox(width: 18),
                  _stat(Icons.mode_comment_outlined, s.commentCount(school.id)),
                  const Spacer(),
                  if (school.tags.isNotEmpty)
                    Flexible(
                      child: Text(
                        school.tags.take(3).map((t) => '#$t').join(' '),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: color, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, int n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.black45),
        const SizedBox(width: 4),
        Text('$n', style: const TextStyle(color: Colors.black54, fontSize: 13)),
      ],
    );
  }
}

class _KeyBadge extends StatelessWidget {
  const _KeyBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.amber.shade400),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 13, color: Colors.amber.shade800),
          const SizedBox(width: 2),
          Text('重点',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.amber.shade900,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  final bool filled;
  const _Pill({required this.text, required this.color, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11.5, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
