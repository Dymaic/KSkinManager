# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.2] - Unreleased

### Fixed
- 🐛 解决了暗色自定义主题的黑屏问题
  - 修复了 `_createTheme()` 方法中调用顺序的问题，现在先调用 `.dark()` 再设置颜色
  - 添加了 `KSkinFixes` 工具类来验证主题并自动修复潜在问题
  - 改进了日志系统以便于调试主题切换问题

### Changed
- 🔄 优化了 `KThemeBuilder` 类以正确处理扩展方法
- 📊 增强了调试功能以追踪主题创建、切换和应用过程
- 🔧 将 `withValues(alpha: x)` 替换为兼容的 Flutter API `withOpacity(x)`

### Added
- 🔍 新增主题验证功能，在切换主题时自动检测并修复潜在问题
- 🧪 添加测试工具来验证主题切换和修复功能

## [0.0.1] - 2025-05-27

### Added
- 🎨 **可扩展颜色系统** - 支持自定义颜色和 Material Design 3
- 📚 **动态资源管理** - 统一管理图像、字体、图标资源  
- 🌐 **网络皮肤下载** - 支持从网络下载和安装皮肤包
- 🔄 **实时主题切换** - 无缝的主题切换体验
- 🏗️ **流畅构建 API** - 简洁的链式 API 构建自定义主题
- 📱 **Material Design 3** - 完全支持 Material 3 设计规范

### Core Components
- `KThemeManager` - 主题管理器，负责主题的加载、切换和持久化
- `KThemeProvider` - 主题提供者 Widget，为子组件提供主题数据
- `KThemeData` - 主题数据类，包含完整的主题信息
- `KColorScheme` - 颜色方案，管理应用的颜色系统
- `KTypography` - 排版系统，管理文本样式
- `KResourceManager` - 资源管理器，统一管理应用资源

### Theme Builders
- `KThemeBuilder` - 通用主题构建器，提供链式 API
- `QuickThemeBuilder` - 快速主题构建器，提供预设模板

### UI Components
- `KThemeSwitcher` - 主题切换下拉选择器
- `KThemeGridSelector` - 主题网格选择器

### Skin Management
- `KSkinManager` - 皮肤包管理器
- `SkinPackage` - 皮肤包数据类
- `SkinDownloader` - 网络皮肤下载器

### Theme Templates
- Ocean 主题 - 海洋蓝色调
- Forest 主题 - 森林绿色调
- Sunset 主题 - 日落橙色调
- Night 主题 - 夜间深色调

### Technical Improvements
- ✅ 完整的单元测试覆盖
- ✅ 符合 Flutter 最新标准
- ✅ 支持 Material Design 3
- ✅ 零编译警告和错误
- ✅ 完整的 API 文档

### Initial Release Features
- 基础主题系统架构
- 颜色方案和排版系统
- 资源管理功能
- 主题构建器和快速模板
- 网络皮肤包支持
- UI 组件库
- 完整的测试套件
