import 'dart:ui';

/// K皮肤库的颜色方案类，支持无限扩展的颜色定义
///
/// 除了基础的 Flutter 颜色，用户可以通过 [customColors]
/// 定义任意数量的自定义颜色，实现高度可扩展的颜色系统
class KColorScheme {
  /// 基础颜色 - 对应 Flutter 的 ColorScheme.primary
  final Color primary;

  /// 主色变体 - 对应 Flutter 的 ColorScheme.primaryContainer
  final Color primaryContainer;

  /// 次要颜色 - 对应 Flutter 的 ColorScheme.secondary
  final Color secondary;

  /// 次要颜色容器 - 对应 Flutter 的 ColorScheme.secondaryContainer
  final Color secondaryContainer;

  /// 背景色 - 对应 Flutter 的 ColorScheme.surface
  final Color surface;

  /// 错误颜色 - 对应 Flutter 的 ColorScheme.error
  final Color error;

  /// 主要文本颜色 - 对应 Flutter 的 ColorScheme.onSurface
  final Color onSurface;

  /// 在主色上显示的文本颜色 - 对应 Flutter 的 ColorScheme.onPrimary
  final Color onPrimary;

  /// 在次要色上显示的文本颜色 - 对应 Flutter 的 ColorScheme.onSecondary
  final Color onSecondary;

  /// 在错误色上显示的文本颜色 - 对应 Flutter 的 ColorScheme.onError
  final Color onError;

  /// 自定义颜色映射 - 支持用户定义的无限颜色
  ///
  /// 通过这个 Map，用户可以定义任意数量的自定义颜色，例如：
  /// ```dart
  /// customColors: {
  ///   'brand': Color(0xFF123456),
  ///   'accent': Color(0xFF654321),
  ///   'warning': Color(0xFFFFAA00),
  ///   'success': Color(0xFF00AA00),
  ///   // ... 更多自定义颜色
  /// }
  /// ```
  final Map<String, Color> customColors;

  const KColorScheme({
    required this.primary,
    required this.primaryContainer,
    required this.secondary,
    required this.secondaryContainer,
    required this.surface,
    required this.error,
    required this.onSurface,
    required this.onPrimary,
    required this.onSecondary,
    required this.onError,
    this.customColors = const {},
  });

  /// 从 JSON 数据创建 KColorScheme 实例
  ///
  /// JSON 格式示例：
  /// ```json
  /// {
  ///   "primary": "#FF5722",
  ///   "primaryContainer": "#FFCCBC",
  ///   "secondary": "#2196F3",
  ///   "secondaryContainer": "#BBDEFB",
  ///   "surface": "#FFFFFF",
  ///   "error": "#F44336",
  ///   "onSurface": "#000000",
  ///   "onPrimary": "#FFFFFF",
  ///   "onSecondary": "#FFFFFF",
  ///   "onError": "#FFFFFF",
  ///   "customColors": {
  ///     "brand": "#123456",
  ///     "accent": "#654321",
  ///     "warning": "#FFAA00"
  ///   }
  /// }
  /// ```
  factory KColorScheme.fromJson(Map<String, dynamic> json) {
    return KColorScheme(
      primary: _parseColor(json['primary']),
      primaryContainer: _parseColor(json['primaryContainer']),
      secondary: _parseColor(json['secondary']),
      secondaryContainer: _parseColor(json['secondaryContainer']),
      surface: _parseColor(json['surface']),
      error: _parseColor(json['error']),
      onSurface: _parseColor(json['onSurface']),
      onPrimary: _parseColor(json['onPrimary']),
      onSecondary: _parseColor(json['onSecondary']),
      onError: _parseColor(json['onError']),
      customColors: _parseCustomColors(json['customColors']),
    );
  }

  /// 将 KColorScheme 转换为 JSON 数据
  Map<String, dynamic> toJson() {
    return {
      'primary': _colorToHex(primary),
      'primaryContainer': _colorToHex(primaryContainer),
      'secondary': _colorToHex(secondary),
      'secondaryContainer': _colorToHex(secondaryContainer),
      'surface': _colorToHex(surface),
      'error': _colorToHex(error),
      'onSurface': _colorToHex(onSurface),
      'onPrimary': _colorToHex(onPrimary),
      'onSecondary': _colorToHex(onSecondary),
      'onError': _colorToHex(onError),
      'customColors': customColors.map(
        (key, color) => MapEntry(key, _colorToHex(color)),
      ),
    };
  }

  /// 获取自定义颜色
  ///
  /// 通过键名获取自定义颜色，如果不存在则返回 null
  ///
  /// ```dart
  /// final brandColor = colorScheme.getCustomColor('brand');
  /// final accentColor = colorScheme.getCustomColor('accent');
  /// ```
  Color? getCustomColor(String key) {
    return customColors[key];
  }

  /// 获取自定义颜色，如果不存在则返回默认颜色
  ///
  /// ```dart
  /// final brandColor = colorScheme.getCustomColorOrDefault('brand', Colors.blue);
  /// ```
  Color getCustomColorOrDefault(String key, Color defaultColor) {
    return customColors[key] ?? defaultColor;
  }

  /// 复制当前颜色方案并允许修改部分属性
  KColorScheme copyWith({
    Color? primary,
    Color? primaryContainer,
    Color? secondary,
    Color? secondaryContainer,
    Color? surface,
    Color? error,
    Color? onSurface,
    Color? onPrimary,
    Color? onSecondary,
    Color? onError,
    Map<String, Color>? customColors,
  }) {
    return KColorScheme(
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      secondary: secondary ?? this.secondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      surface: surface ?? this.surface,
      error: error ?? this.error,
      onSurface: onSurface ?? this.onSurface,
      onPrimary: onPrimary ?? this.onPrimary,
      onSecondary: onSecondary ?? this.onSecondary,
      onError: onError ?? this.onError,
      customColors: customColors ?? this.customColors,
    );
  }

  /// 添加或更新自定义颜色
  KColorScheme withCustomColor(String key, Color color) {
    final newCustomColors = Map<String, Color>.from(customColors);
    newCustomColors[key] = color;
    return copyWith(customColors: newCustomColors);
  }

  /// 移除自定义颜色
  KColorScheme withoutCustomColor(String key) {
    final newCustomColors = Map<String, Color>.from(customColors);
    newCustomColors.remove(key);
    return copyWith(customColors: newCustomColors);
  }

  /// 默认的亮色主题颜色方案
  static const light = KColorScheme(
    primary: Color(0xFF6200EE),
    primaryContainer: Color(0xFFBB86FC),
    secondary: Color(0xFF03DAC6),
    secondaryContainer: Color(0xFF018786),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFB00020),
    onSurface: Color(0xFF000000),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF000000),
    onError: Color(0xFFFFFFFF),
  );

  /// 默认的暗色主题颜色方案
  static const dark = KColorScheme(
    primary: Color(0xFFBB86FC),
    primaryContainer: Color(0xFF3700B3),
    secondary: Color(0xFF03DAC6),
    secondaryContainer: Color(0xFF018786),
    surface: Color(0xFF121212),
    error: Color(0xFFCF6679),
    onSurface: Color(0xFFFFFFFF),
    onPrimary: Color(0xFF000000),
    onSecondary: Color(0xFF000000),
    onError: Color(0xFF000000),
  );

  // 私有辅助方法

  /// 解析颜色字符串为 Color 对象
  static Color _parseColor(dynamic colorValue) {
    if (colorValue is String) {
      // 移除 # 前缀并解析十六进制颜色
      final hex = colorValue.replaceFirst('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }
    throw ArgumentError('Invalid color format: $colorValue');
  }

  /// 解析自定义颜色映射
  static Map<String, Color> _parseCustomColors(dynamic customColorsValue) {
    if (customColorsValue is Map<String, dynamic>) {
      return customColorsValue.map(
        (key, value) => MapEntry(key, _parseColor(value)),
      );
    }
    return {};
  }

  /// 将 Color 转换为十六进制字符串
  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! KColorScheme) return false;

    return primary == other.primary &&
        primaryContainer == other.primaryContainer &&
        secondary == other.secondary &&
        secondaryContainer == other.secondaryContainer &&
        surface == other.surface &&
        error == other.error &&
        onSurface == other.onSurface &&
        onPrimary == other.onPrimary &&
        onSecondary == other.onSecondary &&
        onError == other.onError &&
        _mapEquals(customColors, other.customColors);
  }

  @override
  int get hashCode {
    return Object.hash(
      primary,
      primaryContainer,
      secondary,
      secondaryContainer,
      surface,
      error,
      onSurface,
      onPrimary,
      onSecondary,
      onError,
      Object.hashAll(
        customColors.entries.map((e) => Object.hash(e.key, e.value)),
      ),
    );
  }

  /// 比较两个 Map 是否相等
  static bool _mapEquals<K, V>(Map<K, V> map1, Map<K, V> map2) {
    if (map1.length != map2.length) return false;
    for (final entry in map1.entries) {
      if (map2[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'KColorScheme('
        'primary: $primary, '
        'primaryContainer: $primaryContainer, '
        'secondary: $secondary, '
        'secondaryContainer: $secondaryContainer, '
        'surface: $surface, '
        'error: $error, '
        'onSurface: $onSurface, '
        'onPrimary: $onPrimary, '
        'onSecondary: $onSecondary, '
        'onError: $onError, '
        'customColors: $customColors)';
  }
}
