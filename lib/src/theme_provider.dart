import 'package:flutter/material.dart';
import 'theme_data.dart';
import 'theme_manager.dart';

/// K皮肤库的主题提供者 Widget
///
/// 这是一个 InheritedWidget，用于在 Widget 树中提供主题数据，
/// 并处理主题变更时的界面更新
class KThemeProvider extends StatefulWidget {
  /// 子 Widget
  final Widget child;

  /// 初始主题ID（可选）
  final String? initialThemeId;

  /// 是否监听系统主题变化
  final bool followSystemTheme;

  const KThemeProvider({
    super.key,
    required this.child,
    this.initialThemeId,
    this.followSystemTheme = true,
  });

  /// 获取当前上下文中的主题数据
  static KThemeData of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_InheritedKTheme>();
    return inherited?.themeData ?? KThemeData.light;
  }

  /// 获取当前上下文中的主题数据（可能为空）
  static KThemeData? maybeOf(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_InheritedKTheme>();
    return inherited?.themeData;
  }

  /// 切换主题的便捷方法
  static bool switchTheme(BuildContext context, String themeId) {
    return KThemeManager.instance.switchTheme(themeId);
  }

  /// 切换到下一个主题
  static void switchToNextTheme(BuildContext context) {
    KThemeManager.instance.switchToNextTheme();
  }

  /// 切换到上一个主题
  static void switchToPreviousTheme(BuildContext context) {
    KThemeManager.instance.switchToPreviousTheme();
  }

  /// 获取主题管理器
  static KThemeManager getManager(BuildContext context) {
    return KThemeManager.instance;
  }

  @override
  State<KThemeProvider> createState() => _KThemeProviderState();
}

class _KThemeProviderState extends State<KThemeProvider>
    with WidgetsBindingObserver {
  late KThemeManager _themeManager;
  late KThemeData _currentTheme;

  @override
  void initState() {
    super.initState();
    _themeManager = KThemeManager.instance;

    // 设置初始主题
    if (widget.initialThemeId != null) {
      _themeManager.switchTheme(widget.initialThemeId!);
    }

    _currentTheme = _themeManager.currentTheme;

    // 监听主题变更
    _themeManager.addListener(_onThemeChanged);

    // 监听系统主题变化
    if (widget.followSystemTheme) {
      WidgetsBinding.instance.addObserver(this);
    }
  }

  @override
  void dispose() {
    _themeManager.removeListener(_onThemeChanged);
    if (widget.followSystemTheme) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (widget.followSystemTheme) {
      _handleSystemThemeChange();
    }
  }

  void _onThemeChanged() {
    if (mounted) {
      final newTheme = _themeManager.currentTheme;
      setState(() {
        _currentTheme = newTheme;
      });
    }
  }

  void _handleSystemThemeChange() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDark = brightness == Brightness.dark;

    // 根据系统主题自动切换
    if (isDark && !_currentTheme.isDark) {
      // 切换到暗色主题
      final darkThemes = _themeManager.darkThemes;
      if (darkThemes.isNotEmpty) {
        _themeManager.switchTheme(darkThemes.first.id);
      } else {
        _themeManager.switchTheme('default_dark');
      }
    } else if (!isDark && _currentTheme.isDark) {
      // 切换到亮色主题
      final lightThemes = _themeManager.lightThemes;
      if (lightThemes.isNotEmpty) {
        _themeManager.switchTheme(lightThemes.first.id);
      } else {
        _themeManager.switchTheme('default_light');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 转换为Flutter主题
    final flutterTheme = _currentTheme.toFlutterThemeData();

    return _InheritedKTheme(
      themeData: _currentTheme,
      child: Theme(data: flutterTheme, child: widget.child),
    );
  }
}

/// 内部的 InheritedWidget，用于传递主题数据
class _InheritedKTheme extends InheritedWidget {
  final KThemeData themeData;

  const _InheritedKTheme({required this.themeData, required super.child});

  @override
  bool updateShouldNotify(_InheritedKTheme oldWidget) {
    return themeData != oldWidget.themeData;
  }
}

/// 主题构建器 Widget
///
/// 提供构建器模式来访问主题数据，适用于需要根据主题进行条件渲染的场景
class KThemeBuilderWidget extends StatelessWidget {
  /// 构建器函数
  final Widget Function(BuildContext context, KThemeData theme) builder;

  const KThemeBuilderWidget({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final theme = KThemeProvider.of(context);
    return builder(context, theme);
  }
}

/// 主题切换器 Widget
///
/// 提供一个下拉菜单来切换主题
class KThemeSwitcher extends StatelessWidget {
  /// 是否显示主题描述
  final bool showDescription;

  /// 自定义样式
  final TextStyle? textStyle;

  /// 自定义图标
  final Widget? icon;

  /// 变更回调
  final void Function(KThemeData theme)? onThemeChanged;

  const KThemeSwitcher({
    super.key,
    this.showDescription = false,
    this.textStyle,
    this.icon,
    this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = KThemeManager.instance;
    final currentTheme = themeManager.currentTheme;
    final themes = themeManager.themes.values.toList();

    return DropdownButton<String>(
      value: currentTheme.id,
      icon: icon ?? const Icon(Icons.palette),
      style: textStyle,
      onChanged: (String? themeId) {
        if (themeId != null) {
          final success = themeManager.switchTheme(themeId);
          if (success && onThemeChanged != null) {
            final newTheme = themeManager.getTheme(themeId)!;
            onThemeChanged!(newTheme);
          }
        }
      },
      items:
          themes.map<DropdownMenuItem<String>>((theme) {
            return DropdownMenuItem<String>(
              value: theme.id,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(theme.name),
                  if (showDescription && theme.description != null)
                    Text(
                      theme.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

/// 主题预览卡片 Widget
///
/// 显示主题的预览效果
class KThemePreviewCard extends StatelessWidget {
  /// 要预览的主题
  final KThemeData theme;

  /// 是否为当前主题
  final bool isActive;

  /// 点击回调
  final VoidCallback? onTap;

  /// 卡片尺寸
  final Size size;

  const KThemePreviewCard({
    super.key,
    required this.theme,
    this.isActive = false,
    this.onTap,
    this.size = const Size(120, 80),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          border: Border.all(
            color:
                isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.2),
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Theme(
          data: theme.toFlutterThemeData(),
          child: Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(7),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题栏预览
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Text(
                        theme.name,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 内容预览
                  Expanded(
                    child: Row(
                      children: [
                        // 主要内容区域
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  height: 8,
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                                Container(
                                  height: 6,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),

                        // 侧边栏预览
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // 底部信息
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        theme.isDark ? 'Dark' : 'Light',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 6,
                        ),
                      ),
                      if (isActive)
                        Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                          size: 8,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 主题网格选择器 Widget
///
/// 以网格形式显示所有主题供用户选择
class KThemeGridSelector extends StatelessWidget {
  /// 网格列数
  final int crossAxisCount;

  /// 卡片间距
  final double spacing;

  /// 卡片尺寸
  final Size cardSize;

  /// 主题变更回调
  final void Function(KThemeData theme)? onThemeChanged;

  const KThemeGridSelector({
    super.key,
    this.crossAxisCount = 3,
    this.spacing = 8.0,
    this.cardSize = const Size(120, 80),
    this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeManager = KThemeManager.instance;
    final currentTheme = themeManager.currentTheme;
    final themes = themeManager.themes.values.toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: cardSize.width / cardSize.height,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        final isActive = theme.id == currentTheme.id;

        return KThemePreviewCard(
          theme: theme,
          isActive: isActive,
          size: cardSize,
          onTap: () {
            final success = themeManager.switchTheme(theme.id);
            if (success && onThemeChanged != null) {
              onThemeChanged!(theme);
            }
          },
        );
      },
    );
  }
}
