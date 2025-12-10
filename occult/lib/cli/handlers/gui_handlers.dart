import 'dart:io';

import 'package:fast_log/fast_log.dart';
import 'package:path/path.dart' as p;

/// Launch the GUI wizard
Future<void> handleGuiLaunch(Map<String, dynamic> args, Map<String, dynamic> flags) async {
  info("Launching Occult GUI wizard...");

  final guiPath = await _findGuiPath();

  if (guiPath == null) {
    error("Could not find occult_gui project.");
    error("The GUI project should be located at: ../occult_gui relative to occult");
    exit(1);
  }

  verbose("Found GUI at: $guiPath");

  // Build flutter run command
  final flutterArgs = <String>['run'];

  // Add platform if specified
  final platform = args['platform'] as String?;
  if (platform != null) {
    flutterArgs.addAll(['-d', platform]);
  }

  // Add release mode if requested
  if (flags['release'] == true) {
    flutterArgs.add('--release');
  }

  info("Starting Flutter app...");
  verbose("Command: flutter ${flutterArgs.join(' ')}");

  // Run the GUI
  final process = await Process.start(
    'flutter',
    flutterArgs,
    workingDirectory: guiPath,
    mode: ProcessStartMode.inheritStdio,
  );

  final exitCode = await process.exitCode;

  if (exitCode != 0) {
    error("GUI exited with code $exitCode");
    exit(exitCode);
  }
}

/// Build the GUI for distribution
Future<void> handleGuiBuild(Map<String, dynamic> args, Map<String, dynamic> flags) async {
  final platform = args['platform'] as String? ?? 'macos';
  info("Building Occult GUI for $platform...");

  final guiPath = await _findGuiPath();

  if (guiPath == null) {
    error("Could not find occult_gui project.");
    exit(1);
  }

  final flutterArgs = ['build', platform, '--release'];

  info("Running: flutter ${flutterArgs.join(' ')}");

  final result = await Process.run(
    'flutter',
    flutterArgs,
    workingDirectory: guiPath,
    runInShell: Platform.isWindows,
  );

  if (result.exitCode == 0) {
    success("Build completed successfully!");
    info("Output: $guiPath/build/$platform/");
  } else {
    error("Build failed: ${result.stderr}");
    exit(result.exitCode);
  }
}

/// Find the GUI project path
Future<String?> _findGuiPath() async {
  final possiblePaths = [
    // Relative to Occult directory
    p.join(Directory.current.path, '..', 'occult_gui'),
    p.join(Directory.current.path, 'occult_gui'),
    // Check if we're in the Occult parent directory
    p.join(Directory.current.path, 'Occult', 'occult_gui'),
    // Platform-specific install locations (for compiled versions)
    if (Platform.isMacOS) ...[
      p.join(Platform.environment['HOME'] ?? '', '.occult', 'gui'),
      '/Applications/OccultGUI.app/Contents/MacOS',
    ],
    if (Platform.isLinux) ...[
      p.join(Platform.environment['HOME'] ?? '', '.occult', 'gui'),
      '/usr/local/share/occult/gui',
    ],
    if (Platform.isWindows) ...[
      p.join(Platform.environment['LOCALAPPDATA'] ?? '', 'Occult', 'gui'),
    ],
  ];

  for (final path in possiblePaths) {
    final normalized = p.normalize(path);
    final dir = Directory(normalized);
    if (dir.existsSync()) {
      // Check if it's a valid Flutter project
      final pubspec = File(p.join(normalized, 'pubspec.yaml'));
      if (pubspec.existsSync()) {
        return normalized;
      }
    }
  }

  // Try to find it relative to the script location
  final scriptPath = Platform.script.toFilePath();
  final scriptDir = p.dirname(scriptPath);
  final parentOfScript = p.dirname(p.dirname(scriptDir));
  final guiFromScript = p.join(parentOfScript, 'occult_gui');

  if (Directory(guiFromScript).existsSync()) {
    return guiFromScript;
  }

  return null;
}
