import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/districts.dart';
import '../models/school.dart';

/// 学校地图定位：
/// - 内嵌 OpenStreetMap（无需 API Key）显示位置标记；
/// - 优先用学校精确坐标，否则回退到所在行政区中心（标注为"区域参考"）；
/// - 提供"用高德地图打开"按钮跳转外部地图进行精确搜索/导航。
class SchoolMap extends StatelessWidget {
  final School school;
  const SchoolMap({super.key, required this.school});

  bool get _exact => school.lat != null && school.lng != null;

  LatLng get _point {
    if (_exact) return LatLng(school.lat!, school.lng!);
    final c = districtCenter(school.district);
    return LatLng(c[0], c[1]);
  }

  Future<void> _openAmap() async {
    final kw = Uri.encodeComponent('${school.district}${school.name}');
    final uri = Uri.parse('https://uri.amap.com/search?keyword=$kw');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(districtColor(school.district));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 180,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _point,
                initialZoom: _exact ? 15 : 12.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.hzedu.hangzhou_edu',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _point,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: Icon(Icons.location_on,
                          color: color, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(_exact ? Icons.gps_fixed : Icons.info_outline,
                size: 14, color: Colors.black45),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _exact ? '已显示校区位置' : '当前为「${school.district}」区域参考位置，点右侧按钮精确搜索',
                style: const TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ),
            TextButton.icon(
              onPressed: _openAmap,
              icon: const Icon(Icons.navigation_outlined, size: 18),
              label: const Text('高德导航'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
