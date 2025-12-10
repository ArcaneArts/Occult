import 'dart:io';

import 'package:fast_log/fast_log.dart';
import 'package:path/path.dart' as p;

import '../models/setup_config.dart';
import '../utils/string_utils.dart';

/// Service for replacing placeholders in template files
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
  /// IMPORTANT: Order matters! Class names (PascalCase) must be replaced BEFORE snake_case
  String replaceInContent(String content) {
    var result = content;

    // 1. Replace class names first (PascalCase patterns) to avoid double replacement
    // APPNAMEServer -> MyAppServer
    result = result.replaceAll('APPNAMEServer', config.serverClassName);

    // APPNAMERunner -> MyAppRunner
    result = result.replaceAll('APPNAMERunner', config.runnerClassName);

    // APPNAME in PascalCase context (like class names)
    // Be careful here - only replace when followed by typical class name contexts
    result = result.replaceAll(RegExp(r'APPNAME(?=[A-Z])'), config.baseClassName);

    // 2. Replace snake_case patterns
    // APPNAME -> my_app (in most contexts)
    result = result.replaceAll('APPNAME', config.appName);

    // 3. Replace Firebase project ID
    if (config.firebaseProjectId != null) {
      result = result.replaceAll('FIREBASE_PROJECT_ID', config.firebaseProjectId!);
    }

    // 4. Replace organization domain
    result = result.replaceAll('ORG_DOMAIN', config.orgDomain);

    // 5. Replace package imports
    // package:arcane_template/ -> package:my_app/
    // package:arcane_beamer/ -> package:my_app/
    // etc.
    result = result.replaceAll('package:arcane_template/', 'package:${config.appName}/');
    result = result.replaceAll('package:arcane_beamer/', 'package:${config.appName}/');
    result = result.replaceAll('package:arcane_dock/', 'package:${config.appName}/');
    result = result.replaceAll('package:arcane_cli/', 'package:${config.appName}/');

    // 6. Replace models package imports
    result = result.replaceAll('package:models_template/', 'package:${config.modelsPackageName}/');
    result = result.replaceAll('package:APPNAME_models/', 'package:${config.modelsPackageName}/');

    return result;
  }

  /// Get the new filename after placeholder replacement
  String replaceInFilename(String filename) {
    var result = filename;

    // APPNAME_models.dart -> my_app_models.dart
    result = result.replaceAll('APPNAME_models', '${config.appName}_models');

    // APPNAME.dart -> my_app.dart
    result = result.replaceAll('APPNAME', config.appName);

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
      ];
      for (final pkg in firebasePackages) {
        content = content.replaceAll(
          RegExp(r'#\s*' + pkg + r':'),
          '$pkg:',
        );
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
      final modelsDep = '''

  ${config.modelsPackageName}:
    path: ../${config.modelsPackageName}
''';
      content = content.substring(0, insertPosition) +
          modelsDep +
          content.substring(insertPosition);

      await pubspecFile.writeAsString(content);
      verbose('  Added models dependency to: ${p.basename(pubspecFile.path)}');
    }
  }
}
