import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

/// K皮肤库的资源管理器，支持动态加载图片、字体、图标等资源
///
/// 提供了高度可扩展的资源管理系统，用户可以定义任意的资源键名
/// 支持本地资源和皮肤包中的资源
class KResourceManager {
  /// 图片资源映射 - 键名到资源路径的映射
  ///
  /// 用户可以定义任意的图片键名，例如：
  /// ```dart
  /// images: {
  ///   'logo': 'assets/images/logo.png',
  ///   'background': 'assets/images/bg.jpg',
  ///   'icon_home': 'assets/icons/home.png',
  ///   'avatar_default': 'assets/images/default_avatar.png',
  ///   // ... 更多自定义图片
  /// }
  /// ```
  final Map<String, String> images;

  /// 字体资源映射 - 字体名称到字体文件路径的映射
  ///
  /// 用户可以定义任意的字体，例如：
  /// ```dart
  /// fonts: {
  ///   'primary': 'assets/fonts/Roboto.ttf',
  ///   'heading': 'assets/fonts/OpenSans-Bold.ttf',
  ///   'body': 'assets/fonts/OpenSans-Regular.ttf',
  ///   'code': 'assets/fonts/FiraCode.ttf',
  ///   // ... 更多自定义字体
  /// }
  /// ```
  final Map<String, String> fonts;

  /// 图标资源映射 - 图标名称到图标路径的映射
  ///
  /// 用户可以定义任意的图标，例如：
  /// ```dart
  /// icons: {
  ///   'home': 'assets/icons/home.svg',
  ///   'settings': 'assets/icons/settings.svg',
  ///   'profile': 'assets/icons/profile.svg',
  ///   'notification': 'assets/icons/bell.svg',
  ///   // ... 更多自定义图标
  /// }
  /// ```
  final Map<String, String> icons;

  /// 其他资源映射 - 支持任意类型的资源
  ///
  /// 用户可以定义任意类型的资源，例如：
  /// ```dart
  /// others: {
  ///   'config': 'assets/data/config.json',
  ///   'sounds': 'assets/sounds/click.mp3',
  ///   'animations': 'assets/animations/loading.json',
  ///   // ... 更多自定义资源
  /// }
  /// ```
  final Map<String, String> others;

  /// 皮肤包基础路径 - 用于皮肤包中的资源
  final String? skinBasePath;

  const KResourceManager({
    this.images = const {},
    this.fonts = const {},
    this.icons = const {},
    this.others = const {},
    this.skinBasePath,
  });

  /// 从 JSON 数据创建 KResourceManager 实例
  ///
  /// JSON 格式示例：
  /// ```json
  /// {
  ///   "images": {
  ///     "logo": "assets/images/logo.png",
  ///     "background": "assets/images/bg.jpg"
  ///   },
  ///   "fonts": {
  ///     "primary": "assets/fonts/Roboto.ttf",
  ///     "heading": "assets/fonts/OpenSans-Bold.ttf"
  ///   },
  ///   "icons": {
  ///     "home": "assets/icons/home.svg",
  ///     "settings": "assets/icons/settings.svg"
  ///   },
  ///   "others": {
  ///     "config": "assets/data/config.json"
  ///   }
  /// }
  /// ```
  factory KResourceManager.fromJson(
    Map<String, dynamic> json, {
    String? skinBasePath,
  }) {
    return KResourceManager(
      images: _parseResourceMap(json['images']),
      fonts: _parseResourceMap(json['fonts']),
      icons: _parseResourceMap(json['icons']),
      others: _parseResourceMap(json['others']),
      skinBasePath: skinBasePath,
    );
  }

  /// 将 KResourceManager 转换为 JSON 数据
  Map<String, dynamic> toJson() {
    return {'images': images, 'fonts': fonts, 'icons': icons, 'others': others};
  }

  /// 获取图片资源路径
  ///
  /// ```dart
  /// final logoPath = resourceManager.getImagePath('logo');
  /// final backgroundPath = resourceManager.getImagePath('background');
  /// ```
  String? getImagePath(String key) {
    return _getResourcePath(images[key]);
  }

  /// 获取图片资源路径，如果不存在则返回默认路径
  String getImagePathOrDefault(String key, String defaultPath) {
    return getImagePath(key) ?? defaultPath;
  }

  /// 获取字体资源路径
  String? getFontPath(String key) {
    return _getResourcePath(fonts[key]);
  }

  /// 获取字体资源路径，如果不存在则返回默认路径
  String getFontPathOrDefault(String key, String defaultPath) {
    return getFontPath(key) ?? defaultPath;
  }

  /// 获取图标资源路径
  String? getIconPath(String key) {
    return _getResourcePath(icons[key]);
  }

  /// 获取图标资源路径，如果不存在则返回默认路径
  String getIconPathOrDefault(String key, String defaultPath) {
    return getIconPath(key) ?? defaultPath;
  }

  /// 获取其他资源路径
  String? getOtherPath(String key) {
    return _getResourcePath(others[key]);
  }

  /// 获取其他资源路径，如果不存在则返回默认路径
  String getOtherPathOrDefault(String key, String defaultPath) {
    return getOtherPath(key) ?? defaultPath;
  }

  /// 获取任意资源路径 - 统一接口
  ///
  /// 按优先级搜索所有资源类型：images -> icons -> fonts -> others
  String? getResourcePath(String key) {
    return getImagePath(key) ??
        getIconPath(key) ??
        getFontPath(key) ??
        getOtherPath(key);
  }

  /// 检查资源是否存在
  bool hasImage(String key) => images.containsKey(key);
  bool hasFont(String key) => fonts.containsKey(key);
  bool hasIcon(String key) => icons.containsKey(key);
  bool hasOther(String key) => others.containsKey(key);
  bool hasResource(String key) {
    return hasImage(key) || hasIcon(key) || hasFont(key) || hasOther(key);
  }

  /// 获取所有资源键名
  List<String> get allImageKeys => images.keys.toList();
  List<String> get allFontKeys => fonts.keys.toList();
  List<String> get allIconKeys => icons.keys.toList();
  List<String> get allOtherKeys => others.keys.toList();
  List<String> get allResourceKeys {
    return [...allImageKeys, ...allIconKeys, ...allFontKeys, ...allOtherKeys];
  }

  /// 异步加载字节数据 - 用于动态加载资源
  Future<ByteData?> loadResourceData(String key) async {
    final resourcePath = getResourcePath(key);
    if (resourcePath == null) return null;

    try {
      if (skinBasePath != null) {
        // 从皮肤包文件系统加载
        final file = File(path.join(skinBasePath!, resourcePath));
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          return ByteData.view(bytes.buffer);
        }
      }

      // 从 assets 加载
      return await rootBundle.load(resourcePath);
    } catch (e) {
      return null;
    }
  }

  /// 异步加载字符串数据
  Future<String?> loadResourceString(String key) async {
    final data = await loadResourceData(key);
    if (data == null) return null;

    try {
      return String.fromCharCodes(data.buffer.asUint8List());
    } catch (e) {
      return null;
    }
  }

  /// 验证所有资源文件是否存在（仅在调试模式下使用）
  Future<Map<String, bool>> validateResources() async {
    final results = <String, bool>{};

    for (final entry in {...images, ...fonts, ...icons, ...others}.entries) {
      try {
        final resourcePath = _getResourcePath(entry.value);
        if (resourcePath != null) {
          if (skinBasePath != null) {
            final file = File(path.join(skinBasePath!, resourcePath));
            results[entry.key] = await file.exists();
          } else {
            await rootBundle.load(resourcePath);
            results[entry.key] = true;
          }
        } else {
          results[entry.key] = false;
        }
      } catch (e) {
        results[entry.key] = false;
      }
    }

    return results;
  }

  /// 复制当前资源管理器并允许修改部分属性
  KResourceManager copyWith({
    Map<String, String>? images,
    Map<String, String>? fonts,
    Map<String, String>? icons,
    Map<String, String>? others,
    String? skinBasePath,
  }) {
    return KResourceManager(
      images: images ?? this.images,
      fonts: fonts ?? this.fonts,
      icons: icons ?? this.icons,
      others: others ?? this.others,
      skinBasePath: skinBasePath ?? this.skinBasePath,
    );
  }

  /// 添加或更新图片资源
  KResourceManager withImage(String key, String path) {
    final newImages = Map<String, String>.from(images);
    newImages[key] = path;
    return copyWith(images: newImages);
  }

  /// 添加或更新字体资源
  KResourceManager withFont(String key, String path) {
    final newFonts = Map<String, String>.from(fonts);
    newFonts[key] = path;
    return copyWith(fonts: newFonts);
  }

  /// 添加或更新图标资源
  KResourceManager withIcon(String key, String path) {
    final newIcons = Map<String, String>.from(icons);
    newIcons[key] = path;
    return copyWith(icons: newIcons);
  }

  /// 添加或更新其他资源
  KResourceManager withOther(String key, String path) {
    final newOthers = Map<String, String>.from(others);
    newOthers[key] = path;
    return copyWith(others: newOthers);
  }

  /// 移除资源
  KResourceManager withoutImage(String key) {
    final newImages = Map<String, String>.from(images);
    newImages.remove(key);
    return copyWith(images: newImages);
  }

  KResourceManager withoutFont(String key) {
    final newFonts = Map<String, String>.from(fonts);
    newFonts.remove(key);
    return copyWith(fonts: newFonts);
  }

  KResourceManager withoutIcon(String key) {
    final newIcons = Map<String, String>.from(icons);
    newIcons.remove(key);
    return copyWith(icons: newIcons);
  }

  KResourceManager withoutOther(String key) {
    final newOthers = Map<String, String>.from(others);
    newOthers.remove(key);
    return copyWith(others: newOthers);
  }

  // 私有辅助方法

  /// 解析资源映射
  static Map<String, String> _parseResourceMap(dynamic resourceValue) {
    if (resourceValue is Map<String, dynamic>) {
      return resourceValue.map((key, value) => MapEntry(key, value.toString()));
    }
    return {};
  }

  /// 获取完整的资源路径
  String? _getResourcePath(String? relativePath) {
    if (relativePath == null) return null;

    if (skinBasePath != null) {
      return path.join(skinBasePath!, relativePath);
    }

    return relativePath;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! KResourceManager) return false;

    return _mapEquals(images, other.images) &&
        _mapEquals(fonts, other.fonts) &&
        _mapEquals(icons, other.icons) &&
        _mapEquals(others, other.others) &&
        skinBasePath == other.skinBasePath;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(images.entries.map((e) => Object.hash(e.key, e.value))),
      Object.hashAll(fonts.entries.map((e) => Object.hash(e.key, e.value))),
      Object.hashAll(icons.entries.map((e) => Object.hash(e.key, e.value))),
      Object.hashAll(others.entries.map((e) => Object.hash(e.key, e.value))),
      skinBasePath,
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
    return 'KResourceManager('
        'images: ${images.length} items, '
        'fonts: ${fonts.length} items, '
        'icons: ${icons.length} items, '
        'others: ${others.length} items, '
        'skinBasePath: $skinBasePath)';
  }
}
