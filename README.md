# 杭州教育 (Hangzhou Edu)

一个专注杭州教育的 Flutter App：按行政区、按学段浏览学校，标注重点学校，支持简介、评论、点赞、收藏分组、学校对比、地图定位与按区中考升学数据。

## 功能

- **行政区切换**：左上角切换地区，上城 / 拱墅 / 西湖 / 滨江 / 萧山 / 余杭 / 临平 / 钱塘 / 富阳 / 临安，每个区有专属配色。
- **学段筛选**：幼儿园 / 小学 / 初中 / 高中 / 大学，「全部」时按学段分组展示。
- **重点学校标注**：⭐ 重点徽章，支持「只看重点」。
- **学校详情**：封面图、简介、标签、地址。部分学校接入真实校园照片（维基百科图库），其余使用按区配色的渐变封面。
- **互动**：点赞、评论（增删，本地持久化）。
- **收藏分组**：收藏后可分组管理（想去 / 保底 / 再看看 / 自定义分组）。
- **学校对比**：最多选 4 所学校并排逐项对比。
- **地图定位**：内嵌 OpenStreetMap 显示位置，一键跳转高德地图导航。
- **按区中考升学数据**：杭州市区为统一招生口径（含 2024 真实数据，来源市教育局），独立招生区如实标注。

> 说明：中考数据中「市区统一招生」遵循 2024 官方口径；缺乏经核实公开数据的独立区标注「暂无公开数据」，数值请以官方公告为准。学校简介为概要信息，招生政策以官方为准。

## 技术栈

- Flutter (Material 3)
- `provider` 状态管理
- `shared_preferences` 本地持久化（点赞 / 评论 / 收藏分组）
- `flutter_map` + `latlong2` 地图
- `url_launcher` 外部地图跳转
- `flutter_launcher_icons` 应用图标

## 运行

```bash
flutter pub get
flutter run -d chrome       # 浏览器
flutter run -d macos        # macOS 桌面
flutter build apk --release # 安卓 APK
```

## 目录结构

```
lib/
├── main.dart                       # 入口 + 主题
├── models/school.dart              # School / Comment / Stage 模型
├── data/
│   ├── districts.dart              # 行政区 + 配色 + 坐标
│   ├── district_stats.dart         # 按区中考升学数据
│   └── schools.dart                # 学校数据库
├── state/app_state.dart            # 全局状态 + 持久化
├── screens/                        # 首页 / 详情 / 收藏 / 对比
└── widgets/                        # 卡片 / 封面 / 地图
```
