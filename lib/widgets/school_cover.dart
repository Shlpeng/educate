import 'package:flutter/material.dart';
import '../data/districts.dart';
import '../models/school.dart';

/// 学校封面图：
/// - 若 [School.imageUrl] 有值则加载网络图片；
/// - 加载中显示占位、失败或为空时回退到"按区配色的渐变封面"（含学段 emoji 水印）。
class SchoolCover extends StatelessWidget {
  final School school;
  final double height;
  final BorderRadius? radius;
  final bool showLabel; // 是否在封面上叠加校名

  const SchoolCover({
    super.key,
    required this.school,
    this.height = 160,
    this.radius,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = radius ?? BorderRadius.circular(12);
    return ClipRRect(
      borderRadius: r,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (school.imageUrl != null)
              Image.network(
                school.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, progress) =>
                    progress == null ? child : _gradient(),
                errorBuilder: (ctx, error, stack) => _gradient(),
              )
            else
              _gradient(),
            if (showLabel)
              Positioned(
                left: 12,
                bottom: 10,
                right: 12,
                child: Text(
                  school.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black54)],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _gradient() {
    final base = Color(districtColor(school.district));
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base, Color.lerp(base, Colors.black, 0.35)!],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -18,
            child: Text(
              school.stage.emoji,
              style: const TextStyle(fontSize: 110, color: Colors.white24),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${school.district} · ${school.stage.label}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
