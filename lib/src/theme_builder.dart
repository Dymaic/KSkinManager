import 'package:flutter/material.dart';
import 'color_scheme.dart';
import 'typography.dart';
import 'resource_manager.dart';
import 'theme_data.dart';

/// 主题构建器
///
/// 提供流畅的 API 用于构建自定义主题
class KThemeBuilder {
  String? _id;
  String? _name;
  String? _description;
  String? _version;
  String? _author;
  KColorScheme? _colorScheme;
  KTypography? _typography;
  KResourceManager? _resourceManager;
  bool? _isDark;
  Map<String, dynamic> _extensions = {};

  /// 获取当前是否为暗色主题
  bool get isDark => _isDark ?? false;

  /// 设置主题 ID
  KThemeBuilder id(String id) {
    _id = id;
    return this;
  }

  /// 设置主题名称
  KThemeBuilder name(String name) {
    _name = name;
    return this;
  }

  /// 设置主题描述
  KThemeBuilder description(String description) {
    _description = description;
    return this;
  }

  /// 设置主题版本
  KThemeBuilder version(String version) {
    _version = version;
    return this;
  }

  /// 设置主题作者
  KThemeBuilder author(String author) {
    _author = author;
    return this;
  }

  /// 设置颜色方案
  KThemeBuilder colorScheme(KColorScheme colorScheme) {
    _colorScheme = colorScheme;
    return this;
  }

  /// 设置排版样式
  KThemeBuilder typography(KTypography typography) {
    _typography = typography;
    return this;
  }

  /// 设置资源管理器
  KThemeBuilder resourceManager(KResourceManager resourceManager) {
    _resourceManager = resourceManager;
    return this;
  }

  /// 设置是否为暗色主题
  KThemeBuilder dark([bool isDark = true]) {
    final bool previousIsDark = _isDark ?? false;
    _isDark = isDark;

    if (_colorScheme != null) {
      // 检查是否实际改变了主题模式
      if (isDark != previousIsDark) {
        final currentScheme = _colorScheme!;
        final baseScheme = isDark ? KColorScheme.dark : KColorScheme.light;

        // 创建一个Map来跟踪哪些颜色已经被显式设置
        Map<String, Color> explicitColors = {};

        // 检查哪些颜色被显式设置了（不同于默认值）
        if (currentScheme.primary !=
            (previousIsDark
                ? KColorScheme.dark.primary
                : KColorScheme.light.primary)) {
          explicitColors['primary'] = currentScheme.primary;
        }

        if (currentScheme.secondary !=
            (previousIsDark
                ? KColorScheme.dark.secondary
                : KColorScheme.light.secondary)) {
          explicitColors['secondary'] = currentScheme.secondary;
        }

        if (currentScheme.surface !=
            (previousIsDark
                ? KColorScheme.dark.surface
                : KColorScheme.light.surface)) {
          explicitColors['surface'] = currentScheme.surface;
        }

        if (currentScheme.error !=
            (previousIsDark
                ? KColorScheme.dark.error
                : KColorScheme.light.error)) {
          explicitColors['error'] = currentScheme.error;
        }

        // 创建新的颜色方案基于请求的主题模式
        _colorScheme = baseScheme.copyWith(
          primary: explicitColors['primary'] ?? baseScheme.primary,
          secondary: explicitColors['secondary'] ?? baseScheme.secondary,
          surface: explicitColors['surface'] ?? baseScheme.surface,
          error: explicitColors['error'] ?? baseScheme.error,
        );

        // 保留自定义颜色
        if (currentScheme.customColors.isNotEmpty) {
          for (final entry in currentScheme.customColors.entries) {
            _colorScheme = _colorScheme!.withCustomColor(
              entry.key,
              entry.value,
            );
          }
        }
      }
    }

    return this;
  }

  /// 添加扩展配置
  KThemeBuilder extension(String key, dynamic value) {
    try {
      _extensions[key] = value;
    } catch (e) {
      // In case of any issues, ensure we have a fresh map
      _extensions = Map<String, dynamic>.from(_extensions);
      _extensions[key] = value;
    }
    return this;
  }

  /// 批量添加扩展配置
  KThemeBuilder extensions(Map<String, dynamic> extensions) {
    try {
      _extensions.addAll(extensions);
    } catch (e) {
      // In case of any issues, ensure we have a fresh map
      _extensions = Map<String, dynamic>.from(_extensions);
      _extensions.addAll(extensions);
    }
    return this;
  }

  /// 从现有主题开始构建
  KThemeBuilder fromTheme(KThemeData theme) {
    _id = theme.id;
    _name = theme.name;
    _description = theme.description;
    _version = theme.version;
    _author = theme.author;
    _colorScheme = theme.colorScheme;
    _typography = theme.typography;
    _resourceManager = theme.resourceManager;
    _isDark = theme.isDark;
    _extensions = Map.from(theme.extensions);
    return this;
  }

  /// 从 JSON 构建
  KThemeBuilder fromJson(Map<String, dynamic> json) {
    if (json.containsKey('id')) _id = json['id'];
    if (json.containsKey('name')) _name = json['name'];
    if (json.containsKey('description')) _description = json['description'];
    if (json.containsKey('version')) _version = json['version'];
    if (json.containsKey('author')) _author = json['author'];
    if (json.containsKey('isDark')) _isDark = json['isDark'];

    if (json.containsKey('colorScheme')) {
      _colorScheme = KColorScheme.fromJson(json['colorScheme']);
    }

    if (json.containsKey('typography')) {
      _typography = KTypography.fromJson(json['typography']);
    }

    if (json.containsKey('resourceManager')) {
      _resourceManager = KResourceManager.fromJson(json['resourceManager']);
    }

    if (json.containsKey('extensions')) {
      _extensions = Map<String, dynamic>.from(json['extensions'] ?? {});
    }

    return this;
  }

  /// 构建主题数据
  KThemeData build() {
    final isDark = _isDark ?? false;

    // 初始化颜色方案
    final colorScheme =
        _colorScheme ?? (isDark ? KColorScheme.dark : KColorScheme.light);

    final theme = KThemeData(
      id: _id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name ?? 'Custom Theme',
      description: _description,
      version: _version ?? '1.0.0',
      author: _author,
      colorScheme: colorScheme,
      typography: _typography ?? KTypography.defaultTypography,
      resourceManager: _resourceManager ?? KResourceManager(),
      isDark: isDark,
      extensions: _extensions,
    );

    return theme;
  }

  /// 重置构建器状态
  KThemeBuilder reset() {
    _id = null;
    _name = null;
    _description = null;
    _version = null;
    _author = null;
    _colorScheme = null;
    _typography = null;
    _resourceManager = null;
    _isDark = null;
    _extensions = {};
    return this;
  }

  /// 设置主色
  KThemeBuilder primaryColor(Color color) {
    _ensureColorScheme();
    _colorScheme = _colorScheme!.copyWith(primary: color);
    return this;
  }

  /// 设置次色
  KThemeBuilder secondaryColor(Color color) {
    _ensureColorScheme();
    _colorScheme = _colorScheme!.copyWith(secondary: color);
    return this;
  }

  /// 设置表面颜色
  KThemeBuilder surfaceColor(Color color) {
    _ensureColorScheme();
    _colorScheme = _colorScheme!.copyWith(surface: color);
    return this;
  }

  /// 设置背景颜色
  KThemeBuilder backgroundColor(Color color) {
    _ensureColorScheme();
    _colorScheme = _colorScheme!.copyWith(surface: color);
    return this;
  }

  /// 设置错误颜色
  KThemeBuilder errorColor(Color color) {
    _ensureColorScheme();
    _colorScheme = _colorScheme!.copyWith(error: color);
    return this;
  }

  /// 添加自定义颜色
  KThemeBuilder customColor(String name, Color color) {
    _ensureColorScheme();
    _colorScheme = _colorScheme!.withCustomColor(name, color);
    return this;
  }

  /// 确保颜色方案已初始化
  void _ensureColorScheme() {
    if (_colorScheme == null) {
      _colorScheme = _isDark ?? false ? KColorScheme.dark : KColorScheme.light;
    }
  }

  /// 设置字体样式
  KThemeBuilder fontStyle(String name, TextStyle style) {
    if (_typography == null) {
      _typography = KTypography.defaultTypography;
    }

    final Map<String, TextStyle> newCustomStyles = Map.from(
      _typography!.customStyles,
    );
    newCustomStyles[name] = style;

    _typography = _typography!.copyWith(customStyles: newCustomStyles);
    return this;
  }
}

/// 快捷主题构建器
class KQuickThemeBuilder {
  /// 创建预设主题
  static KThemeBuilder preset(String presetName) {
    final builder = KThemeBuilder();

    switch (presetName.toLowerCase()) {
      case 'ocean':
        return builder
            .name('Ocean Theme')
            .primaryColor(Colors.blue.shade700)
            .secondaryColor(Colors.cyan.shade400)
            .customColor('accent', Colors.teal.shade300);

      case 'forest':
        return builder
            .name('Forest Theme')
            .primaryColor(Colors.green.shade800)
            .secondaryColor(Colors.lightGreen.shade600)
            .customColor('accent', Colors.amber.shade400);

      case 'sunset':
        return builder
            .name('Sunset Theme')
            .primaryColor(Colors.orange.shade700)
            .secondaryColor(Colors.pink.shade400)
            .customColor('accent', Colors.yellow.shade300);

      case 'midnight':
        return builder
            .name('Midnight Theme')
            .dark(true)
            .primaryColor(Colors.indigo.shade400)
            .secondaryColor(Colors.purple.shade300)
            .customColor('accent', Colors.cyan.shade200);

      case 'minimal':
        return builder
            .name('Minimal Theme')
            .primaryColor(Colors.grey.shade800)
            .secondaryColor(Colors.grey.shade600)
            .customColor('accent', Colors.blue.shade400);

      default:
        return builder.name('Default Theme');
    }
  }

  /// 创建亮色主题
  static KThemeBuilder light({
    String name = 'Light Theme',
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    return KThemeBuilder()
        .name(name)
        .dark(false)
        .colorScheme(KColorScheme.light)
        .primaryColor(primaryColor ?? Colors.blue)
        .secondaryColor(secondaryColor ?? Colors.blueAccent);
  }

  /// 创建暗色主题
  static KThemeBuilder dark({
    String name = 'Dark Theme',
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    return KThemeBuilder()
        .name(name)
        .dark(true)
        .colorScheme(KColorScheme.dark)
        .primaryColor(primaryColor ?? Colors.blue.shade300)
        .secondaryColor(secondaryColor ?? Colors.blueAccent.shade100);
  }

  /// 创建带渐变的主题
  static KThemeBuilder gradient({
    required String name,
    required KColorScheme colorScheme,
    Color? primaryColor,
    Color? secondaryColor,
  }) {
    return KThemeBuilder()
        .name(name)
        .colorScheme(colorScheme)
        .primaryColor(primaryColor ?? colorScheme.primary)
        .secondaryColor(secondaryColor ?? colorScheme.secondary);
  }

  /// 从颜色创建主题
  static KThemeBuilder fromColors({
    required String name,
    required Color primaryColor,
    required Color secondaryColor,
    bool isDark = false,
  }) {
    return KThemeBuilder()
        .name(name)
        .dark(isDark)
        .primaryColor(primaryColor)
        .secondaryColor(secondaryColor);
  }
}
