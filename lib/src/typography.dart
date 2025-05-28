import 'package:flutter/material.dart';

/// K皮肤库的字体排版类，支持自定义字体样式定义
///
/// 提供了完整的字体排版系统，支持用户定义任意数量的自定义文本样式
class KTypography {
  /// 显示大文本样式 - 用于重要标题
  final TextStyle displayLarge;

  /// 显示中等文本样式 - 用于次要标题
  final TextStyle displayMedium;

  /// 显示小文本样式 - 用于小标题
  final TextStyle displaySmall;

  /// 标题大文本样式 - 用于页面标题
  final TextStyle headlineLarge;

  /// 标题中等文本样式 - 用于节标题
  final TextStyle headlineMedium;

  /// 标题小文本样式 - 用于小节标题
  final TextStyle headlineSmall;

  /// 正文大文本样式 - 用于重要正文
  final TextStyle bodyLarge;

  /// 正文中等文本样式 - 用于普通正文
  final TextStyle bodyMedium;

  /// 正文小文本样式 - 用于辅助文本
  final TextStyle bodySmall;

  /// 标签大文本样式 - 用于按钮等
  final TextStyle labelLarge;

  /// 标签中等文本样式 - 用于小按钮等
  final TextStyle labelMedium;

  /// 标签小文本样式 - 用于标签等
  final TextStyle labelSmall;

  /// 自定义文本样式映射 - 支持用户定义的无限文本样式
  ///
  /// 通过这个 Map，用户可以定义任意数量的自定义文本样式，例如：
  /// ```dart
  /// customStyles: {
  ///   'appBarTitle': TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ///   'cardTitle': TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  ///   'buttonText': TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  ///   'captionText': TextStyle(fontSize: 12, color: Colors.grey),
  ///   'errorText': TextStyle(fontSize: 14, color: Colors.red),
  ///   // ... 更多自定义样式
  /// }
  /// ```
  final Map<String, TextStyle> customStyles;

  const KTypography({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    this.customStyles = const {},
  });

  /// 从 JSON 数据创建 KTypography 实例
  ///
  /// JSON 格式示例：
  /// ```json
  /// {
  ///   "displayLarge": {
  ///     "fontSize": 32,
  ///     "fontWeight": "w400",
  ///     "fontFamily": "Roboto"
  ///   },
  ///   "displayMedium": {
  ///     "fontSize": 28,
  ///     "fontWeight": "w400",
  ///     "fontFamily": "Roboto"
  ///   },
  ///   "customStyles": {
  ///     "appBarTitle": {
  ///       "fontSize": 20,
  ///       "fontWeight": "bold",
  ///       "color": "#000000"
  ///     },
  ///     "cardTitle": {
  ///       "fontSize": 16,
  ///       "fontWeight": "w600"
  ///     }
  ///   }
  /// }
  /// ```
  factory KTypography.fromJson(Map<String, dynamic> json) {
    return KTypography(
      displayLarge: _parseTextStyle(json['displayLarge'] ?? {}),
      displayMedium: _parseTextStyle(json['displayMedium'] ?? {}),
      displaySmall: _parseTextStyle(json['displaySmall'] ?? {}),
      headlineLarge: _parseTextStyle(json['headlineLarge'] ?? {}),
      headlineMedium: _parseTextStyle(json['headlineMedium'] ?? {}),
      headlineSmall: _parseTextStyle(json['headlineSmall'] ?? {}),
      bodyLarge: _parseTextStyle(json['bodyLarge'] ?? {}),
      bodyMedium: _parseTextStyle(json['bodyMedium'] ?? {}),
      bodySmall: _parseTextStyle(json['bodySmall'] ?? {}),
      labelLarge: _parseTextStyle(json['labelLarge'] ?? {}),
      labelMedium: _parseTextStyle(json['labelMedium'] ?? {}),
      labelSmall: _parseTextStyle(json['labelSmall'] ?? {}),
      customStyles: _parseCustomStyles(json['customStyles']),
    );
  }

  /// 将 KTypography 转换为 JSON 数据
  Map<String, dynamic> toJson() {
    return {
      'displayLarge': _textStyleToJson(displayLarge),
      'displayMedium': _textStyleToJson(displayMedium),
      'displaySmall': _textStyleToJson(displaySmall),
      'headlineLarge': _textStyleToJson(headlineLarge),
      'headlineMedium': _textStyleToJson(headlineMedium),
      'headlineSmall': _textStyleToJson(headlineSmall),
      'bodyLarge': _textStyleToJson(bodyLarge),
      'bodyMedium': _textStyleToJson(bodyMedium),
      'bodySmall': _textStyleToJson(bodySmall),
      'labelLarge': _textStyleToJson(labelLarge),
      'labelMedium': _textStyleToJson(labelMedium),
      'labelSmall': _textStyleToJson(labelSmall),
      'customStyles': customStyles.map(
        (key, style) => MapEntry(key, _textStyleToJson(style)),
      ),
    };
  }

  /// 获取自定义文本样式
  ///
  /// 通过键名获取自定义文本样式，如果不存在则返回 null
  ///
  /// ```dart
  /// final titleStyle = typography.getCustomStyle('appBarTitle');
  /// final buttonStyle = typography.getCustomStyle('buttonText');
  /// ```
  TextStyle? getCustomStyle(String key) {
    return customStyles[key];
  }

  /// 获取自定义文本样式，如果不存在则返回默认样式
  ///
  /// ```dart
  /// final titleStyle = typography.getCustomStyleOrDefault('appBarTitle', bodyLarge);
  /// ```
  TextStyle getCustomStyleOrDefault(String key, TextStyle defaultStyle) {
    return customStyles[key] ?? defaultStyle;
  }

  /// 检查自定义样式是否存在
  bool hasCustomStyle(String key) => customStyles.containsKey(key);

  /// 获取所有自定义样式键名
  List<String> get allCustomStyleKeys => customStyles.keys.toList();

  /// 复制当前排版并允许修改部分属性
  KTypography copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
    Map<String, TextStyle>? customStyles,
  }) {
    return KTypography(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      labelSmall: labelSmall ?? this.labelSmall,
      customStyles: customStyles ?? this.customStyles,
    );
  }

  /// 添加或更新自定义文本样式
  KTypography withCustomStyle(String key, TextStyle style) {
    final newCustomStyles = Map<String, TextStyle>.from(customStyles);
    newCustomStyles[key] = style;
    return copyWith(customStyles: newCustomStyles);
  }

  /// 移除自定义文本样式
  KTypography withoutCustomStyle(String key) {
    final newCustomStyles = Map<String, TextStyle>.from(customStyles);
    newCustomStyles.remove(key);
    return copyWith(customStyles: newCustomStyles);
  }

  /// 应用颜色到所有文本样式
  KTypography applyColor(Color color) {
    return copyWith(
      displayLarge: displayLarge.copyWith(color: color),
      displayMedium: displayMedium.copyWith(color: color),
      displaySmall: displaySmall.copyWith(color: color),
      headlineLarge: headlineLarge.copyWith(color: color),
      headlineMedium: headlineMedium.copyWith(color: color),
      headlineSmall: headlineSmall.copyWith(color: color),
      bodyLarge: bodyLarge.copyWith(color: color),
      bodyMedium: bodyMedium.copyWith(color: color),
      bodySmall: bodySmall.copyWith(color: color),
      labelLarge: labelLarge.copyWith(color: color),
      labelMedium: labelMedium.copyWith(color: color),
      labelSmall: labelSmall.copyWith(color: color),
      customStyles: customStyles.map(
        (key, style) => MapEntry(key, style.copyWith(color: color)),
      ),
    );
  }

  /// 应用字体族到所有文本样式
  KTypography applyFontFamily(String fontFamily) {
    return copyWith(
      displayLarge: displayLarge.copyWith(fontFamily: fontFamily),
      displayMedium: displayMedium.copyWith(fontFamily: fontFamily),
      displaySmall: displaySmall.copyWith(fontFamily: fontFamily),
      headlineLarge: headlineLarge.copyWith(fontFamily: fontFamily),
      headlineMedium: headlineMedium.copyWith(fontFamily: fontFamily),
      headlineSmall: headlineSmall.copyWith(fontFamily: fontFamily),
      bodyLarge: bodyLarge.copyWith(fontFamily: fontFamily),
      bodyMedium: bodyMedium.copyWith(fontFamily: fontFamily),
      bodySmall: bodySmall.copyWith(fontFamily: fontFamily),
      labelLarge: labelLarge.copyWith(fontFamily: fontFamily),
      labelMedium: labelMedium.copyWith(fontFamily: fontFamily),
      labelSmall: labelSmall.copyWith(fontFamily: fontFamily),
      customStyles: customStyles.map(
        (key, style) => MapEntry(key, style.copyWith(fontFamily: fontFamily)),
      ),
    );
  }

  /// 默认的排版系统 - 基于 Material Design 3
  static const defaultTypography = KTypography(
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  // 私有辅助方法

  /// 解析 TextStyle 从 JSON
  static TextStyle _parseTextStyle(Map<String, dynamic> json) {
    return TextStyle(
      fontSize: json['fontSize']?.toDouble(),
      fontWeight: _parseFontWeight(json['fontWeight']),
      fontFamily: json['fontFamily'],
      color: json['color'] != null ? _parseColor(json['color']) : null,
      letterSpacing: json['letterSpacing']?.toDouble(),
      wordSpacing: json['wordSpacing']?.toDouble(),
      height: json['height']?.toDouble(),
      decoration: _parseTextDecoration(json['decoration']),
      decorationColor:
          json['decorationColor'] != null
              ? _parseColor(json['decorationColor'])
              : null,
      decorationStyle: _parseTextDecorationStyle(json['decorationStyle']),
      fontStyle: _parseFontStyle(json['fontStyle']),
    );
  }

  /// 将 TextStyle 转换为 JSON
  static Map<String, dynamic> _textStyleToJson(TextStyle style) {
    return {
      if (style.fontSize != null) 'fontSize': style.fontSize,
      if (style.fontWeight != null)
        'fontWeight': _fontWeightToString(style.fontWeight!),
      if (style.fontFamily != null) 'fontFamily': style.fontFamily,
      if (style.color != null) 'color': _colorToHex(style.color!),
      if (style.letterSpacing != null) 'letterSpacing': style.letterSpacing,
      if (style.wordSpacing != null) 'wordSpacing': style.wordSpacing,
      if (style.height != null) 'height': style.height,
      if (style.decoration != null)
        'decoration': _textDecorationToString(style.decoration!),
      if (style.decorationColor != null)
        'decorationColor': _colorToHex(style.decorationColor!),
      if (style.decorationStyle != null)
        'decorationStyle': _textDecorationStyleToString(style.decorationStyle!),
      if (style.fontStyle != null)
        'fontStyle': _fontStyleToString(style.fontStyle!),
    };
  }

  /// 解析自定义样式映射
  static Map<String, TextStyle> _parseCustomStyles(dynamic customStylesValue) {
    if (customStylesValue is Map<String, dynamic>) {
      return customStylesValue.map(
        (key, value) => MapEntry(key, _parseTextStyle(value)),
      );
    }
    return {};
  }

  /// 解析字体粗细
  static FontWeight? _parseFontWeight(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'thin':
        case 'w100':
          return FontWeight.w100;
        case 'extralight':
        case 'w200':
          return FontWeight.w200;
        case 'light':
        case 'w300':
          return FontWeight.w300;
        case 'normal':
        case 'w400':
          return FontWeight.w400;
        case 'medium':
        case 'w500':
          return FontWeight.w500;
        case 'semibold':
        case 'w600':
          return FontWeight.w600;
        case 'bold':
        case 'w700':
          return FontWeight.w700;
        case 'extrabold':
        case 'w800':
          return FontWeight.w800;
        case 'black':
        case 'w900':
          return FontWeight.w900;
      }
    }
    if (value is int) {
      switch (value) {
        case 100:
          return FontWeight.w100;
        case 200:
          return FontWeight.w200;
        case 300:
          return FontWeight.w300;
        case 400:
          return FontWeight.w400;
        case 500:
          return FontWeight.w500;
        case 600:
          return FontWeight.w600;
        case 700:
          return FontWeight.w700;
        case 800:
          return FontWeight.w800;
        case 900:
          return FontWeight.w900;
      }
    }
    return null;
  }

  /// 解析颜色
  static Color _parseColor(String colorValue) {
    final hex = colorValue.replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    throw ArgumentError('Invalid color format: $colorValue');
  }

  /// 解析文本装饰
  static TextDecoration? _parseTextDecoration(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'none':
          return TextDecoration.none;
        case 'underline':
          return TextDecoration.underline;
        case 'overline':
          return TextDecoration.overline;
        case 'linethrough':
          return TextDecoration.lineThrough;
      }
    }
    return null;
  }

  /// 解析文本装饰样式
  static TextDecorationStyle? _parseTextDecorationStyle(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'solid':
          return TextDecorationStyle.solid;
        case 'double':
          return TextDecorationStyle.double;
        case 'dotted':
          return TextDecorationStyle.dotted;
        case 'dashed':
          return TextDecorationStyle.dashed;
        case 'wavy':
          return TextDecorationStyle.wavy;
      }
    }
    return null;
  }

  /// 解析字体样式
  static FontStyle? _parseFontStyle(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'normal':
          return FontStyle.normal;
        case 'italic':
          return FontStyle.italic;
      }
    }
    return null;
  }

  // 转换为字符串的辅助方法

  static String _fontWeightToString(FontWeight fontWeight) {
    switch (fontWeight) {
      case FontWeight.w100:
        return 'w100';
      case FontWeight.w200:
        return 'w200';
      case FontWeight.w300:
        return 'w300';
      case FontWeight.w400:
        return 'w400';
      case FontWeight.w500:
        return 'w500';
      case FontWeight.w600:
        return 'w600';
      case FontWeight.w700:
        return 'w700';
      case FontWeight.w800:
        return 'w800';
      case FontWeight.w900:
        return 'w900';
      default:
        return 'w400';
    }
  }

  static String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  static String _textDecorationToString(TextDecoration decoration) {
    if (decoration == TextDecoration.none) return 'none';
    if (decoration == TextDecoration.underline) return 'underline';
    if (decoration == TextDecoration.overline) return 'overline';
    if (decoration == TextDecoration.lineThrough) return 'linethrough';
    return 'none';
  }

  static String _textDecorationStyleToString(TextDecorationStyle style) {
    switch (style) {
      case TextDecorationStyle.solid:
        return 'solid';
      case TextDecorationStyle.double:
        return 'double';
      case TextDecorationStyle.dotted:
        return 'dotted';
      case TextDecorationStyle.dashed:
        return 'dashed';
      case TextDecorationStyle.wavy:
        return 'wavy';
    }
  }

  static String _fontStyleToString(FontStyle style) {
    switch (style) {
      case FontStyle.normal:
        return 'normal';
      case FontStyle.italic:
        return 'italic';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! KTypography) return false;

    return displayLarge == other.displayLarge &&
        displayMedium == other.displayMedium &&
        displaySmall == other.displaySmall &&
        headlineLarge == other.headlineLarge &&
        headlineMedium == other.headlineMedium &&
        headlineSmall == other.headlineSmall &&
        bodyLarge == other.bodyLarge &&
        bodyMedium == other.bodyMedium &&
        bodySmall == other.bodySmall &&
        labelLarge == other.labelLarge &&
        labelMedium == other.labelMedium &&
        labelSmall == other.labelSmall &&
        _mapEquals(customStyles, other.customStyles);
  }

  @override
  int get hashCode {
    return Object.hash(
      displayLarge,
      displayMedium,
      displaySmall,
      headlineLarge,
      headlineMedium,
      headlineSmall,
      bodyLarge,
      bodyMedium,
      bodySmall,
      labelLarge,
      labelMedium,
      labelSmall,
      Object.hashAll(
        customStyles.entries.map((e) => Object.hash(e.key, e.value)),
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
    return 'KTypography('
        'customStyles: ${customStyles.length} items)';
  }
}
