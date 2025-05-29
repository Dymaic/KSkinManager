import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:k_skin/k_skin.dart';

void main() {
  group('KColorScheme', () {
    test('should create from JSON correctly', () {
      final json = {
        'primary': '#FF5722',
        'primaryContainer': '#FFCCBC',
        'secondary': '#2196F3',
        'secondaryContainer': '#BBDEFB',
        'surface': '#FFFFFF',
        'error': '#F44336',
        'onSurface': '#000000',
        'onPrimary': '#FFFFFF',
        'onSecondary': '#FFFFFF',
        'onError': '#FFFFFF',
        'customColors': {'brand': '#123456', 'accent': '#654321'},
      };

      final colorScheme = KColorScheme.fromJson(json);

      expect(colorScheme.primary, const Color(0xFFFF5722));
      expect(colorScheme.secondary, const Color(0xFF2196F3));
      expect(colorScheme.customColors['brand'], const Color(0xFF123456));
      expect(colorScheme.customColors['accent'], const Color(0xFF654321));
    });

    test('should convert to JSON correctly', () {
      const colorScheme = KColorScheme(
        primary: Color(0xFFFF5722),
        primaryContainer: Color(0xFFFFCCBC),
        secondary: Color(0xFF2196F3),
        secondaryContainer: Color(0xFFBBDEFB),
        surface: Color(0xFFFFFFFF),
        error: Color(0xFFF44336),
        onSurface: Color(0xFF000000),
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFFFFFFFF),
        onError: Color(0xFFFFFFFF),
        customColors: {'brand': Color(0xFF123456)},
      );

      final json = colorScheme.toJson();

      expect(json['primary'], '#FFFF5722');
      expect(json['secondary'], '#FF2196F3');
      expect(json['customColors']['brand'], '#FF123456');
    });

    test('should add custom color correctly', () {
      const colorScheme = KColorScheme.light;
      final updated = colorScheme.withCustomColor('accent', Colors.blue);

      expect(updated.customColors['accent'], Colors.blue);
      expect(colorScheme.customColors.containsKey('accent'), false);
    });

    test('should use default light scheme', () {
      expect(KColorScheme.light.primary, const Color(0xFF6200EE));
      expect(KColorScheme.light.surface, const Color(0xFFFFFFFF));
    });

    test('should use default dark scheme', () {
      expect(KColorScheme.dark.primary, const Color(0xFFBB86FC));
      expect(KColorScheme.dark.surface, const Color(0xFF121212));
    });
  });

  group('KTypography', () {
    test('should create from JSON correctly', () {
      final json = {
        'displayLarge': {
          'fontSize': 32,
          'fontWeight': 'w400',
          'fontFamily': 'Roboto',
        },
        'customStyles': {
          'appBarTitle': {
            'fontSize': 20,
            'fontWeight': 'bold',
            'color': '#000000',
          },
        },
      };

      final typography = KTypography.fromJson(json);

      expect(typography.displayLarge.fontSize, 32);
      expect(typography.displayLarge.fontFamily, 'Roboto');
      expect(typography.customStyles['appBarTitle']?.fontSize, 20);
    });

    test('should convert to JSON correctly', () {
      final typography = KTypography.defaultTypography.copyWith(
        customStyles: {
          'test': const TextStyle(fontSize: 16, color: Colors.red),
        },
      );

      final json = typography.toJson();

      expect(json.containsKey('displayLarge'), true);
      expect(json['customStyles']['test']['fontSize'], 16);
    });
  });

  group('KResourceManager', () {
    test('should manage resources correctly', () {
      final manager = KResourceManager(
        images: {'logo': 'assets/logo.png'},
        fonts: {'title': 'CustomFont'},
        icons: {'home': 'assets/icons/home.svg'},
      );

      // Test getting resources
      expect(manager.getImagePath('logo'), 'assets/logo.png');
      expect(manager.getFontPath('title'), 'CustomFont');
      expect(manager.getIconPath('home'), 'assets/icons/home.svg');

      // Test non-existent resources
      expect(manager.getImagePath('nonexistent'), null);
      expect(manager.getFontPath('nonexistent'), null);
      expect(manager.getIconPath('nonexistent'), null);
    });

    test('should create from JSON correctly', () {
      final json = {
        'images': {'logo': 'assets/logo.png'},
        'fonts': {'title': 'CustomFont'},
        'icons': {'home': 'assets/icons/home.svg'},
      };

      final manager = KResourceManager.fromJson(json);

      expect(manager.getImagePath('logo'), 'assets/logo.png');
      expect(manager.getFontPath('title'), 'CustomFont');
      expect(manager.getIconPath('home'), 'assets/icons/home.svg');
    });
  });

  group('KThemeData', () {
    test('should create theme data correctly', () {
      final themeData = KThemeData(
        id: 'test_theme',
        name: 'Test Theme',
        version: '1.0.0',
        colorScheme: KColorScheme.light,
        typography: KTypography.defaultTypography,
        resourceManager: KResourceManager(),
      );

      expect(themeData.id, 'test_theme');
      expect(themeData.name, 'Test Theme');
      expect(themeData.version, '1.0.0');
      expect(themeData.isDark, false);
    });

    test('should convert to Flutter ThemeData', () {
      final kTheme = KThemeData(
        id: 'test_theme',
        name: 'Test Theme',
        version: '1.0.0',
        colorScheme: KColorScheme.light,
        typography: KTypography.defaultTypography,
        resourceManager: KResourceManager(),
      );

      final flutterTheme = kTheme.toFlutterThemeData();

      expect(flutterTheme, isA<ThemeData>());
      expect(flutterTheme.colorScheme.primary, KColorScheme.light.primary);
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': 'json_theme',
        'name': 'JSON Theme',
        'version': '2.0.0',
        'author': 'Test Author',
        'isDark': true,
        'colorScheme': {
          'primary': '#FF5722',
          'primaryContainer': '#FFCCBC',
          'secondary': '#2196F3',
          'secondaryContainer': '#BBDEFB',
          'surface': '#121212',
          'error': '#F44336',
          'onSurface': '#FFFFFF',
          'onPrimary': '#FFFFFF',
          'onSecondary': '#FFFFFF',
          'onError': '#FFFFFF',
        },
        'extensions': {'borderRadius': 8.0, 'elevation': 4.0},
      };

      final themeData = KThemeData.fromJson(json);

      expect(themeData.id, 'json_theme');
      expect(themeData.name, 'JSON Theme');
      expect(themeData.version, '2.0.0');
      expect(themeData.author, 'Test Author');
      expect(themeData.isDark, true);
      expect(themeData.extensions['borderRadius'], 8.0);
      expect(themeData.extensions['elevation'], 4.0);
    });
  });

  group('KThemeBuilder', () {
    test('should build theme with fluent API', () {
      final theme =
          KThemeBuilder()
              .id('fluent_theme')
              .name('Fluent Theme')
              .version('1.0.0')
              .primaryColor(Colors.blue)
              .secondaryColor(Colors.green)
              .customColor('accent', Colors.orange)
              .extension('borderRadius', 12.0)
              .build();

      expect(theme.id, 'fluent_theme');
      expect(theme.name, 'Fluent Theme');
      expect(theme.colorScheme.primary, Colors.blue);
      expect(theme.colorScheme.secondary, Colors.green);
      expect(theme.colorScheme.customColors['accent'], Colors.orange);
      expect(theme.extensions['borderRadius'], 12.0);
    });

    test('should create from existing theme', () {
      final originalTheme = KThemeData(
        id: 'original',
        name: 'Original',
        version: '1.0.0',
        colorScheme: KColorScheme.light,
        typography: KTypography.defaultTypography,
        resourceManager: KResourceManager(),
      );

      final modifiedTheme =
          KThemeBuilder()
              .fromTheme(originalTheme)
              .name('Modified')
              .primaryColor(Colors.red)
              .build();

      expect(modifiedTheme.id, 'original');
      expect(modifiedTheme.name, 'Modified');
      expect(modifiedTheme.colorScheme.primary, Colors.red);
    });

    test('should reset correctly', () {
      final builder = KThemeBuilder()
          .id('test')
          .name('Test')
          .primaryColor(Colors.blue);

      final theme1 = builder.build();
      expect(theme1.name, 'Test');

      builder.reset();
      final theme2 = builder.build();
      expect(theme2.name, 'Custom Theme'); // Default name
    });
  });

  group('KQuickThemeBuilder', () {
    test('should create light theme', () {
      final theme = KQuickThemeBuilder.light(primaryColor: Colors.blue).build();

      expect(theme.isDark, false);
      expect(theme.colorScheme.primary, Colors.blue);
    });

    test('should create dark theme', () {
      final theme =
          KQuickThemeBuilder.dark(primaryColor: Colors.purple).build();

      expect(theme.isDark, true);
      expect(theme.colorScheme.primary, Colors.purple);
    });

    test('should create gradient theme', () {
      final theme =
          KQuickThemeBuilder.gradient(
            name: 'Gradient Theme',
            colorScheme: KColorScheme.light,
            primaryColor: Colors.green,
            secondaryColor: Colors.greenAccent,
          ).build();

      expect(theme.isDark, false);
      expect(theme.name, 'Gradient Theme');
      expect(theme.colorScheme.primary, Colors.green);
      expect(theme.colorScheme.secondary, Colors.greenAccent);
    });

    test('should create template themes', () {
      final oceanTheme = KQuickThemeBuilder.preset('ocean').build();
      expect(oceanTheme.name, 'Ocean Theme');
      expect(oceanTheme.colorScheme.primary, Colors.blue.shade700);
      expect(
        oceanTheme.colorScheme.customColors['accent'],
        Colors.teal.shade300,
      );

      final forestTheme = KQuickThemeBuilder.preset('forest').build();
      expect(forestTheme.name, 'Forest Theme');
      expect(forestTheme.colorScheme.primary, Colors.green.shade800);

      final defaultTheme = KQuickThemeBuilder.preset('unknown').build();
      expect(defaultTheme.name, 'Default Theme');
      expect(defaultTheme.isDark, false);
    });
  });

  group('SkinPackage', () {
    test('should create skin package correctly', () {
      final info = SkinPackageInfo(
        id: 'test_skin',
        name: 'Test Skin',
        version: '1.0.0',
        description: 'A test skin package',
        author: 'Test Author',
      );

      final themeData = KThemeData(
        id: 'test_theme',
        name: 'Test Theme',
        version: '1.0.0',
        colorScheme: KColorScheme.light,
        typography: KTypography.defaultTypography,
        resourceManager: KResourceManager(),
      );

      final skinPackage = SkinPackage(info: info, themeData: themeData);

      expect(skinPackage.info.id, 'test_skin');
      expect(skinPackage.info.name, 'Test Skin');
      expect(skinPackage.info.version, '1.0.0');
      expect(skinPackage.info.description, 'A test skin package');
      expect(skinPackage.info.author, 'Test Author');
      expect(skinPackage.themeData.id, 'test_theme');
    });

    test('should access theme data correctly', () {
      final colorScheme = KColorScheme.light.copyWith(
        primary: const Color(0xFFFF5722),
        secondary: const Color(0xFF2196F3),
      );

      final themeData = KThemeData(
        id: 'theme_skin',
        name: 'Theme Skin',
        version: '1.0.0',
        colorScheme: colorScheme,
        typography: KTypography.defaultTypography,
        resourceManager: KResourceManager(),
        extensions: {'borderRadius': 10.0},
      );

      final info = SkinPackageInfo(
        id: 'theme_skin',
        name: 'Theme Skin',
        version: '1.0.0',
      );

      final skinPackage = SkinPackage(info: info, themeData: themeData);

      expect(skinPackage.themeData.id, 'theme_skin');
      expect(skinPackage.themeData.name, 'Theme Skin');
      expect(
        skinPackage.themeData.colorScheme.primary,
        const Color(0xFFFF5722),
      );
      expect(skinPackage.themeData.extensions['borderRadius'], 10.0);
    });

    test('should validate installation status', () {
      final info = SkinPackageInfo(
        id: 'valid',
        name: 'Valid Skin',
        version: '1.0.0',
      );

      final themeData = KThemeData(
        id: 'valid_theme',
        name: 'Valid Theme',
        version: '1.0.0',
        colorScheme: KColorScheme.light,
        typography: KTypography.defaultTypography,
        resourceManager: KResourceManager(),
      );

      final installedSkin = SkinPackage(
        info: info,
        themeData: themeData,
        isInstalled: true,
        packagePath: '/path/to/skin',
        installedAt: DateTime.now(),
      );

      final uninstalledSkin = SkinPackage(
        info: info,
        themeData: themeData,
        isInstalled: false,
      );

      expect(installedSkin.isInstalled, true);
      expect(installedSkin.packagePath, '/path/to/skin');
      expect(installedSkin.installedAt, isNotNull);
      expect(uninstalledSkin.isInstalled, false);
      expect(uninstalledSkin.packagePath, null);
    });
  });

  group('Integration Tests', () {
    test('should create complete theme workflow', () {
      // 1. Create a theme using builder
      final customTheme =
          KThemeBuilder()
              .id('custom_workflow')
              .name('Custom Workflow Theme')
              .version('1.0.0')
              .author('Test Developer')
              .primaryColor(const Color(0xFF1976D2))
              .secondaryColor(const Color(0xFF388E3C))
              .customColor('warning', const Color(0xFFF57C00))
              .customColor('info', const Color(0xFF0288D1))
              .fontStyle(
                'heading',
                const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )
              .extension('borderRadius', 8.0)
              .extension('elevation', 2.0)
              .build();

      // 2. Verify theme properties
      expect(customTheme.id, 'custom_workflow');
      expect(customTheme.name, 'Custom Workflow Theme');
      expect(customTheme.colorScheme.primary, const Color(0xFF1976D2));
      expect(
        customTheme.colorScheme.customColors['warning'],
        const Color(0xFFF57C00),
      );
      expect(customTheme.typography.customStyles['heading']?.fontSize, 24);
      expect(customTheme.extensions['borderRadius'], 8.0);

      // 3. Convert to Flutter theme
      final flutterTheme = customTheme.toFlutterThemeData();
      expect(flutterTheme.colorScheme.primary, const Color(0xFF1976D2));

      // 4. Convert to JSON and back
      final json = customTheme.toJson();
      final reconstructed = KThemeData.fromJson(json);

      expect(reconstructed.id, customTheme.id);
      expect(reconstructed.name, customTheme.name);
      expect(
        reconstructed.colorScheme.primary,
        customTheme.colorScheme.primary,
      );
      expect(
        reconstructed.extensions['borderRadius'],
        customTheme.extensions['borderRadius'],
      );
    });

    test('should handle theme variations', () {
      final baseTheme =
          KQuickThemeBuilder.light(primaryColor: Colors.blue).build();

      // Create dark variant
      final darkTheme =
          KThemeBuilder()
              .fromTheme(baseTheme)
              .dark(true)
              .colorScheme(KColorScheme.dark.copyWith(primary: Colors.blue))
              .build();

      expect(darkTheme.isDark, true);
      expect(darkTheme.colorScheme.primary, Colors.blue);
      expect(darkTheme.colorScheme.surface, KColorScheme.dark.surface);

      // Create branded variant
      final brandedTheme =
          KThemeBuilder()
              .fromTheme(baseTheme)
              .name('Branded Theme')
              .customColor('brand', const Color(0xFF123456))
              .extension('brandConfig', {
                'feature1': true,
                'feature2': 'enabled',
              })
              .build();

      expect(brandedTheme.name, 'Branded Theme');
      expect(
        brandedTheme.colorScheme.customColors['brand'],
        const Color(0xFF123456),
      );
      expect(brandedTheme.extensions['brandConfig']['feature1'], true);
    });
  });
}
