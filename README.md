# Culture Map - 历史文化地图导航应用

一个基于Flutter开发的历史文化遗产探索应用，具有完整的GPS导航功能。

## ✨ 核心功能

### 📍 地图探索
- 显示全球历史文化遗产地标
- 集成Wikidata数据源
- 从Wikipedia获取真实内容和图片
- 复古羊皮纸风格UI设计

### 🧭 完整导航系统
- **三种导航模式**：步行 🚶 / 骑行 🚴 / 驾车 🚗
- **实时GPS定位**：高精度跟踪，5米更新
- **真实路线规划**：使用OSRM API获取真实道路
- **转弯提示**：中文语音播报（向左转、向右转等）
- **地图自动旋转**：Heading-up模式，地图跟随朝向
- **语音导航**：全程中文TTS语音指引
- **屏幕常亮**：导航期间自动保持屏幕亮

### 🎨 UI设计
- 复古羊皮纸主题（"百年孤独"风格）
- Crimson Text字体（正文）
- Cinzel字体（标题）
- 勃艮第红 + 金色配色方案

### 💾 后端功能
- Supabase用户认证
- 书签收藏系统
- 评论系统
- 离线地图下载

## 🚀 快速开始

### 环境要求
- Flutter SDK >=3.0.0
- Android Studio / Xcode
- Android 设备（用于完整导航功能）

### 安装依赖
```bash
flutter pub get
```

### 运行应用
```bash
# Web预览（导航功能受限）
flutter run -d chrome

# Android手机（完整功能）
flutter run
```

### 编译APK
```bash
flutter build apk --release
```

## 📦 主要依赖

| 包名 | 用途 |
|-----|------|
| flutter_map | 地图显示 |
| geolocator | GPS定位 |
| flutter_tts | 语音播报 |
| wakelock_plus | 屏幕常亮 |
| supabase_flutter | 后端服务 |
| google_fonts | 字体支持 |
| http | API请求 |

## 📱 权限说明

应用需要以下权限：
- **位置** - GPS导航必需
- **后台位置** - 持续导航
- **网络** - 加载地图和数据
- **屏幕常亮** - 导航期间保持亮屏

## 🗺️ 导航功能详解

### 使用流程
1. 在地图上点击地标卡片
2. 点击"Navigate"按钮
3. 选择导航模式（步行/骑行/驾车）
4. 跟随地图和语音指示

### 功能特点
- ✅ 实时位置更新（每5米）
- ✅ 真实道路路线规划
- ✅ 中文转弯指示
- ✅ 提前50-100米语音提醒
- ✅ 到达50米内通知
- ✅ 预计到达时间计算
- ✅ 指南针方向指示

详细功能说明：[NAVIGATION_FEATURES.md](NAVIGATION_FEATURES.md)  
测试指南：[NAVIGATION_TEST_GUIDE.md](NAVIGATION_TEST_GUIDE.md)

## 📂 项目结构

```
lib/
├── main.dart                          # 主应用入口，地图页面
├── navigation_page.dart               # 导航页面（核心功能）
├── landmark_preview_card.dart         # 地标卡片组件
├── landmark_detail_page_new.dart      # 地标详情页
├── solitude_explorer_theme.dart       # 主题配置
└── ...

android/
└── app/src/main/AndroidManifest.xml   # Android权限配置
```

## 🔧 配置说明

### Supabase配置
在`lib/main.dart`中配置你的Supabase项目：
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
);
```

### 地图瓦片
默认使用OpenStreetMap：
```dart
urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
```

### 路线API
使用OSRM免费API：
```
https://router.project-osrm.org/route/v1/{profile}/...
```

## ⚠️ 重要说明

### Web浏览器限制
- ❌ 无法获取真实GPS位置
- ❌ 无法获取设备朝向
- ❌ 地图旋转功能无效

**结论：导航功能必须在Android/iOS设备上运行！**

### 手机要求
- ✅ 需要GPS硬件
- ✅ 需要指南针传感器
- ✅ 需要网络连接
- ✅ 建议在户外测试（GPS信号）

## 🐛 故障排除

### GPS无法定位
1. 确认GPS已开启
2. 到户外空旷地方
3. 检查应用位置权限

### 路线无法规划
1. 检查网络连接
2. 确认目的地不要太近（>100米）

### 语音不播报
1. 检查音量设置
2. 确认语音开关开启（右上角🔊）

## 📄 License

MIT License

## 👥 贡献

欢迎提交Issue和Pull Request！

## 📞 联系方式

如有问题或建议，请通过Issue反馈。

---

**享受你的文化探索之旅！** 🗺️✨
