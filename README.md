# K Skin - Flutter 主题皮肤管理库

一个强大的 Flutter 主题管理库，提供可扩展的皮肤系统、动态资源管理和网络皮肤包支持。

[![pub package](https://img.shields.io/pub/v/k_skin.svg)](https://pub.dev/packages/k_skin)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## ✨ 特性

- 🎨 **可扩展颜色系统** - 支持自定义颜色和 Material Design 3
- 📚 **动态资源管理** - 统一管理图像、字体、图标资源
- 🌐 **网络皮肤下载** - 支持从网络下载和安装皮肤包
- 🔄 **实时主题切换** - 无缝的主题切换体验
- 🏗️ **流畅构建 API** - 简洁的链式 API 构建自定义主题
- 📱 **Material Design 3** - 完全支持 Material 3 设计规范
- 🧪 **完整测试覆盖** - 所有核心功能的单元测试

## 📦 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  k_skin: ^0.0.1
```

然后运行：

```bash
flutter pub get
```

## 🚀 快速开始

### 1. 基础设置

```dart
import 'package:k_skin/k_skin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化主题管理器
  await KThemeManager.instance.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KThemeProvider(
      child: MaterialApp(
        title: 'K Skin Demo',
        theme: KThemeManager.instance.currentTheme.toFlutterThemeData(),
        home: MyHomePage(),
      ),
    );
  }
}
```

### 2. 创建自定义主题

```dart
// 使用主题构建器
final customTheme = KThemeBuilder()
  .id('ocean_blue')
  .name('Ocean Blue')
  .version('1.0.0')
  .primaryColor(Colors.blue)
  .secondaryColor(Colors.cyan)
  .customColor('accent', Colors.teal)
  .extension('borderRadius', 16.0)
  .build();

// 应用主题
await KThemeManager.instance.applyTheme(customTheme);
```

### 3. 快速主题模板

```dart
// Material 3 主题
final material3Theme = QuickThemeBuilder.material3(
  seedColor: Colors.purple,
  isDark: false,
).build();

// 预设模板主题
final oceanTheme = QuickThemeBuilder.fromTemplate('ocean').build();
final forestTheme = QuickThemeBuilder.fromTemplate('forest').build();
```

### 4. 主题切换组件

```dart
class ThemeSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 主题切换器
        KThemeSwitcher(),
        
        SizedBox(height: 20),
        
        // 主题网格选择器
        KThemeGridSelector(
          crossAxisCount: 2,
          onThemeSelected: (theme) {
            print('Selected theme: ${theme.name}');
          },
        ),
      ],
    );
  }
}
```

## 📖 详细用法

### 颜色系统

K Skin 提供了强大的颜色系统，支持自定义颜色和 Material Design 3：

```dart
// 创建自定义颜色方案
final colorScheme = KColorScheme(
  primary: Color(0xFF6200EE),
  secondary: Color(0xFF03DAC6),
  surface: Color(0xFFFFFFFF),
  error: Color(0xFFB00020),
  // 标准颜色...
  customColors: {
    'brand': Color(0xFF123456),
    'accent': Color(0xFF654321),
  },
);

// 从 JSON 创建
final colorScheme = KColorScheme.fromJson({
  'primary': '#6200EE',
  'secondary': '#03DAC6',
  'customColors': {
    'brand': '#123456',
  },
});

// 添加自定义颜色
final updated = colorScheme.withCustomColor('highlight', Colors.amber);
```

### 排版系统

自定义字体样式和排版规则：

```dart
final typography = KTypography(
  displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
  customStyles: {
    'appBarTitle': TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  },
);

// 使用自定义样式
Text(
  'App Bar Title',
  style: typography.getCustomStyle('appBarTitle'),
)
```

### 资源管理

统一管理应用资源：

```dart
final resourceManager = KResourceManager(
  images: {'logo': 'assets/images/logo.png'},
  fonts: {'title': 'CustomFont'},
  icons: {'home': Icons.home},
);

// 获取资源
final logoPath = resourceManager.getImagePath('logo');
final titleFont = resourceManager.getFontFamily('title');
final homeIcon = resourceManager.getIcon('home');
```

### 皮肤包管理

下载和管理网络皮肤包：

```dart
// 初始化皮肤管理器
await KSkinManager.instance.initialize();

// 下载皮肤包
await KSkinManager.instance.downloadSkin(
  'https://example.com/themes/ocean_theme.zip',
  onProgress: (received, total) {
    print('Progress: ${(received / total * 100).toStringAsFixed(1)}%');
  },
);

// 获取已安装的皮肤
final installedSkins = KSkinManager.instance.installedSkins;

// 应用皮肤
await KSkinManager.instance.applySkin(installedSkins.first);
```

### 主题扩展

添加自定义配置：

```dart
final theme = KThemeData(
  // 基础配置...
  extensions: {
    'borderRadius': 12.0,
    'cardElevation': 4.0,
    'animationDuration': 300,
    'customConfig': {
      'enableAnimations': true,
      'showShadows': false,
    },
  },
);

// 获取扩展配置
final borderRadius = theme.getExtension<double>('borderRadius', 8.0);
final config = theme.getExtension<Map>('customConfig', {});
```

## 🎨 主题模板

K Skin 提供了多个内置主题模板：

```dart
// Ocean 主题 - 海洋蓝色调
final oceanTheme = QuickThemeBuilder.fromTemplate('ocean').build();

// Forest 主题 - 森林绿色调
final forestTheme = QuickThemeBuilder.fromTemplate('forest').build();

// Sunset 主题 - 日落橙色调
final sunsetTheme = QuickThemeBuilder.fromTemplate('sunset').build();

// Night 主题 - 夜间深色调
final nightTheme = QuickThemeBuilder.fromTemplate('night').build();
```

## 📱 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:k_skin/k_skin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KThemeManager.instance.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KThemeProvider(
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'K Skin Demo',
            theme: KThemeProvider.of(context).toFlutterThemeData(),
            home: MyHomePage(),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = KThemeProvider.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('K Skin Demo'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 主题信息卡片
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前主题: ${theme.name}',
                      style: theme.typography.headlineSmall,
                    ),
                    Text(
                      '版本: ${theme.version}',
                      style: theme.typography.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // 主题切换器
            KThemeSwitcher(),
            
            SizedBox(height: 20),
            
            // 颜色展示
            Wrap(
              spacing: 8,
              children: [
                _ColorChip('Primary', theme.colorScheme.primary),
                _ColorChip('Secondary', theme.colorScheme.secondary),
                _ColorChip('Surface', theme.colorScheme.surface),
              ],
            ),
            
            SizedBox(height: 20),
            
            // 快速创建主题按钮
            ElevatedButton(
              onPressed: () => _createCustomTheme(),
              child: Text('创建自定义主题'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _ColorChip(String label, Color color) {
    return Chip(
      label: Text(label),
      backgroundColor: color,
      labelStyle: TextStyle(
        color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
      ),
    );
  }
  
  void _createCustomTheme() async {
    final customTheme = KThemeBuilder()
      .id('my_custom_theme')
      .name('My Custom Theme')
      .version('1.0.0')
      .primaryColor(Colors.deepPurple)
      .secondaryColor(Colors.amber)
      .customColor('accent', Colors.pink)
      .extension('borderRadius', 20.0)
      .build();
    
    await KThemeManager.instance.applyTheme(customTheme);
  }
}
```

## 💡 最佳实践

### 创建暗色主题

为避免暗色主题中出现黑屏问题，请遵循以下最佳实践：

1. **正确的方法调用顺序** - 创建暗色主题时，先调用 `.dark()` 方法设置主题类型，再设置颜色：

```dart
// ✅ 正确方式
final darkTheme = KThemeBuilder()
  .id('my_dark_theme')
  .name('My Dark Theme')
  .dark(true) // 先设置为暗色主题
  .primaryColor(Colors.indigo) // 然后设置颜色
  .secondaryColor(Colors.teal)
  .build();

// ❌ 错误方式 - 可能导致黑屏问题
final darkTheme = KThemeBuilder()
  .id('my_dark_theme')
  .name('My Dark Theme')
  .primaryColor(Colors.indigo) // 先设置颜色 - 基于亮色方案
  .secondaryColor(Colors.teal)
  .dark(true) // 后设置为暗色主题 - 但颜色已基于亮色方案设置
  .build();
```

2. **使用自动修复** - 从 v0.0.2 开始，`KThemeManager` 会自动检测和修复暗色主题中可能导致黑屏的问题。如需手动验证主题，可使用：

```dart
// 验证主题
KSkinFixes.validateTheme(myTheme);

// 修复暗色主题
final fixedTheme = KSkinFixes.fixDarkTheme(myTheme);
```

3. **避免纯黑表面色** - 暗色主题中避免使用纯黑色作为表面色，这可能导致可读性问题：

```dart
// ✅ 推荐 - 使用深灰色而非纯黑
final darkTheme = KThemeBuilder()
  .dark(true)
  .surfaceColor(Color(0xFF121212)) // Material Dark 推荐的表面色
  .build();

// ❌ 不推荐 - 纯黑可能导致可读性问题
final darkTheme = KThemeBuilder()
  .dark(true)
  .surfaceColor(Colors.black)
  .build();
```

4. **检查对比度** - 确保文字和背景之间有足够的对比度，特别是在暗色主题中：

```dart
// 计算对比度
final background = theme.colorScheme.surface;
final text = theme.colorScheme.onSurface;
final backgroundLuminance = background.computeLuminance();
final textLuminance = text.computeLuminance();
final contrast = (backgroundLuminance + 0.05) / (textLuminance + 0.05);

// WCAG AA 标准要求至少 4.5:1 的对比度
final isAccessible = contrast >= 4.5;
```

## 📋 API 参考

### 核心类

- `KThemeManager` - 主题管理器，负责主题的加载、切换和持久化
- `KThemeProvider` - 主题提供者 Widget，为子组件提供主题数据
- `KThemeData` - 主题数据类，包含完整的主题信息
- `KColorScheme` - 颜色方案，管理应用的颜色系统
- `KTypography` - 排版系统，管理文本样式
- `KResourceManager` - 资源管理器，统一管理应用资源

### 构建器

- `KThemeBuilder` - 通用主题构建器，提供链式 API
- `QuickThemeBuilder` - 快速主题构建器，提供预设模板

### 组件

- `KThemeSwitcher` - 主题切换下拉选择器
- `KThemeGridSelector` - 主题网格选择器

### 皮肤管理

- `KSkinManager` - 皮肤包管理器
- `SkinPackage` - 皮肤包数据类
- `SkinDownloader` - 网络皮肤下载器

## 🤝 贡献

欢迎贡献代码！请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何参与项目开发。

## 📄 许可证

本项目基于 MIT 许可证开源。详情请查看 [LICENSE](LICENSE) 文件。

## 📞 支持

如果您在使用过程中遇到问题或有建议，请：

- 查看 [文档](https://github.com/yourusername/k_skin/wiki)
- 阅读 [暗色主题黑屏问题修复指南](docs/dark_theme_fix_guide.md)
- 提交 [Issue](https://github.com/yourusername/k_skin/issues)
- 发起 [讨论](https://github.com/yourusername/k_skin/discussions)

## 🏆 致谢

感谢所有贡献者和使用者对 K Skin 的支持！
