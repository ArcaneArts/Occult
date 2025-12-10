import 'dart:io';

import 'package:cli_annotations/cli_annotations.dart';
import 'package:fast_log/fast_log.dart';
import 'package:path/path.dart' as p;

part 'gui_command.g.dart';

/// GUI command - launch the Occult GUI wizard
@cliSubcommand
class GuiCommand extends _$GuiCommand {
  /// Launch the Occult GUI wizard application
  ///
  /// Starts the graphical project creation wizard. The GUI provides
  /// a visual interface for creating Arcane projects with:
  /// - Step-by-step wizard flow
  /// - Template selection with descriptions
  /// - Real-time validation
  /// - Progress tracking during project creation
  @cliCommand
  Future<void> launch({
    /// Platform to run on (macos, linux, windows)
    String? platform,

    /// Run in release mode
    bool release = false,
  }) async {
    info("Launching Occult GUI wizard...");

    // Find the occult_gui directory relative to the CLI
    final guiPath = await _findGuiPath();

    if (guiPath == null) {
      error("Could not find occult_gui project.");
      error(
          "The GUI project should be located at: ../occult_gui relative to occult");
      exit(1);
    }

    verbose("Found GUI at: $guiPath");

    // Build flutter run command
    final args = <String>['run'];

    // Add platform if specified
    if (platform != null) {
      args.addAll(['-d', platform]);
    }

    // Add release mode if requested
    if (release) {
      args.add('--release');
    }

    info("Starting Flutter app...");
    verbose("Command: flutter ${args.join(' ')}");

    // Run the GUI
    final process = await Process.start(
      'flutter',
      args,
      workingDirectory: guiPath,
      mode: ProcessStartMode.inheritStdio,
    );

    final exitCode = await process.exitCode;

    if (exitCode != 0) {
      error("GUI exited with code $exitCode");
      exit(exitCode);
    }
  }

  /// Build the Occult GUI for distribution
  ///
  /// Creates a release build of the GUI application
  @cliCommand
  Future<void> build({
    /// Platform to build for (macos, linux, windows)
    String platform = 'macos',
  }) async {
    info("Building Occult GUI for $platform...");

    final guiPath = await _findGuiPath();

    if (guiPath == null) {
      error("Could not find occult_gui project.");
      exit(1);
    }

    final args = ['build', platform, '--release'];

    info("Running: flutter ${args.join(' ')}");

    final result = await Process.run(
      'flutter',
      args,
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

  Future<String?> _findGuiPath() async {
    // Try to find occult_gui relative to this CLI project
    // When running from source: ../occult_gui
    // When running from compiled binary: check common locations

    // First, try relative to script/current directory
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
    // This helps when the CLI is activated globally
    final scriptPath = Platform.script.toFilePath();
    final scriptDir = p.dirname(scriptPath);
    final parentOfScript = p.dirname(p.dirname(scriptDir));
    final guiFromScript = p.join(parentOfScript, 'occult_gui');

    if (Directory(guiFromScript).existsSync()) {
      return guiFromScript;
    }

    return null;
  }
}
