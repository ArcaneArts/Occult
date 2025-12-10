import 'dart:io';

import 'package:fast_log/fast_log.dart';
import 'package:path/path.dart' as p;

import '../models/setup_config.dart';
import '../models/template_info.dart';
import 'placeholder_replacer.dart';

/// Service for copying and customizing templates
class TemplateCopier {
  final SetupConfig config;
  late final PlaceholderReplacer _replacer;

  /// Path to the templates directory (sibling to occult package)
  late final String templatesBasePath;

  TemplateCopier(this.config) {
    _replacer = PlaceholderReplacer(config);
    templatesBasePath = _findTemplatesPath();
  }

  /// Find the templates directory
  /// Templates are now in a sibling 'templates/' folder, not embedded in lib/
  String _findTemplatesPath() {
    // Try to find templates relative to the script
    final scriptPath = Platform.script.toFilePath();
    final scriptDir = p.dirname(scriptPath);

    // Check various possible locations
    final possiblePaths = [
      // When running from pub global activate - templates sibling to package
      p.join(scriptDir, '..', '..', 'templates'),
      // When running locally with dart run from occult/ directory
      p.join(scriptDir, '..', '..', 'templates'),
      // When running from the occult package directory
      p.join(Directory.current.path, '..', 'templates'),
      // When running from the Occult monorepo root
      p.join(Directory.current.path, 'templates'),
      // Absolute path for development
      '/Users/brianfopiano/Developer/RemoteGit/ArcaneArts/Occult/templates',
    ];

    for (final path in possiblePaths) {
      final normalizedPath = p.normalize(path);
      if (Directory(normalizedPath).existsSync()) {
        verbose('Found templates at: $normalizedPath');
        return normalizedPath;
      }
    }

    // Fallback to current directory
    warn('Templates directory not found, using current directory');
    return p.join(Directory.current.path, 'templates');
  }

  /// Get the path to a specific template
  String getTemplatePath(String templateName) {
    return p.join(templatesBasePath, templateName);
  }

  /// Copy the main app template to the output directory
  Future<void> copyAppTemplate() async {
    final templateDir = Directory(
      getTemplatePath(config.template.directoryName),
    );
    final targetDir = Directory(p.join(config.outputDir, config.appName));

    if (!templateDir.existsSync()) {
      throw Exception('Template not found: ${templateDir.path}');
    }

    info('Copying ${config.template.displayName} template...');

    // Copy template files
    await _copyDirectory(templateDir, targetDir);

    // Process placeholders
    await _replacer.processDirectory(targetDir);

    // Update pubspec
    final pubspecFile = File(p.join(targetDir.path, 'pubspec.yaml'));
    await _replacer.updatePubspec(pubspecFile, config.appName);

    // Add models dependency if needed
    if (config.createModels) {
      await _replacer.addModelsDependency(pubspecFile);
    }

    success('App template copied to: ${targetDir.path}');
  }

  /// Copy the models template
  Future<void> copyModelsTemplate() async {
    if (!config.createModels) return;

    final templateDir = Directory(getTemplatePath('arcane_models'));
    final targetDir = Directory(
      p.join(config.outputDir, config.modelsPackageName),
    );

    if (!templateDir.existsSync()) {
      throw Exception('Models template not found: ${templateDir.path}');
    }

    info('Copying models template...');

    // Copy template files
    await _copyDirectory(templateDir, targetDir);

    // Process placeholders
    await _replacer.processDirectory(targetDir);

    // Update pubspec
    final pubspecFile = File(p.join(targetDir.path, 'pubspec.yaml'));
    await _replacer.updatePubspec(pubspecFile, config.modelsPackageName);

    success('Models package created at: ${targetDir.path}');
  }

  /// Copy the server template
  Future<void> copyServerTemplate() async {
    if (!config.createServer) return;

    final templateDir = Directory(getTemplatePath('arcane_server'));
    final targetDir = Directory(
      p.join(config.outputDir, config.serverPackageName),
    );

    if (!templateDir.existsSync()) {
      throw Exception('Server template not found: ${templateDir.path}');
    }

    info('Copying server template...');

    // Copy template files
    await _copyDirectory(templateDir, targetDir);

    // Process placeholders
    await _replacer.processDirectory(targetDir);

    // Update pubspec
    final pubspecFile = File(p.join(targetDir.path, 'pubspec.yaml'));
    await _replacer.updatePubspec(pubspecFile, config.serverPackageName);

    // Add models dependency if needed
    if (config.createModels) {
      await _replacer.addModelsDependency(pubspecFile);
    }

    success('Server app created at: ${targetDir.path}');
  }

  /// Copy the references folder
  Future<void> copyReferences() async {
    final templateDir = Directory(getTemplatePath('references'));
    final targetDir = Directory(p.join(config.outputDir, 'references'));

    if (!templateDir.existsSync()) {
      warn('References directory not found, skipping');
      return;
    }

    info('Copying references...');

    await _copyDirectory(templateDir, targetDir);

    success('References copied to: ${targetDir.path}');
  }

  /// Copy a directory recursively
  Future<void> _copyDirectory(Directory source, Directory target) async {
    if (!target.existsSync()) {
      await target.create(recursive: true);
    }

    await for (final entity in source.list(recursive: false)) {
      final targetPath = p.join(target.path, p.basename(entity.path));

      if (entity is Directory) {
        // Skip certain directories
        final dirName = p.basename(entity.path);
        if (_shouldSkipDirectory(dirName)) {
          continue;
        }

        final newDirectory = Directory(targetPath);
        await _copyDirectory(entity, newDirectory);
      } else if (entity is File) {
        // Skip certain files
        final fileName = p.basename(entity.path);
        if (_shouldSkipFile(fileName)) {
          continue;
        }

        await entity.copy(targetPath);
      }
    }
  }

  /// Check if a directory should be skipped during copy
  bool _shouldSkipDirectory(String dirName) {
    const skipDirs = [
      '.dart_tool',
      '.idea',
      '.git',
      'build',
      '.gradle',
      'Pods',
    ];
    return skipDirs.contains(dirName);
  }

  /// Check if a file should be skipped during copy
  bool _shouldSkipFile(String fileName) {
    const skipFiles = [
      '.DS_Store',
      'pubspec.lock',
      '.flutter-plugins',
      '.flutter-plugins-dependencies',
      '.packages',
      '.metadata',
    ];

    // Skip generated dart files
    if (fileName.endsWith('.g.dart')) return true;

    return skipFiles.contains(fileName);
  }

  /// Copy all templates based on config
  Future<void> copyAll() async {
    info('Starting template copy...');

    // Create output directory if needed
    final outputDir = Directory(config.outputDir);
    if (!outputDir.existsSync()) {
      await outputDir.create(recursive: true);
    }

    // Copy main app template
    await copyAppTemplate();

    // Copy models if enabled
    if (config.createModels) {
      await copyModelsTemplate();
    }

    // Copy server if enabled
    if (config.createServer) {
      await copyServerTemplate();
    }

    // Always copy references
    await copyReferences();

    success('All templates copied successfully!');
  }

  /// Get list of files that would be copied (dry run)
  Future<List<String>> getFilesToCopy() async {
    final files = <String>[];

    // Main app
    final appTemplate = Directory(
      getTemplatePath(config.template.directoryName),
    );
    if (appTemplate.existsSync()) {
      await for (final entity in appTemplate.list(recursive: true)) {
        if (entity is File) {
          files.add(p.relative(entity.path, from: appTemplate.path));
        }
      }
    }

    return files;
  }
}
