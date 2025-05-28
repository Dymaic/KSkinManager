import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'theme_data.dart';
import 'theme_fixes.dart';

/// K皮肤库的主题管理器 - 单例模式
///
/// 负责管理应用的主题状态，包括：
/// - 当前主题的切换和管理
/// - 主题变更的通知
/// - 主题的持久化存储
/// - 主题列表的管理
class KThemeManager extends ChangeNotifier {
  static KThemeManager? _instance;
  static KThemeManager get instance => _instance ??= KThemeManager._();

  KThemeManager._();

  /// 当前激活的主题
  KThemeData _currentTheme = KThemeData.light;

  /// 所有可用的主题列表
  final Map<String, KThemeData> _themes = {
    'default_light': KThemeData.light,
    'default_dark': KThemeData.dark,
  };

  /// 主题变更回调函数
  final List<VoidCallback> _themeChangeCallbacks = [];

  /// 获取当前主题
  KThemeData get currentTheme => _currentTheme;

  /// 获取当前主题ID
  String get currentThemeId => _currentTheme.id;

  /// 获取所有主题列表
  Map<String, KThemeData> get themes => Map.unmodifiable(_themes);

  /// 获取所有主题ID列表
  List<String> get themeIds => _themes.keys.toList();

  /// 获取所有主题名称列表
  List<String> get themeNames =>
      _themes.values.map((theme) => theme.name).toList();

  /// 切换主题
  ///
  /// [themeId] 要切换到的主题ID
  /// 返回是否切换成功
  bool switchTheme(String themeId) {
    if (!_themes.containsKey(themeId)) {
      debugPrint('KThemeManager: Theme with ID "$themeId" not found');
      return false;
    }

    var newTheme = _themes[themeId]!;

    // 修复潜在的主题问题（黑屏问题）
    if (newTheme.isDark) {
      final fixedTheme = KSkinFixes.fixDarkTheme(newTheme);
      if (fixedTheme != newTheme) {
        _themes[themeId] = fixedTheme; // 更新集合中的主题
        newTheme = fixedTheme; // 使用修复后的主题
      }
    }

    if (_currentTheme.id == newTheme.id) {
      return true; // 已经是当前主题
    }

    _currentTheme = newTheme;
    notifyListeners();
    _notifyThemeChangeCallbacks();

    debugPrint(
      'KThemeManager: Switched to theme "${newTheme.name}" (${newTheme.id})',
    );
    return true;
  }

  /// 切换到下一个主题
  void switchToNextTheme() {
    final currentIndex = themeIds.indexOf(_currentTheme.id);
    final nextIndex = (currentIndex + 1) % themeIds.length;
    switchTheme(themeIds[nextIndex]);
  }

  /// 切换到上一个主题
  void switchToPreviousTheme() {
    final currentIndex = themeIds.indexOf(_currentTheme.id);
    final previousIndex =
        (currentIndex - 1 + themeIds.length) % themeIds.length;
    switchTheme(themeIds[previousIndex]);
  }

  /// 添加主题
  ///
  /// [theme] 要添加的主题
  /// [makeActive] 是否立即激活这个主题
  void addTheme(KThemeData theme, {bool makeActive = false}) {
    // 先添加主题到集合
    _themes[theme.id] = theme;

    // 如果指定了激活标志，切换到新主题
    if (makeActive) {
      switchTheme(theme.id);
    }

    debugPrint('KThemeManager: Added theme "${theme.name}" (${theme.id})');
  }

  /// 批量添加主题
  void addThemes(List<KThemeData> themes, {String? activeThemeId}) {
    for (final theme in themes) {
      _themes[theme.id] = theme;
    }

    if (activeThemeId != null && _themes.containsKey(activeThemeId)) {
      switchTheme(activeThemeId);
    }

    debugPrint('KThemeManager: Added ${themes.length} themes');
  }

  /// 移除主题
  ///
  /// [themeId] 要移除的主题ID
  /// 返回是否移除成功
  bool removeTheme(String themeId) {
    // 不能移除默认主题
    if (themeId == 'default_light' || themeId == 'default_dark') {
      debugPrint('KThemeManager: Cannot remove default theme "$themeId"');
      return false;
    }

    if (!_themes.containsKey(themeId)) {
      debugPrint('KThemeManager: Theme with ID "$themeId" not found');
      return false;
    }

    // 如果要移除的是当前主题，切换到默认主题
    if (_currentTheme.id == themeId) {
      switchTheme('default_light');
    }

    _themes.remove(themeId);
    debugPrint('KThemeManager: Removed theme "$themeId"');
    return true;
  }

  /// 检查主题是否存在
  bool hasTheme(String themeId) => _themes.containsKey(themeId);

  /// 获取指定主题
  KThemeData? getTheme(String themeId) => _themes[themeId];

  /// 获取主题，如果不存在则返回默认主题
  KThemeData getThemeOrDefault(String themeId, {KThemeData? defaultTheme}) {
    return _themes[themeId] ?? defaultTheme ?? KThemeData.light;
  }

  /// 根据名称查找主题
  KThemeData? findThemeByName(String name) {
    for (final theme in _themes.values) {
      if (theme.name == name) return theme;
    }
    return null;
  }

  /// 根据作者查找主题
  List<KThemeData> findThemesByAuthor(String author) {
    return _themes.values.where((theme) => theme.author == author).toList();
  }

  /// 获取暗色主题列表
  List<KThemeData> get darkThemes {
    return _themes.values.where((theme) => theme.isDark).toList();
  }

  /// 获取亮色主题列表
  List<KThemeData> get lightThemes {
    return _themes.values.where((theme) => !theme.isDark).toList();
  }

  /// 清除所有自定义主题（保留默认主题）
  void clearCustomThemes() {
    final customThemeIds =
        _themes.keys
            .where((id) => id != 'default_light' && id != 'default_dark')
            .toList();

    for (final id in customThemeIds) {
      _themes.remove(id);
    }

    // 如果当前主题被清除，切换到默认主题
    if (!_themes.containsKey(_currentTheme.id)) {
      switchTheme('default_light');
    }

    debugPrint('KThemeManager: Cleared ${customThemeIds.length} custom themes');
  }

  /// 重置到默认状态
  void reset() {
    _themes.clear();
    _themes['default_light'] = KThemeData.light;
    _themes['default_dark'] = KThemeData.dark;
    switchTheme('default_light');
    debugPrint('KThemeManager: Reset to default state');
  }

  /// 从JSON数据加载主题
  ///
  /// [json] JSON数据
  /// [skinBasePath] 皮肤包基础路径（可选）
  KThemeData? loadThemeFromJson(
    Map<String, dynamic> json, {
    String? skinBasePath,
  }) {
    try {
      return KThemeData.fromJson(json, skinBasePath: skinBasePath);
    } catch (e) {
      debugPrint('KThemeManager: Failed to load theme from JSON: $e');
      return null;
    }
  }

  /// 从JSON字符串加载主题
  KThemeData? loadThemeFromJsonString(
    String jsonString, {
    String? skinBasePath,
  }) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return loadThemeFromJson(json, skinBasePath: skinBasePath);
    } catch (e) {
      debugPrint('KThemeManager: Failed to parse JSON string: $e');
      return null;
    }
  }

  /// 从assets加载主题
  Future<KThemeData?> loadThemeFromAssets(
    String assetPath, {
    String? skinBasePath,
  }) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      return loadThemeFromJsonString(jsonString, skinBasePath: skinBasePath);
    } catch (e) {
      debugPrint(
        'KThemeManager: Failed to load theme from assets "$assetPath": $e',
      );
      return null;
    }
  }

  /// 导出当前主题为JSON
  Map<String, dynamic> exportCurrentTheme() {
    return _currentTheme.toJson();
  }

  /// 导出指定主题为JSON
  Map<String, dynamic>? exportTheme(String themeId) {
    final theme = _themes[themeId];
    return theme?.toJson();
  }

  /// 导出所有主题为JSON
  Map<String, dynamic> exportAllThemes() {
    return {
      'themes': _themes.map((id, theme) => MapEntry(id, theme.toJson())),
      'currentThemeId': _currentTheme.id,
    };
  }

  /// 从导出的JSON导入主题
  void importThemesFromJson(Map<String, dynamic> json) {
    try {
      final themesJson = json['themes'] as Map<String, dynamic>?;
      if (themesJson != null) {
        for (final entry in themesJson.entries) {
          final themeData = loadThemeFromJson(
            entry.value as Map<String, dynamic>,
          );
          if (themeData != null) {
            addTheme(themeData);
          }
        }
      }

      final currentThemeId = json['currentThemeId'] as String?;
      if (currentThemeId != null && _themes.containsKey(currentThemeId)) {
        switchTheme(currentThemeId);
      }
    } catch (e) {
      debugPrint('KThemeManager: Failed to import themes from JSON: $e');
    }
  }

  /// 添加主题变更回调
  void addThemeChangeCallback(VoidCallback callback) {
    _themeChangeCallbacks.add(callback);
  }

  /// 移除主题变更回调
  void removeThemeChangeCallback(VoidCallback callback) {
    _themeChangeCallbacks.remove(callback);
  }

  /// 清除所有主题变更回调
  void clearThemeChangeCallbacks() {
    _themeChangeCallbacks.clear();
  }

  /// 通知主题变更回调
  void _notifyThemeChangeCallbacks() {
    for (final callback in _themeChangeCallbacks) {
      try {
        callback();
      } catch (e) {
        debugPrint('KThemeManager: Error in theme change callback: $e');
      }
    }
  }

  /// 获取主题统计信息
  Map<String, dynamic> getStatistics() {
    return {
      'totalThemes': _themes.length,
      'lightThemes': lightThemes.length,
      'darkThemes': darkThemes.length,
      'customThemes': _themes.length - 2, // 减去两个默认主题
      'currentTheme': _currentTheme.name,
      'currentThemeId': _currentTheme.id,
    };
  }

  /// 验证主题完整性
  Future<Map<String, dynamic>> validateTheme(String themeId) async {
    final theme = _themes[themeId];
    if (theme == null) {
      return {'valid': false, 'error': 'Theme not found'};
    }

    try {
      // 验证资源文件是否存在
      final resourceValidation =
          await theme.resourceManager.validateResources();
      final missingResources =
          resourceValidation.entries
              .where((entry) => !entry.value)
              .map((entry) => entry.key)
              .toList();

      return {
        'valid': missingResources.isEmpty,
        'missingResources': missingResources,
        'resourceValidation': resourceValidation,
      };
    } catch (e) {
      return {'valid': false, 'error': 'Validation failed: $e'};
    }
  }

  @override
  void dispose() {
    _themeChangeCallbacks.clear();
    super.dispose();
  }

  /// 获取调试信息
  String get debugInfo {
    return '''
KThemeManager Debug Info:
- Current Theme: ${_currentTheme.name} (${_currentTheme.id})
- Total Themes: ${_themes.length}
- Light Themes: ${lightThemes.length}
- Dark Themes: ${darkThemes.length}
- Theme Change Callbacks: ${_themeChangeCallbacks.length}
- Available Themes: ${themeIds.join(', ')}
''';
  }
}
