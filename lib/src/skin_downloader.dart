import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'skin_package.dart';

/// 下载状态枚举
enum DownloadStatus {
  /// 等待中
  pending,

  /// 下载中
  downloading,

  /// 解压中
  extracting,

  /// 完成
  completed,

  /// 失败
  failed,

  /// 已取消
  cancelled,
}

/// 下载进度信息
class DownloadProgress {
  /// 下载状态
  final DownloadStatus status;

  /// 已下载字节数
  final int downloadedBytes;

  /// 总字节数
  final int totalBytes;

  /// 下载进度（0.0 - 1.0）
  final double progress;

  /// 下载速度（字节/秒）
  final double speed;

  /// 剩余时间（秒）
  final double? remainingTime;

  /// 错误信息
  final String? error;

  /// 额外信息
  final String? message;

  const DownloadProgress({
    required this.status,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.progress = 0.0,
    this.speed = 0.0,
    this.remainingTime,
    this.error,
    this.message,
  });

  DownloadProgress copyWith({
    DownloadStatus? status,
    int? downloadedBytes,
    int? totalBytes,
    double? progress,
    double? speed,
    double? remainingTime,
    String? error,
    String? message,
  }) {
    return DownloadProgress(
      status: status ?? this.status,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      progress: progress ?? this.progress,
      speed: speed ?? this.speed,
      remainingTime: remainingTime ?? this.remainingTime,
      error: error ?? this.error,
      message: message ?? this.message,
    );
  }

  @override
  String toString() {
    return 'DownloadProgress(status: $status, progress: ${(progress * 100).toStringAsFixed(1)}%, speed: ${(speed / 1024).toStringAsFixed(1)} KB/s)';
  }
}

/// 皮肤包下载器
///
/// 负责从网络下载皮肤包，支持：
/// - 断点续传
/// - 进度监听
/// - 自动解压
/// - 取消下载
/// - 并发下载管理
class SkinDownloader {
  static SkinDownloader? _instance;
  static SkinDownloader get instance => _instance ??= SkinDownloader._();

  SkinDownloader._();

  /// HTTP 客户端
  final http.Client _httpClient = http.Client();

  /// 活动的下载任务
  final Map<String, _DownloadTask> _activeTasks = {};

  /// 下载目录
  String? _downloadDirectory;

  /// 最大并发下载数
  int maxConcurrentDownloads = 3;

  /// 连接超时时间（秒）
  int connectionTimeout = 30;

  /// 读取超时时间（秒）
  int readTimeout = 60;

  /// 初始化下载器
  Future<void> initialize() async {
    if (_downloadDirectory == null) {
      final appDir = await getApplicationDocumentsDirectory();
      _downloadDirectory = path.join(appDir.path, 'k_skin', 'downloads');

      // 创建下载目录
      final downloadDir = Directory(_downloadDirectory!);
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
    }
  }

  /// 设置下载目录
  void setDownloadDirectory(String directory) {
    _downloadDirectory = directory;
  }

  /// 获取下载目录
  String? get downloadDirectory => _downloadDirectory;

  /// 下载皮肤包
  ///
  /// [url] 下载URL
  /// [skinPackageInfo] 皮肤包信息（可选）
  /// [fileName] 自定义文件名（可选）
  /// [extractAfterDownload] 下载后是否自动解压
  /// 返回下载进度流
  Stream<DownloadProgress> downloadSkinPackage({
    required String url,
    SkinPackageInfo? skinPackageInfo,
    String? fileName,
    bool extractAfterDownload = true,
  }) async* {
    await initialize();

    final taskId = _generateTaskId(url);
    fileName ??= path.basename(Uri.parse(url).path);
    if (!fileName.endsWith('.zip')) {
      fileName += '.zip';
    }

    final filePath = path.join(_downloadDirectory!, fileName);

    // 检查是否已有相同任务在执行
    if (_activeTasks.containsKey(taskId)) {
      yield* _activeTasks[taskId]!.progressStream;
      return;
    }

    // 检查并发下载限制
    if (_activeTasks.length >= maxConcurrentDownloads) {
      yield DownloadProgress(
        status: DownloadStatus.failed,
        error: 'Maximum concurrent downloads ($maxConcurrentDownloads) reached',
      );
      return;
    }

    // 创建下载任务
    final task = _DownloadTask(
      id: taskId,
      url: url,
      filePath: filePath,
      skinPackageInfo: skinPackageInfo,
      extractAfterDownload: extractAfterDownload,
      httpClient: _httpClient,
      connectionTimeout: connectionTimeout,
      readTimeout: readTimeout,
    );

    _activeTasks[taskId] = task;

    try {
      yield* task.start();
    } finally {
      _activeTasks.remove(taskId);
    }
  }

  /// 取消下载
  bool cancelDownload(String url) {
    final taskId = _generateTaskId(url);
    final task = _activeTasks[taskId];
    if (task != null) {
      task.cancel();
      _activeTasks.remove(taskId);
      return true;
    }
    return false;
  }

  /// 取消所有下载
  void cancelAllDownloads() {
    for (final task in _activeTasks.values) {
      task.cancel();
    }
    _activeTasks.clear();
  }

  /// 获取活动下载列表
  List<String> get activeDownloads => _activeTasks.keys.toList();

  /// 检查URL是否正在下载
  bool isDownloading(String url) {
    final taskId = _generateTaskId(url);
    return _activeTasks.containsKey(taskId);
  }

  /// 获取下载进度（如果正在下载）
  DownloadProgress? getDownloadProgress(String url) {
    final taskId = _generateTaskId(url);
    return _activeTasks[taskId]?.currentProgress;
  }

  /// 验证URL是否可访问
  Future<bool> validateUrl(String url) async {
    try {
      final response = await _httpClient
          .head(Uri.parse(url))
          .timeout(Duration(seconds: connectionTimeout));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 获取文件大小
  Future<int?> getFileSize(String url) async {
    try {
      final response = await _httpClient
          .head(Uri.parse(url))
          .timeout(Duration(seconds: connectionTimeout));

      if (response.statusCode == 200) {
        final contentLength = response.headers['content-length'];
        if (contentLength != null) {
          return int.tryParse(contentLength);
        }
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  /// 从仓库获取皮肤包列表
  Future<List<SkinPackageInfo>> fetchSkinPackageList(
    String repositoryUrl,
  ) async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse(repositoryUrl),
            headers: {'Accept': 'application/json'},
          )
          .timeout(Duration(seconds: connectionTimeout));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is Map<String, dynamic> && jsonData['packages'] is List) {
          final packagesList = jsonData['packages'] as List;
          return packagesList
              .map((packageData) => SkinPackageInfo.fromJson(packageData))
              .toList();
        }
      }
    } catch (e) {
      debugPrint(
        'SkinDownloader: Failed to fetch package list from $repositoryUrl: $e',
      );
    }
    return [];
  }

  /// 搜索皮肤包
  Future<List<SkinPackageInfo>> searchSkinPackages({
    required String repositoryUrl,
    String? query,
    List<String>? tags,
    String? author,
    String? type,
  }) async {
    try {
      final uri = Uri.parse(repositoryUrl).replace(
        queryParameters: {
          if (query != null) 'q': query,
          if (tags != null && tags.isNotEmpty) 'tags': tags.join(','),
          if (author != null) 'author': author,
          if (type != null) 'type': type,
        },
      );

      final response = await _httpClient
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(Duration(seconds: connectionTimeout));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData is List) {
          return jsonData
              .map((packageData) => SkinPackageInfo.fromJson(packageData))
              .toList();
        } else if (jsonData is Map<String, dynamic> &&
            jsonData['results'] is List) {
          final results = jsonData['results'] as List;
          return results
              .map((packageData) => SkinPackageInfo.fromJson(packageData))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('SkinDownloader: Failed to search packages: $e');
    }
    return [];
  }

  /// 清理下载缓存
  Future<void> cleanupDownloads({bool onlyCompleted = false}) async {
    await initialize();

    final downloadDir = Directory(_downloadDirectory!);
    if (!await downloadDir.exists()) return;

    try {
      await for (final entity in downloadDir.list()) {
        if (entity is File) {
          if (!onlyCompleted || entity.path.endsWith('.zip')) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('SkinDownloader: Failed to cleanup downloads: $e');
    }
  }

  /// 获取下载缓存大小
  Future<int> getDownloadCacheSize() async {
    await initialize();

    final downloadDir = Directory(_downloadDirectory!);
    if (!await downloadDir.exists()) return 0;

    int totalSize = 0;
    try {
      await for (final entity in downloadDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
    } catch (e) {
      debugPrint('SkinDownloader: Failed to calculate cache size: $e');
    }

    return totalSize;
  }

  /// 释放资源
  void dispose() {
    cancelAllDownloads();
    _httpClient.close();
  }

  /// 生成任务ID
  String _generateTaskId(String url) {
    return url.hashCode.toString();
  }
}

/// 内部下载任务类
class _DownloadTask {
  final String id;
  final String url;
  final String filePath;
  final SkinPackageInfo? skinPackageInfo;
  final bool extractAfterDownload;
  final http.Client httpClient;
  final int connectionTimeout;
  final int readTimeout;

  final StreamController<DownloadProgress> _progressController =
      StreamController();
  bool _isCancelled = false;
  DownloadProgress? _currentProgress;

  _DownloadTask({
    required this.id,
    required this.url,
    required this.filePath,
    this.skinPackageInfo,
    required this.extractAfterDownload,
    required this.httpClient,
    required this.connectionTimeout,
    required this.readTimeout,
  });

  Stream<DownloadProgress> get progressStream => _progressController.stream;
  DownloadProgress? get currentProgress => _currentProgress;

  Stream<DownloadProgress> start() async* {
    try {
      // 发送开始状态
      _emitProgress(
        DownloadProgress(
          status: DownloadStatus.pending,
          message: 'Starting download...',
        ),
      );

      // 检查文件是否已存在
      final file = File(filePath);
      int resumePosition = 0;
      if (await file.exists()) {
        resumePosition = await file.length();
      }

      // 发送下载请求
      final request = http.Request('GET', Uri.parse(url));
      if (resumePosition > 0) {
        request.headers['Range'] = 'bytes=$resumePosition-';
      }

      final response = await httpClient
          .send(request)
          .timeout(Duration(seconds: connectionTimeout));

      if (_isCancelled) {
        _emitProgress(DownloadProgress(status: DownloadStatus.cancelled));
        return;
      }

      // 检查响应状态
      if (response.statusCode != 200 && response.statusCode != 206) {
        _emitProgress(
          DownloadProgress(
            status: DownloadStatus.failed,
            error: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          ),
        );
        return;
      }

      // 获取文件总大小
      int totalBytes = resumePosition;
      final contentLength = response.headers['content-length'];
      if (contentLength != null) {
        totalBytes += int.parse(contentLength);
      }

      // 开始下载
      _emitProgress(
        DownloadProgress(
          status: DownloadStatus.downloading,
          totalBytes: totalBytes,
          downloadedBytes: resumePosition,
          progress: totalBytes > 0 ? resumePosition / totalBytes : 0.0,
          message: 'Downloading...',
        ),
      );

      // 下载文件
      await _downloadFile(response, file, resumePosition, totalBytes);

      if (_isCancelled) {
        _emitProgress(DownloadProgress(status: DownloadStatus.cancelled));
        return;
      }

      // 解压文件（如果需要）
      if (extractAfterDownload) {
        await _extractFile(file);
      }

      // 发送完成状态
      _emitProgress(
        DownloadProgress(
          status: DownloadStatus.completed,
          totalBytes: totalBytes,
          downloadedBytes: totalBytes,
          progress: 1.0,
          message: 'Download completed',
        ),
      );
    } catch (e) {
      if (!_isCancelled) {
        _emitProgress(
          DownloadProgress(status: DownloadStatus.failed, error: e.toString()),
        );
      }
    } finally {
      _progressController.close();
    }

    yield* progressStream;
  }

  Future<void> _downloadFile(
    http.StreamedResponse response,
    File file,
    int resumePosition,
    int totalBytes,
  ) async {
    final sink = file.openWrite(mode: FileMode.writeOnlyAppend);
    int downloadedBytes = resumePosition;

    final stopwatch = Stopwatch()..start();
    int lastProgressTime = 0;
    int lastDownloadedBytes = resumePosition;

    try {
      await for (final chunk in response.stream) {
        if (_isCancelled) break;

        sink.add(chunk);
        downloadedBytes += chunk.length;

        // 更新进度（限制更新频率）
        final currentTime = stopwatch.elapsedMilliseconds;
        if (currentTime - lastProgressTime > 500 ||
            downloadedBytes == totalBytes) {
          final elapsed = (currentTime - lastProgressTime) / 1000.0;
          final speed =
              elapsed > 0
                  ? (downloadedBytes - lastDownloadedBytes) / elapsed
                  : 0.0;

          final progress = totalBytes > 0 ? downloadedBytes / totalBytes : 0.0;
          final remainingBytes = totalBytes - downloadedBytes;
          final remainingTime = speed > 0 ? remainingBytes / speed : null;

          _emitProgress(
            DownloadProgress(
              status: DownloadStatus.downloading,
              downloadedBytes: downloadedBytes,
              totalBytes: totalBytes,
              progress: progress,
              speed: speed,
              remainingTime: remainingTime,
            ),
          );

          lastProgressTime = currentTime;
          lastDownloadedBytes = downloadedBytes;
        }
      }
    } finally {
      await sink.close();
    }
  }

  Future<void> _extractFile(File zipFile) async {
    try {
      _emitProgress(
        DownloadProgress(
          status: DownloadStatus.extracting,
          progress: 1.0,
          message: 'Extracting...',
        ),
      );

      // 读取ZIP文件
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // 创建解压目录
      final extractDir = Directory(
        path.join(
          path.dirname(zipFile.path),
          path.basenameWithoutExtension(zipFile.path),
        ),
      );

      if (!await extractDir.exists()) {
        await extractDir.create(recursive: true);
      }

      // 解压文件
      for (final file in archive) {
        if (_isCancelled) break;

        final filePath = path.join(extractDir.path, file.name);

        if (file.isFile) {
          final extractedFile = File(filePath);
          await extractedFile.create(recursive: true);
          await extractedFile.writeAsBytes(file.content as List<int>);
        } else {
          await Directory(filePath).create(recursive: true);
        }
      }

      // 删除ZIP文件
      await zipFile.delete();
    } catch (e) {
      throw Exception('Failed to extract file: $e');
    }
  }

  void _emitProgress(DownloadProgress progress) {
    _currentProgress = progress;
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }

  void cancel() {
    _isCancelled = true;
    if (!_progressController.isClosed) {
      _progressController.close();
    }
  }
}
