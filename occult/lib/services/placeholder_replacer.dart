import 'dart:io';

import 'package:fast_log/fast_log.dart';
import 'package:path/path.dart' as p;

import '../models/setup_config.dart';

/// Service for replacing placeholders in template files
///
/// Templates use canonical names (arcane_app, arcane_cli_app, etc.) that are
/// replaced with the user's actual app name when scaffolding a new project.
class PlaceholderReplacer {
  final SetupConfig config;

  PlaceholderReplacer(this.config);

  /// File extensions that should have placeholder replacement applied
  static const textFileExtensions = [
    '.dart',
    '.yaml',
    '.yml',
    '.json',
    '.md',
    '.txt',
    '.sh',
    '.xml',
    '.plist',
    '.xcconfig',
    '.xcscheme',
    '.pbxproj',
    '.swift',
    '.kt',
    '.kts',
    '.gradle',
    '.properties',
    '.cc',
    '.h',
    '.cmake',
    '.html',
    '.js',
    '.css',
    '.entitlements',
    '.storyboard',
    '.xib',
    '.xcworkspacedata',
  ];

  /// Check if a file should have placeholders replaced
  bool shouldProcessFile(String path) {
    final ext = p.extension(path).toLowerCase();
    return textFileExtensions.contains(ext);
  }

  /// Replace all placeholders in a string
  /// Templates use real working names that get replaced with user's names
  String replaceInContent(String content) {
    var result = content;

    // 1. Replace class names first (PascalCase patterns) to avoid double replacement
    // ArcaneServer -> MyAppServer
    result = result.replaceAll('ArcaneServer', config.serverClassName);

    // ArcaneRunner -> MyAppRunner
    result = result.replaceAll('ArcaneRunner', config.runnerClassName);

    // 2. Replace package imports - order matters, longer names first
    // package:arcane_beamer_app/ -> package:my_app/
    result = result.replaceAll(
      'package:arcane_beamer_app/',
      'package:${config.appName}/',
    );
    // package:arcane_dock_app/ -> package:my_app/
    result = result.replaceAll(
      'package:arcane_dock_app/',
      'package:${config.appName}/',
    );
    // package:arcane_cli_app/ -> package:my_app/
    result = result.replaceAll(
      'package:arcane_cli_app/',
      'package:${config.appName}/',
    );
    // package:arcane_app/ -> package:my_app/
    result = result.replaceAll(
      'package:arcane_app/',
      'package:${config.appName}/',
    );

    // 3. Replace models package references
    result = result.replaceAll(
      'package:arcane_models/',
      'package:${config.modelsPackageName}/',
    );
    result = result.replaceAll('arcane_models', config.modelsPackageName);

    // 4. Replace server package references
    result = result.replaceAll('arcane_server', config.serverPackageName);

    // 5. Replace app names in various contexts (order matters - longer names first)
    // These are the canonical template names
    result = result.replaceAll('arcane_beamer_app', config.appName);
    result = result.replaceAll('arcane_dock_app', config.appName);
    result = result.replaceAll('arcane_cli_app', config.appName);
    result = result.replaceAll('arcane_app', config.appName);

    // 6. Replace Firebase project ID
    if (config.firebaseProjectId != null) {
      result = result.replaceAll(
        'FIREBASE_PROJECT_ID',
        config.firebaseProjectId!,
      );
    }

    // 7. Replace organization domain patterns
    // art.arcane.template -> com.example.myapp
    result = result.replaceAll(
      'art.arcane.template',
      '${config.orgDomain}.${config.appName.replaceAll('_', '')}',
    );
    result = result.replaceAll('ORG_DOMAIN', config.orgDomain);

    // 8. Replace display names in platform configs (e.g., Windows, Linux titles)
    // These show up in window titles, app manifests, etc.
    result = result.replaceAll('Arcane Template', config.baseClassName);
    result = result.replaceAll('Arcane Beamer', config.baseClassName);
    result = result.replaceAll('Arcane Dock', config.baseClassName);
    result = result.replaceAll('Arcane CLI', config.baseClassName);

    return result;
  }

  /// Get the new filename after placeholder replacement
  String replaceInFilename(String filename) {
    var result = filename;

    // arcane_models.dart -> my_app_models.dart
    result = result.replaceAll('arcane_models', config.modelsPackageName);

    // arcane_cli_app.dart -> my_app.dart (and .g.dart files)
    result = result.replaceAll('arcane_cli_app', config.appName);
    result = result.replaceAll('arcane_beamer_app', config.appName);
    result = result.replaceAll('arcane_dock_app', config.appName);
    result = result.replaceAll('arcane_app', config.appName);

    return result;
  }

  /// Process a single file - replace placeholders in content and rename if needed
  Future<void> processFile(File file) async {
    final path = file.path;

    if (shouldProcessFile(path)) {
      // Read and replace content
      var content = await file.readAsString();
      final newContent = replaceInContent(content);

      if (content != newContent) {
        await file.writeAsString(newContent);
        verbose('  Replaced placeholders in: ${p.basename(path)}');
      }
    }

    // Check if filename needs replacing
    final filename = p.basename(path);
    final newFilename = replaceInFilename(filename);

    if (filename != newFilename) {
      final newPath = p.join(p.dirname(path), newFilename);
      await file.rename(newPath);
      verbose('  Renamed: $filename -> $newFilename');
    }
  }

  /// Process all files in a directory recursively
  Future<void> processDirectory(Directory dir) async {
    info('Processing placeholders in: ${dir.path}');

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        await processFile(entity);
      } else if (entity is Directory) {
        // Check if directory name needs replacing
        final dirName = p.basename(entity.path);
        final newDirName = replaceInFilename(dirName);

        if (dirName != newDirName) {
          final newPath = p.join(p.dirname(entity.path), newDirName);
          await entity.rename(newPath);
          verbose('  Renamed directory: $dirName -> $newDirName');
        }
      }
    }
  }

  /// Handle conditional imports in CLI template
  /// Uncomments lines based on configuration
  Future<void> processConditionalImports(File file) async {
    if (!file.existsSync()) return;

    var content = await file.readAsString();
    var modified = false;

    // Handle Firebase imports
    if (config.useFirebase) {
      final firebasePattern = RegExp(r'// FIREBASE_IMPORT: (.+)');
      content = content.replaceAllMapped(firebasePattern, (match) {
        modified = true;
        return match.group(1)!;
      });
    }

    // Handle server command imports
    if (config.createServer) {
      final serverPattern = RegExp(r'// SERVER_COMMAND_IMPORT: (.+)');
      content = content.replaceAllMapped(serverPattern, (match) {
        modified = true;
        return match.group(1)!;
      });
    }

    // Handle models imports
    if (config.createModels) {
      final modelsPattern = RegExp(r'// MODELS_IMPORT: (.+)');
      content = content.replaceAllMapped(modelsPattern, (match) {
        modified = true;
        return match.group(1)!;
      });
    }

    if (modified) {
      await file.writeAsString(content);
      verbose('  Processed conditional imports in: ${p.basename(file.path)}');
    }
  }

  /// Update pubspec.yaml with correct name and optional dependencies
  Future<void> updatePubspec(File pubspecFile, String packageName) async {
    if (!pubspecFile.existsSync()) return;

    var content = await pubspecFile.readAsString();

    // Update package name
    content = content.replaceFirst(
      RegExp(r'^name: .+$', multiLine: true),
      'name: $packageName',
    );

    // Handle conditional dependencies
    if (config.createModels) {
      // Uncomment models dependency
      content = content.replaceAll(
        RegExp(r'#\s*${config.modelsPackageName}:'),
        '${config.modelsPackageName}:',
      );
    }

    // Handle Firebase dependencies
    if (config.useFirebase) {
      // Uncomment Firebase packages
      final firebasePackages = [
        'firebase_core',
        'firebase_auth',
        'cloud_firestore',
        'firebase_storage',
        'arcane_fluf',
        'arcane_auth',
        'fire_crud',
      ];
      for (final pkg in firebasePackages) {
        content = content.replaceAll(RegExp(r'#\s*' + pkg + r':'), '$pkg:');
      }
    }

    await pubspecFile.writeAsString(content);
    verbose('  Updated pubspec.yaml for: $packageName');
  }

  /// Add models dependency to a project's pubspec.yaml
  Future<void> addModelsDependency(File pubspecFile) async {
    if (!pubspecFile.existsSync()) return;

    var content = await pubspecFile.readAsString();

    // Check if dependency already exists
    if (content.contains('${config.modelsPackageName}:')) {
      return;
    }

    // Find the dependencies section and add models dependency
    final dependenciesPattern = RegExp(r'^dependencies:\s*$', multiLine: true);
    final match = dependenciesPattern.firstMatch(content);

    if (match != null) {
      final insertPosition = match.end;
      final modelsDep =
          '''

  ${config.modelsPackageName}:
    path: ../${config.modelsPackageName}
''';
      content =
          content.substring(0, insertPosition) +
          modelsDep +
          content.substring(insertPosition);

      await pubspecFile.writeAsString(content);
      verbose('  Added models dependency to: ${p.basename(pubspecFile.path)}');
    }
  }
}
