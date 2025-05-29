import 'package:flutter/material.dart';
import 'color_scheme.dart';
import 'typography.dart';
import 'resource_manager.dart';

/// K皮肤库的主题数据类，整合颜色、排版和资源管理
///
/// 这是K皮肤库的核心主题数据结构，整合了所有的主题组件，
/// 并提供与 Flutter ThemeData 的无缝集成
class KThemeData {
  /// 主题标识符 - 用于区分不同的主题
  final String id;

  /// 主题名称 - 用于显示的友好名称
  final String name;

  /// 主题描述
  final String? description;

  /// 主题版本
  final String version;

  /// 主题作者
  final String? author;

  /// 颜色方案
  final KColorScheme colorScheme;

  /// 排版系统
  final KTypography typography;

  /// 资源管理器
  final KResourceManager resourceManager;

  /// 是否为暗色主题
  final bool isDark;

  /// 主题的额外配置数据
  ///
  /// 用户可以在这里存储任意的主题配置数据，例如：
  /// ```dart
  /// extensions: {
  ///   'borderRadius': 8.0,
  ///   'shadowElevation': 4.0,
  ///   'animationDuration': 200,
  ///   'customConfig': {
  ///     'feature1': true,
  ///     'feature2': 'value'
  ///   }
  /// }
  /// ```
  final Map<String, dynamic> extensions;

  const KThemeData({
    required this.id,
    required this.name,
    this.description,
    required this.version,
    this.author,
    required this.colorScheme,
    required this.typography,
    required this.resourceManager,
    this.isDark = false,
    this.extensions = const {},
  });

  /// 从 JSON 数据创建 KThemeData 实例
  ///
  /// JSON 格式示例：
  /// ```json
  /// {
  ///   "id": "modern_blue",
  ///   "name": "Modern Blue",
  ///   "description": "A modern blue theme",
  ///   "version": "1.0.0",
  ///   "author": "Theme Author",
  ///   "isDark": false,
  ///   "colorScheme": { ... },
  ///   "typography": { ... },
  ///   "resourceManager": { ... },
  ///   "extensions": {
  ///     "borderRadius": 8.0,
  ///     "shadowElevation": 4.0
  ///   }
  /// }
  /// ```
  factory KThemeData.fromJson(
    Map<String, dynamic> json, {
    String? skinBasePath,
  }) {
    return KThemeData(
      id: json['id'] ?? 'unknown',
      name: json['name'] ?? 'Unknown Theme',
      description: json['description'],
      version: json['version'] ?? '1.0.0',
      author: json['author'],
      colorScheme: KColorScheme.fromJson(json['colorScheme'] ?? {}),
      typography: KTypography.fromJson(json['typography'] ?? {}),
      resourceManager: KResourceManager.fromJson(
        json['resourceManager'] ?? {},
        skinBasePath: skinBasePath,
      ),
      isDark: json['isDark'] ?? false,
      extensions: Map<String, dynamic>.from(json['extensions'] ?? {}),
    );
  }

  /// 将 KThemeData 转换为 JSON 数据
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'version': version,
      if (author != null) 'author': author,
      'colorScheme': colorScheme.toJson(),
      'typography': typography.toJson(),
      'resourceManager': resourceManager.toJson(),
      'isDark': isDark,
      'extensions': extensions,
    };
  }

  /// 转换为 Flutter 的 ThemeData
  ///
  /// 将K皮肤主题数据转换为 Flutter 标准的 ThemeData，
  /// 实现与 Flutter 主题系统的无缝集成
  ThemeData toFlutterThemeData() {
    // 获取合适的亮度
    final themeBrightness = isDark ? Brightness.dark : Brightness.light;

    // 创建 Flutter ColorScheme
    final flutterColorScheme = ColorScheme(
      brightness: themeBrightness,
      primary: colorScheme.primary,
      onPrimary: colorScheme.onPrimary,
      primaryContainer: colorScheme.primaryContainer,
      onPrimaryContainer: colorScheme.onPrimary,
      secondary: colorScheme.secondary,
      onSecondary: colorScheme.onSecondary,
      secondaryContainer: colorScheme.secondaryContainer,
      onSecondaryContainer: colorScheme.onSecondary,
      tertiary: colorScheme.secondary,
      onTertiary: colorScheme.onSecondary,
      tertiaryContainer: colorScheme.secondaryContainer,
      onTertiaryContainer: colorScheme.onSecondary,
      error: colorScheme.error,
      onError: colorScheme.onError,
      errorContainer: colorScheme.error,
      onErrorContainer: colorScheme.onError,
      outline: colorScheme.onSurface.withOpacity(0.12),
      outlineVariant: colorScheme.onSurface.withOpacity(0.06),
      surface: colorScheme.surface,
      onSurface: colorScheme.onSurface,
      surfaceContainerHighest: colorScheme.surface,
      onSurfaceVariant: colorScheme.onSurface,
      inverseSurface: colorScheme.onSurface,
      onInverseSurface: colorScheme.surface,
      inversePrimary: colorScheme.primaryContainer,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
      surfaceTint: colorScheme.primary,
    );

    // 创建 Flutter TextTheme
    final flutterTextTheme = TextTheme(
      displayLarge: typography.displayLarge,
      displayMedium: typography.displayMedium,
      displaySmall: typography.displaySmall,
      headlineLarge: typography.headlineLarge,
      headlineMedium: typography.headlineMedium,
      headlineSmall: typography.headlineSmall,
      bodyLarge: typography.bodyLarge,
      bodyMedium: typography.bodyMedium,
      bodySmall: typography.bodySmall,
      labelLarge: typography.labelLarge,
      labelMedium: typography.labelMedium,
      labelSmall: typography.labelSmall,
      titleLarge: typography.headlineMedium,
      titleMedium: typography.headlineSmall,
      titleSmall: typography.bodyLarge,
    );

    // 创建主题数据
    return ThemeData(
      useMaterial3: true,
      colorScheme: flutterColorScheme,
      textTheme: flutterTextTheme,
      brightness: themeBrightness,

      // 应用自定义配置
      cardTheme: CardThemeData(
        elevation: getExtension<double>('cardElevation', 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            getExtension<double>('borderRadius', 12.0),
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: getExtension<double>('buttonElevation', 2.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              getExtension<double>('buttonBorderRadius', 8.0),
            ),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            getExtension<double>('inputBorderRadius', 8.0),
          ),
        ),
        filled: getExtension<bool>('inputFilled', true),
        fillColor: colorScheme.surface,
      ),

      appBarTheme: AppBarTheme(
        elevation: getExtension<double>('appBarElevation', 0.0),
        centerTitle: getExtension<bool>('appBarCenterTitle', true),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle:
            typography.getCustomStyle('appBarTitle') ??
            typography.headlineSmall,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        elevation: getExtension<double>('bottomNavElevation', 8.0),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: getExtension<double>('fabElevation', 6.0),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),

      dividerTheme: DividerThemeData(
        color: colorScheme.onSurface.withOpacity(0.12),
        thickness: getExtension<double>('dividerThickness', 1.0),
      ),
    );
  }

  /// 获取扩展配置值
  T getExtension<T>(String key, T defaultValue) {
    final value = extensions[key];
    if (value is T) return value;
    return defaultValue;
  }

  /// 检查扩展配置是否存在
  bool hasExtension(String key) => extensions.containsKey(key);

  /// 获取所有扩展配置键名
  List<String> get allExtensionKeys => extensions.keys.toList();

  /// 复制当前主题数据并允许修改部分属性
  KThemeData copyWith({
    String? id,
    String? name,
    String? description,
    String? version,
    String? author,
    KColorScheme? colorScheme,
    KTypography? typography,
    KResourceManager? resourceManager,
    bool? isDark,
    Map<String, dynamic>? extensions,
  }) {
    return KThemeData(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      author: author ?? this.author,
      colorScheme: colorScheme ?? this.colorScheme,
      typography: typography ?? this.typography,
      resourceManager: resourceManager ?? this.resourceManager,
      isDark: isDark ?? this.isDark,
      extensions: extensions ?? this.extensions,
    );
  }

  /// 添加或更新扩展配置
  KThemeData withExtension(String key, dynamic value) {
    final newExtensions = Map<String, dynamic>.from(extensions);
    newExtensions[key] = value;
    return copyWith(extensions: newExtensions);
  }

  /// 移除扩展配置
  KThemeData withoutExtension(String key) {
    final newExtensions = Map<String, dynamic>.from(extensions);
    newExtensions.remove(key);
    return copyWith(extensions: newExtensions);
  }

  /// 合并另一个主题的扩展配置
  KThemeData mergeExtensions(Map<String, dynamic> otherExtensions) {
    final newExtensions = Map<String, dynamic>.from(extensions);
    newExtensions.addAll(otherExtensions);
    return copyWith(extensions: newExtensions);
  }

  /// 默认的亮色主题
  static final light = KThemeData(
    id: 'default_light',
    name: 'Default Light',
    description: 'Default light theme',
    version: '1.0.0',
    colorScheme: KColorScheme.light,
    typography: KTypography.defaultTypography,
    resourceManager: const KResourceManager(),
    isDark: false,
    extensions: const {
      'borderRadius': 12.0,
      'buttonBorderRadius': 8.0,
      'inputBorderRadius': 8.0,
      'cardElevation': 1.0,
      'buttonElevation': 2.0,
      'appBarElevation': 0.0,
      'bottomNavElevation': 8.0,
      'fabElevation': 6.0,
      'dividerThickness': 1.0,
      'appBarCenterTitle': true,
      'inputFilled': true,
    },
  );

  /// 默认的暗色主题
  static final dark = KThemeData(
    id: 'default_dark',
    name: 'Default Dark',
    description: 'Default dark theme',
    version: '1.0.0',
    colorScheme: KColorScheme.dark,
    typography: KTypography.defaultTypography,
    resourceManager: const KResourceManager(),
    isDark: true,
    extensions: const {
      'borderRadius': 12.0,
      'buttonBorderRadius': 8.0,
      'inputBorderRadius': 8.0,
      'cardElevation': 1.0,
      'buttonElevation': 2.0,
      'appBarElevation': 0.0,
      'bottomNavElevation': 8.0,
      'fabElevation': 6.0,
      'dividerThickness': 1.0,
      'appBarCenterTitle': true,
      'inputFilled': true,
    },
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! KThemeData) return false;

    return id == other.id &&
        name == other.name &&
        description == other.description &&
        version == other.version &&
        author == other.author &&
        colorScheme == other.colorScheme &&
        typography == other.typography &&
        resourceManager == other.resourceManager &&
        isDark == other.isDark &&
        _mapEquals(extensions, other.extensions);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      version,
      author,
      colorScheme,
      typography,
      resourceManager,
      isDark,
      Object.hashAll(
        extensions.entries.map((e) => Object.hash(e.key, e.value)),
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
    return 'KThemeData('
        'id: $id, '
        'name: $name, '
        'version: $version, '
        'isDark: $isDark, '
        'extensions: ${extensions.length} items)';
  }
}
