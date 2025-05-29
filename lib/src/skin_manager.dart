import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';

import 'skin_package.dart';
import 'skin_downloader.dart';
import 'theme_data.dart';

/// 回调函数类型定义
typedef DownloadProgressCallback = void Function(int received, int total);

/// 皮肤包管理器
///
/// 负责管理已安装的皮肤包，包括下载、安装、卸载等操作
class SkinManager extends ChangeNotifier {
  static final SkinManager _instance = SkinManager._internal();

  /// 获取单例实例
  factory SkinManager() => _instance;

  SkinManager._internal();

  /// 已安装的皮肤包列表
  final List<SkinPackage> _installedSkins = [];

  /// 获取已安装的皮肤包列表
  List<SkinPackage> get installedSkins => List.unmodifiable(_installedSkins);

  /// 皮肤包存储目录
  Directory? _skinsDirectory;

  /// 是否已初始化
  bool _isInitialized = false;

  /// 获取初始化状态
  bool get isInitialized => _isInitialized;

  /// 初始化皮肤管理器
  ///
  /// 扫描本地已安装的皮肤包并加载
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 获取应用文档目录
      final appDir = await getApplicationDocumentsDirectory();
      _skinsDirectory = Directory(path.join(appDir.path, 'skins'));

      // 创建皮肤目录（如果不存在）
      if (!await _skinsDirectory!.exists()) {
        await _skinsDirectory!.create(recursive: true);
      }

      // 扫描已安装的皮肤包
      await _scanInstalledSkins();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to initialize SkinManager: $e');
    }
  }

  /// 扫描已安装的皮肤包
  Future<void> _scanInstalledSkins() async {
    if (_skinsDirectory == null) return;

    _installedSkins.clear();

    try {
      await for (final entity in _skinsDirectory!.list()) {
        if (entity is Directory) {
          final skinId = path.basename(entity.path);
          final configFile = File(path.join(entity.path, 'skin.json'));

          if (await configFile.exists()) {
            try {
              final configContent = await configFile.readAsString();
              final configJson =
                  json.decode(configContent) as Map<String, dynamic>;

              // 创建皮肤包信息
              final info = SkinPackageInfo(
                id: skinId,
                name: configJson['name'] ?? skinId,
                version: configJson['version'] ?? '1.0.0',
                description: configJson['description'] ?? '',
                author: configJson['author'] ?? '',
                isBuiltIn: false,
                tags: [],
                supportedPlatforms: [],
              );

              // 从配置创建主题数据
              final themeData =
                  configJson.containsKey('theme')
                      ? KThemeData.fromJson(configJson['theme'])
                      : KThemeData.light;

              final skinPackage = SkinPackage(
                info: info,
                themeData: themeData,
                packagePath: entity.path,
                isInstalled: true,
                installedAt: DateTime.now(),
              );

              _installedSkins.add(skinPackage);
            } catch (e) {
              debugPrint('Failed to load skin config for $skinId: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to scan installed skins: $e');
    }
  }

  /// 下载并安装皮肤包
  ///
  /// [url] 皮肤包下载链接
  /// [skinId] 皮肤包唯一标识
  /// [onProgress] 下载进度回调
  ///
  /// 返回下载成功的皮肤包，失败时返回 null
  Future<SkinPackage?> downloadSkin({
    required String url,
    required String skinId,
    DownloadProgressCallback? onProgress,
  }) async {
    if (!_isInitialized) {
      throw StateError('SkinManager not initialized. Call initialize() first.');
    }

    try {
      final downloader = SkinDownloader.instance;

      // 创建皮肤包信息
      final skinPackageInfo = SkinPackageInfo(
        id: skinId,
        name: skinId,
        version: '1.0.0',
        downloadUrl: url,
        isBuiltIn: false,
        tags: [],
        supportedPlatforms: [],
      );

      SkinPackage? downloadedSkin;

      // 监听下载进度
      await for (final progress in downloader.downloadSkinPackage(
        url: url,
        skinPackageInfo: skinPackageInfo,
        extractAfterDownload: true,
      )) {
        if (onProgress != null) {
          onProgress(progress.downloadedBytes, progress.totalBytes);
        }

        // 下载完成后需要从解压目录创建皮肤包
        if (progress.status == DownloadStatus.completed) {
          // 构建解压目录路径
          final fileName =
              skinPackageInfo.downloadUrl?.split('/').last ?? '$skinId.zip';
          final baseName = fileName.replaceAll('.zip', '');
          final extractedPath = path.join(_skinsDirectory!.path, baseName);

          downloadedSkin = await SkinPackage.fromDirectory(extractedPath);
          break;
        }

        if (progress.status == DownloadStatus.failed ||
            progress.status == DownloadStatus.cancelled) {
          throw Exception(
            'Download failed: ${progress.message ?? progress.error}',
          );
        }
      }

      if (downloadedSkin != null) {
        // 添加到已安装列表
        _installedSkins.removeWhere((skin) => skin.info.id == skinId);
        _installedSkins.add(downloadedSkin);
        notifyListeners();
        return downloadedSkin;
      }

      return null;
    } catch (e) {
      debugPrint('Failed to download skin $skinId: $e');
      return null;
    }
  }

  /// 从本地文件安装皮肤包
  ///
  /// [filePath] 皮肤包ZIP文件路径
  /// 返回安装成功的皮肤包，失败时返回 null
  Future<SkinPackage?> installFromFile(String filePath) async {
    if (!_isInitialized) {
      throw StateError('SkinManager not initialized. Call initialize() first.');
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      // 解压到临时目录然后创建皮肤包
      // final fileName = path.basename(filePath).replaceAll('.zip', '');
      // final extractPath = path.join(_skinsDirectory!.path, fileName);

      // 这里需要实现解压逻辑，暂时返回null
      // final skinPackage = await _extractAndCreateSkinPackage(file, extractPath);

      debugPrint('Install from file not yet implemented');
      return null;
    } catch (e) {
      debugPrint('Failed to install skin from file $filePath: $e');
      return null;
    }
  }

  /// 删除皮肤包
  ///
  /// [skinId] 要删除的皮肤包 ID
  ///
  /// 返回是否删除成功
  Future<bool> deleteSkin(String skinId) async {
    if (!_isInitialized) {
      throw StateError('SkinManager not initialized. Call initialize() first.');
    }

    try {
      final skinIndex = _installedSkins.indexWhere(
        (skin) => skin.info.id == skinId,
      );
      if (skinIndex == -1) {
        return false; // 皮肤包不存在
      }

      final skin = _installedSkins[skinIndex];
      if (skin.packagePath != null) {
        final skinDirectory = Directory(skin.packagePath!);
        if (await skinDirectory.exists()) {
          await skinDirectory.delete(recursive: true);
        }
      }

      _installedSkins.removeAt(skinIndex);
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Failed to delete skin $skinId: $e');
      return false;
    }
  }

  /// 根据 ID 获取皮肤包
  ///
  /// [skinId] 皮肤包 ID
  ///
  /// 返回找到的皮肤包，未找到时返回 null
  SkinPackage? getSkinById(String skinId) {
    try {
      return _installedSkins.firstWhere((skin) => skin.info.id == skinId);
    } catch (e) {
      return null;
    }
  }

  /// 根据名称获取皮肤包
  ///
  /// [name] 皮肤包名称
  ///
  /// 返回找到的皮肤包，未找到时返回 null
  SkinPackage? getSkinByName(String name) {
    try {
      return _installedSkins.firstWhere((skin) => skin.info.name == name);
    } catch (e) {
      return null;
    }
  }

  /// 刷新已安装的皮肤包列表
  Future<void> refresh() async {
    if (!_isInitialized) return;

    await _scanInstalledSkins();
    notifyListeners();
  }

  /// 获取皮肤包的主题数据
  ///
  /// [skinId] 皮肤包 ID
  ///
  /// 返回主题数据，失败时返回 null
  KThemeData? getSkinThemeData(String skinId) {
    final skin = getSkinById(skinId);
    if (skin == null) return null;

    try {
      return skin.themeData;
    } catch (e) {
      debugPrint('Failed to convert skin $skinId to theme data: $e');
      return null;
    }
  }

  /// 验证皮肤包
  ///
  /// [skinId] 皮肤包 ID
  ///
  /// 返回验证结果
  Future<bool> validateSkin(String skinId) async {
    final skin = getSkinById(skinId);
    if (skin == null) return false;

    if (skin.packagePath == null) return false;

    final skinDirectory = Directory(skin.packagePath!);
    if (!await skinDirectory.exists()) return false;

    final configFile = File(path.join(skin.packagePath!, 'skin.json'));
    if (!await configFile.exists()) return false;

    try {
      final configContent = await configFile.readAsString();
      json.decode(configContent); // 验证 JSON 格式
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 清理损坏的皮肤包
  Future<void> cleanupCorruptedSkins() async {
    if (!_isInitialized) return;

    final corruptedSkins = <String>[];

    for (final skin in _installedSkins) {
      if (!await validateSkin(skin.info.id)) {
        corruptedSkins.add(skin.info.id);
      }
    }

    for (final skinId in corruptedSkins) {
      await deleteSkin(skinId);
    }
  }

  /// 获取皮肤包总数
  int get skinCount => _installedSkins.length;

  /// 获取皮肤包总大小（字节）
  Future<int> getTotalSize() async {
    if (!_isInitialized) return 0;

    int totalSize = 0;

    for (final skin in _installedSkins) {
      if (skin.packagePath != null) {
        final directory = Directory(skin.packagePath!);
        if (await directory.exists()) {
          await for (final entity in directory.list(recursive: true)) {
            if (entity is File) {
              try {
                final stat = await entity.stat();
                totalSize += stat.size;
              } catch (e) {
                // 忽略无法访问的文件
              }
            }
          }
        }
      }
    }

    return totalSize;
  }

  /// 清理资源
  @override
  void dispose() {
    _installedSkins.clear();
    _skinsDirectory = null;
    _isInitialized = false;
    super.dispose();
  }
}
