import 'package:flutter/material.dart';
import 'theme_data.dart';
import 'color_scheme.dart';

/// 主题修复工具类
///
/// 用于解决主题相关问题，特别是暗色主题黑屏问题
class KSkinFixes {
  /// 验证主题是否有效
  static void validateTheme(dynamic theme) {
    if (theme == null) {
      debugPrint('KSkinFixes: Theme is null');
      return;
    }

    try {
      // 基本属性验证
      final colorScheme = theme.colorScheme;

      // 对比度检查
      final surfaceLuminance = colorScheme.surface.computeLuminance();
      final onSurfaceLuminance = colorScheme.onSurface.computeLuminance();
      var contrast = (surfaceLuminance + 0.05) / (onSurfaceLuminance + 0.05);
      if (contrast < 1.0) {
        contrast = 1.0 / contrast; // 确保大于1.0
      }

      if (contrast < 4.5) {
        // 对应于WCAG AA的4.5:1
        debugPrint(
          'KSkinFixes: Low contrast detected in theme "${theme.name}"',
        );
      }

      // Flutter主题转换验证
      final flutterTheme = theme.toFlutterThemeData();
      if (theme.isDark && flutterTheme.brightness != Brightness.dark) {
        debugPrint('KSkinFixes: Brightness mismatch in theme "${theme.name}"');
      }
    } catch (e) {
      debugPrint('KSkinFixes: Theme validation error: $e');
    }
  }

  /// 修复暗色主题黑屏问题
  ///
  /// 这个方法确保暗色主题使用正确的颜色方案，避免黑屏问题
  static KThemeData fixDarkTheme(KThemeData theme) {
    if (!theme.isDark) {
      return theme;
    }

    // 检查表面色是否设置正确
    final themeSurface = theme.colorScheme.surface;

    // 如果表面色不是暗色主题的默认值，可能导致黑屏
    if (themeSurface == Colors.black ||
        themeSurface.computeLuminance() < 0.01) {
      // 创建修复后的颜色方案
      final fixedColorScheme = KColorScheme.dark.copyWith(
        primary: theme.colorScheme.primary,
        secondary: theme.colorScheme.secondary,
        error: theme.colorScheme.error,
      );

      // 创建修复后的主题
      final fixedTheme = KThemeData(
        id: theme.id,
        name: theme.name,
        description: theme.description,
        version: theme.version,
        author: theme.author,
        colorScheme: fixedColorScheme,
        typography: theme.typography,
        resourceManager: theme.resourceManager,
        isDark: true,
        extensions: theme.extensions,
      );

      return fixedTheme;
    }

    return theme;
  }
}
