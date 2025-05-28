import 'package:flutter/material.dart';
import 'package:k_skin/k_skin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 注意：KThemeManager 不需要初始化，如果需要皮肤包功能，可以初始化 SkinManager
  // await SkinManager().initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return KThemeProvider(
      child: Builder(
        builder: (context) {
          return MaterialApp(
            title: 'K Skin Example',
            theme: KThemeProvider.of(context).toFlutterThemeData(),
            home: MyHomePage(),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = KThemeProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('K Skin Example'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 主题信息卡片
            _buildThemeInfoCard(theme),

            const SizedBox(height: 20),

            // 主题切换器
            Text('主题切换器', style: theme.typography.headlineSmall),
            const SizedBox(height: 8),
            KThemeSwitcher(),

            const SizedBox(height: 20),

            // 颜色展示
            Text('颜色方案', style: theme.typography.headlineSmall),
            const SizedBox(height: 8),
            _buildColorDisplay(theme),

            const SizedBox(height: 20),

            // 快速创建主题
            Text('快速主题', style: theme.typography.headlineSmall),
            const SizedBox(height: 8),
            _buildQuickThemeButtons(),

            const SizedBox(height: 20),

            // 主题网格选择器
            Text('主题选择器', style: theme.typography.headlineSmall),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: KThemeGridSelector(
                crossAxisCount: 2,
                onThemeChanged: (selectedTheme) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('选择了主题: ${selectedTheme.name}')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCustomThemeDialog,
        tooltip: '创建自定义主题',
        child: const Icon(Icons.palette),
      ),
    );
  }

  Widget _buildThemeInfoCard(KThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前主题信息', style: theme.typography.headlineSmall),
            const SizedBox(height: 8),
            _buildInfoRow('主题名称', theme.name, theme),
            _buildInfoRow('主题 ID', theme.id, theme),
            _buildInfoRow('版本', theme.version, theme),
            if (theme.author != null) _buildInfoRow('作者', theme.author!, theme),
            _buildInfoRow('类型', theme.isDark ? '暗色主题' : '亮色主题', theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, KThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: theme.typography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(child: Text(value, style: theme.typography.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildColorDisplay(KThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildColorChip('Primary', theme.colorScheme.primary),
        _buildColorChip('Secondary', theme.colorScheme.secondary),
        _buildColorChip('Surface', theme.colorScheme.surface),
        _buildColorChip('Error', theme.colorScheme.error),
        ...theme.colorScheme.customColors.entries.map(
          (entry) => _buildColorChip(entry.key, entry.value),
        ),
      ],
    );
  }

  Widget _buildColorChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildQuickThemeButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton(
          onPressed: () => _applyQuickTheme('ocean'),
          child: Text('Ocean'),
        ),
        ElevatedButton(
          onPressed: () => _applyQuickTheme('forest'),
          child: Text('Forest'),
        ),
        ElevatedButton(
          onPressed: () => _applyQuickTheme('sunset'),
          child: Text('Sunset'),
        ),
        ElevatedButton(
          onPressed: () => _applyQuickTheme('night'),
          child: Text('Night'),
        ),
        ElevatedButton(
          onPressed: _applyMaterial3Theme,
          child: Text('Material 3'),
        ),
      ],
    );
  }

  void _applyQuickTheme(String template) async {
    final theme = KQuickThemeBuilder.preset(template).build();
    KThemeManager.instance.addTheme(theme, makeActive: true);
  }

  void _applyMaterial3Theme() async {
    final theme =
        KQuickThemeBuilder.light(
          name: 'Material 3 Theme',
          primaryColor: Colors.deepPurple,
          secondaryColor: Colors.deepPurpleAccent,
        ).build();
    KThemeManager.instance.addTheme(theme, makeActive: true);
  }

  void _showCustomThemeDialog() {
    showDialog(context: context, builder: (context) => CustomThemeDialog());
  }
}

class CustomThemeDialog extends StatefulWidget {
  const CustomThemeDialog({super.key});

  @override
  State<CustomThemeDialog> createState() => _CustomThemeDialogState();
}

class _CustomThemeDialogState extends State<CustomThemeDialog> {
  final _nameController = TextEditingController();
  Color _primaryColor = Colors.blue;
  Color _secondaryColor = Colors.cyan;
  bool _isDark = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('创建自定义主题'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '主题名称',
                hintText: '输入主题名称',
              ),
            ),
            const SizedBox(height: 16),

            ListTile(
              title: const Text('主要颜色'),
              trailing: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              onTap: () => _pickColor('primary'),
            ),

            ListTile(
              title: const Text('次要颜色'),
              trailing: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _secondaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              onTap: () => _pickColor('secondary'),
            ),

            SwitchListTile(
              title: const Text('暗色主题'),
              value: _isDark,
              onChanged: (value) {
                setState(() {
                  _isDark = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(onPressed: _createTheme, child: const Text('创建')),
      ],
    );
  }

  void _pickColor(String type) {
    // 这里可以集成颜色选择器，简化起见使用预设颜色
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('选择颜色'),
            content: Wrap(
              children:
                  colors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (type == 'primary') {
                            _primaryColor = color;
                          } else {
                            _secondaryColor = color;
                          }
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
    );
  }

  void _createTheme() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入主题名称')));
      return;
    }

    final theme =
        KThemeBuilder()
            .id('custom_${DateTime.now().millisecondsSinceEpoch}')
            .name(name)
            .version('1.0.0')
            .dark(_isDark)
            .primaryColor(_primaryColor)
            .secondaryColor(_secondaryColor)
            .extension('borderRadius', 12.0)
            .extension('cardElevation', 4.0)
            .build();

    KThemeManager.instance.addTheme(theme, makeActive: true);

    Navigator.of(context).pop();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('主题 "$name" 创建成功！')));
  }
}
