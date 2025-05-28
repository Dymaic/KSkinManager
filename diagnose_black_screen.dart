import 'package:flutter/material.dart';
import 'lib/src/theme_builder.dart';
import 'lib/src/color_scheme.dart';

void main() {
  print('=== 黑屏问题诊断测试 ===\n');

  // 测试场景1：用户在example app中创建自定义暗色主题的完整流程
  print('场景1: 模拟用户创建自定义暗色主题');

  // 模拟用户在example app中的操作
  final primaryColor = Colors.purple;
  final secondaryColor = Colors.orange;
  final isDark = true;
  final name = "我的自定义主题";

  print('用户输入:');
  print('  主题名称: $name');
  print('  主色调: $primaryColor');
  print('  次色调: $secondaryColor');
  print('  暗色模式: $isDark');

  // 使用修复后的调用顺序创建主题
  final theme =
      KThemeBuilder()
          .id('custom_${DateTime.now().millisecondsSinceEpoch}')
          .name(name)
          .version('1.0.0')
          .dark(isDark) // 先设置暗色模式
          .primaryColor(primaryColor) // 再设置主色
          .secondaryColor(secondaryColor) // 再设置次色
          .extension('borderRadius', 12.0)
          .extension('cardElevation', 4.0)
          .build();

  print('\n创建的主题数据:');
  print('  名称: ${theme.name}');
  print('  是否暗色: ${theme.isDark}');
  print('  主色: ${theme.colorScheme.primary}');
  print('  次色: ${theme.colorScheme.secondary}');
  print('  表面色: ${theme.colorScheme.surface}');
  print('  文字色: ${theme.colorScheme.onSurface}');

  // 验证颜色方案
  final darkScheme = KColorScheme.dark;
  print('\n颜色方案验证:');
  print('  默认暗色表面: ${darkScheme.surface}');
  print('  实际表面色: ${theme.colorScheme.surface}');
  print('  表面色正确: ${theme.colorScheme.surface == darkScheme.surface}');

  print('  默认暗色文字: ${darkScheme.onSurface}');
  print('  实际文字色: ${theme.colorScheme.onSurface}');
  print('  文字色正确: ${theme.colorScheme.onSurface == darkScheme.onSurface}');

  // 转换为Flutter主题
  print('\n转换为Flutter ThemeData...');
  try {
    final flutterTheme = theme.toFlutterThemeData();

    print('Flutter主题属性:');
    print('  useMaterial3: ${flutterTheme.useMaterial3}');
    print('  brightness: ${flutterTheme.brightness}');
    print('  主色: ${flutterTheme.colorScheme.primary}');
    print('  次色: ${flutterTheme.colorScheme.secondary}');
    print('  表面: ${flutterTheme.colorScheme.surface}');
    print('  文字: ${flutterTheme.colorScheme.onSurface}');

    // 黑屏诊断检查
    print('\n🔍 黑屏问题诊断:');
    final surface = flutterTheme.colorScheme.surface;
    final onSurface = flutterTheme.colorScheme.onSurface;
    final primary = flutterTheme.colorScheme.primary;

    print(
      '  1. 表面色是否为黑色: ${surface == Colors.black || surface == const Color(0xFF000000)}',
    );
    print('  2. 表面色透明度: ${(surface.alpha / 255.0).toStringAsFixed(2)}');
    print('  3. 文字色是否与表面色相同: ${surface == onSurface}');
    print('  4. 文字色是否透明: ${onSurface.alpha == 0}');
    print('  5. 主色是否设置正确: ${primary == primaryColor}');

    // 检查对比度
    final surfaceLuminance = surface.computeLuminance();
    final onSurfaceLuminance = onSurface.computeLuminance();
    final contrast = (surfaceLuminance + 0.05) / (onSurfaceLuminance + 0.05);
    print('  6. 表面与文字对比度: ${contrast.toStringAsFixed(2)} (应该 > 3.0)');

    if (surface == Colors.black && onSurface == Colors.black) {
      print('  ❌ 发现问题: 表面色和文字色都是黑色！');
    } else if (surface.alpha == 0) {
      print('  ❌ 发现问题: 表面色是透明的！');
    } else if (contrast < 3.0) {
      print('  ⚠️  警告: 对比度可能不够，用户难以看清文字');
    } else {
      print('  ✅ 颜色设置看起来正常');
    }
  } catch (e) {
    print('❌ 转换Flutter主题时出错: $e');
  }

  // 对比测试：创建亮色主题
  print('\n--- 对比测试：亮色主题 ---');
  final lightTheme =
      KThemeBuilder()
          .dark(false)
          .primaryColor(primaryColor)
          .secondaryColor(secondaryColor)
          .build();

  final lightFlutter = lightTheme.toFlutterThemeData();
  print('亮色主题表面: ${lightFlutter.colorScheme.surface}');
  print('亮色主题文字: ${lightFlutter.colorScheme.onSurface}');

  print('\n=== 测试完成 ===');
}
