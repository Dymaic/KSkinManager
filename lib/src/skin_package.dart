import 'dart:convert';
import 'dart:io';
import 'theme_data.dart';

/// 皮肤包信息类
///
/// 描述一个皮肤包的基本信息，用于皮肤包的管理和展示
class SkinPackageInfo {
  /// 皮肤包ID - 唯一标识符
  final String id;

  /// 皮肤包名称
  final String name;

  /// 皮肤包描述
  final String? description;

  /// 版本号
  final String version;

  /// 作者信息
  final String? author;

  /// 创建时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  /// 皮肤包大小（字节）
  final int? size;

  /// 预览图片URL或路径
  final String? previewImage;

  /// 下载URL
  final String? downloadUrl;

  /// 是否为内置皮肤包
  final bool isBuiltIn;

  /// 标签列表
  final List<String> tags;

  /// 支持的平台
  final List<String> supportedPlatforms;

  /// 最低要求的应用版本
  final String? minAppVersion;

  /// 皮肤包类型（例如：theme, wallpaper, complete等）
  final String type;

  /// 额外的元数据
  final Map<String, dynamic> metadata;

  const SkinPackageInfo({
    required this.id,
    required this.name,
    this.description,
    required this.version,
    this.author,
    this.createdAt,
    this.updatedAt,
    this.size,
    this.previewImage,
    this.downloadUrl,
    this.isBuiltIn = false,
    this.tags = const [],
    this.supportedPlatforms = const [],
    this.minAppVersion,
    this.type = 'theme',
    this.metadata = const {},
  });

  /// 从 JSON 创建皮肤包信息
  factory SkinPackageInfo.fromJson(Map<String, dynamic> json) {
    return SkinPackageInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      version: json['version'] ?? '1.0.0',
      author: json['author'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      size: json['size'],
      previewImage: json['previewImage'],
      downloadUrl: json['downloadUrl'],
      isBuiltIn: json['isBuiltIn'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      supportedPlatforms: List<String>.from(json['supportedPlatforms'] ?? []),
      minAppVersion: json['minAppVersion'],
      type: json['type'] ?? 'theme',
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'version': version,
      if (author != null) 'author': author,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (size != null) 'size': size,
      if (previewImage != null) 'previewImage': previewImage,
      if (downloadUrl != null) 'downloadUrl': downloadUrl,
      'isBuiltIn': isBuiltIn,
      'tags': tags,
      'supportedPlatforms': supportedPlatforms,
      if (minAppVersion != null) 'minAppVersion': minAppVersion,
      'type': type,
      'metadata': metadata,
    };
  }

  SkinPackageInfo copyWith({
    String? id,
    String? name,
    String? description,
    String? version,
    String? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? size,
    String? previewImage,
    String? downloadUrl,
    bool? isBuiltIn,
    List<String>? tags,
    List<String>? supportedPlatforms,
    String? minAppVersion,
    String? type,
    Map<String, dynamic>? metadata,
  }) {
    return SkinPackageInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      size: size ?? this.size,
      previewImage: previewImage ?? this.previewImage,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      tags: tags ?? this.tags,
      supportedPlatforms: supportedPlatforms ?? this.supportedPlatforms,
      minAppVersion: minAppVersion ?? this.minAppVersion,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SkinPackageInfo) return false;

    return id == other.id &&
        name == other.name &&
        description == other.description &&
        version == other.version &&
        author == other.author &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        size == other.size &&
        previewImage == other.previewImage &&
        downloadUrl == other.downloadUrl &&
        isBuiltIn == other.isBuiltIn &&
        _listEquals(tags, other.tags) &&
        _listEquals(supportedPlatforms, other.supportedPlatforms) &&
        minAppVersion == other.minAppVersion &&
        type == other.type &&
        _mapEquals(metadata, other.metadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      version,
      author,
      createdAt,
      updatedAt,
      size,
      previewImage,
      downloadUrl,
      isBuiltIn,
      Object.hashAll(tags),
      Object.hashAll(supportedPlatforms),
      minAppVersion,
      type,
      Object.hashAll(metadata.entries.map((e) => Object.hash(e.key, e.value))),
    );
  }

  @override
  String toString() {
    return 'SkinPackageInfo(id: $id, name: $name, version: $version, type: $type)';
  }

  // 辅助方法
  static bool _listEquals<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  static bool _mapEquals<K, V>(Map<K, V> map1, Map<K, V> map2) {
    if (map1.length != map2.length) return false;
    for (final entry in map1.entries) {
      if (map2[entry.key] != entry.value) return false;
    }
    return true;
  }
}

/// 皮肤包类
///
/// 表示一个完整的皮肤包，包含皮肤包信息和主题数据
class SkinPackage {
  /// 皮肤包信息
  final SkinPackageInfo info;

  /// 主题数据
  final KThemeData themeData;

  /// 皮肤包文件路径（本地存储路径）
  final String? packagePath;

  /// 是否已安装
  final bool isInstalled;

  /// 安装时间
  final DateTime? installedAt;

  const SkinPackage({
    required this.info,
    required this.themeData,
    this.packagePath,
    this.isInstalled = false,
    this.installedAt,
  });

  /// 从皮肤包目录创建 SkinPackage
  ///
  /// [packageDir] 皮肤包解压后的目录路径
  static Future<SkinPackage?> fromDirectory(String packageDir) async {
    try {
      // 读取 package.json 文件
      final packageJsonFile = File('$packageDir/package.json');
      if (!await packageJsonFile.exists()) {
        return null;
      }

      final packageJsonContent = await packageJsonFile.readAsString();
      final packageJson =
          jsonDecode(packageJsonContent) as Map<String, dynamic>;

      // 创建皮肤包信息
      final info = SkinPackageInfo.fromJson(packageJson);

      // 读取主题配置文件
      final themeConfigFile = File('$packageDir/theme.json');
      if (!await themeConfigFile.exists()) {
        return null;
      }

      final themeConfigContent = await themeConfigFile.readAsString();
      final themeJson = jsonDecode(themeConfigContent) as Map<String, dynamic>;

      // 创建主题数据
      final themeData = KThemeData.fromJson(
        themeJson,
        skinBasePath: packageDir,
      );

      return SkinPackage(
        info: info,
        themeData: themeData,
        packagePath: packageDir,
        isInstalled: true,
        installedAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  /// 从 ZIP 文件创建 SkinPackage（不解压，仅读取信息）
  ///
  /// [zipPath] ZIP 文件路径
  static Future<SkinPackageInfo?> getInfoFromZip(String zipPath) async {
    // 这里需要读取 ZIP 文件中的 package.json
    // 为了简化示例，这里返回 null
    // 实际实现中可以使用 archive 包来读取 ZIP 中的文件
    return null;
  }

  /// 验证皮肤包完整性
  Future<bool> validate() async {
    if (packagePath == null) return false;

    try {
      // 检查必要文件是否存在
      final packageJsonFile = File('$packagePath/package.json');
      final themeConfigFile = File('$packagePath/theme.json');

      if (!await packageJsonFile.exists() || !await themeConfigFile.exists()) {
        return false;
      }

      // 验证主题数据的资源文件
      final resourceValidation =
          await themeData.resourceManager.validateResources();
      return resourceValidation.values.every((isValid) => isValid);
    } catch (e) {
      return false;
    }
  }

  /// 获取皮肤包大小
  Future<int> getSize() async {
    if (packagePath == null) return 0;

    try {
      final dir = Directory(packagePath!);
      if (!await dir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// 获取皮肤包中的所有文件
  Future<List<String>> getFiles() async {
    if (packagePath == null) return [];

    try {
      final dir = Directory(packagePath!);
      if (!await dir.exists()) return [];

      final files = <String>[];
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          final relativePath = entity.path.substring(packagePath!.length + 1);
          files.add(relativePath);
        }
      }
      return files;
    } catch (e) {
      return [];
    }
  }

  /// 复制皮肤包
  SkinPackage copyWith({
    SkinPackageInfo? info,
    KThemeData? themeData,
    String? packagePath,
    bool? isInstalled,
    DateTime? installedAt,
  }) {
    return SkinPackage(
      info: info ?? this.info,
      themeData: themeData ?? this.themeData,
      packagePath: packagePath ?? this.packagePath,
      isInstalled: isInstalled ?? this.isInstalled,
      installedAt: installedAt ?? this.installedAt,
    );
  }

  /// 标记为已安装
  SkinPackage markAsInstalled(String installPath) {
    return copyWith(
      packagePath: installPath,
      isInstalled: true,
      installedAt: DateTime.now(),
    );
  }

  /// 标记为未安装
  SkinPackage markAsUninstalled() {
    return copyWith(packagePath: null, isInstalled: false, installedAt: null);
  }

  /// 转换为 JSON（包含安装信息）
  Map<String, dynamic> toJson() {
    return {
      'info': info.toJson(),
      'themeData': themeData.toJson(),
      if (packagePath != null) 'packagePath': packagePath,
      'isInstalled': isInstalled,
      if (installedAt != null) 'installedAt': installedAt!.toIso8601String(),
    };
  }

  /// 从 JSON 创建 SkinPackage
  factory SkinPackage.fromJson(Map<String, dynamic> json) {
    return SkinPackage(
      info: SkinPackageInfo.fromJson(json['info'] ?? {}),
      themeData: KThemeData.fromJson(
        json['themeData'] ?? {},
        skinBasePath: json['packagePath'],
      ),
      packagePath: json['packagePath'],
      isInstalled: json['isInstalled'] ?? false,
      installedAt:
          json['installedAt'] != null
              ? DateTime.tryParse(json['installedAt'])
              : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SkinPackage) return false;

    return info == other.info &&
        themeData == other.themeData &&
        packagePath == other.packagePath &&
        isInstalled == other.isInstalled &&
        installedAt == other.installedAt;
  }

  @override
  int get hashCode {
    return Object.hash(info, themeData, packagePath, isInstalled, installedAt);
  }

  @override
  String toString() {
    return 'SkinPackage(id: ${info.id}, name: ${info.name}, installed: $isInstalled)';
  }
}

/// 皮肤包仓库信息
///
/// 描述一个皮肤包仓库的信息，用于从远程仓库获取皮肤包列表
class SkinPackageRepository {
  /// 仓库ID
  final String id;

  /// 仓库名称
  final String name;

  /// 仓库URL
  final String url;

  /// 仓库描述
  final String? description;

  /// 是否为官方仓库
  final bool isOfficial;

  /// 是否启用
  final bool isEnabled;

  /// 最后同步时间
  final DateTime? lastSyncAt;

  const SkinPackageRepository({
    required this.id,
    required this.name,
    required this.url,
    this.description,
    this.isOfficial = false,
    this.isEnabled = true,
    this.lastSyncAt,
  });

  factory SkinPackageRepository.fromJson(Map<String, dynamic> json) {
    return SkinPackageRepository(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      description: json['description'],
      isOfficial: json['isOfficial'] ?? false,
      isEnabled: json['isEnabled'] ?? true,
      lastSyncAt:
          json['lastSyncAt'] != null
              ? DateTime.tryParse(json['lastSyncAt'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      if (description != null) 'description': description,
      'isOfficial': isOfficial,
      'isEnabled': isEnabled,
      if (lastSyncAt != null) 'lastSyncAt': lastSyncAt!.toIso8601String(),
    };
  }

  SkinPackageRepository copyWith({
    String? id,
    String? name,
    String? url,
    String? description,
    bool? isOfficial,
    bool? isEnabled,
    DateTime? lastSyncAt,
  }) {
    return SkinPackageRepository(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      description: description ?? this.description,
      isOfficial: isOfficial ?? this.isOfficial,
      isEnabled: isEnabled ?? this.isEnabled,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return 'SkinPackageRepository(id: $id, name: $name, url: $url)';
  }
}
