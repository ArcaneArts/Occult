import 'dart:io';

import 'package:cli_annotations/cli_annotations.dart';
import 'package:fast_log/fast_log.dart';

import '../services/script_runner.dart';

part 'script_command.g.dart';

/// Manage and run scripts defined in pubspec.yaml
///
/// Execute scripts from the `scripts:` section of the nearest pubspec.yaml.
/// Supports fuzzy matching and abbreviations for script names.
///
/// Examples:
///   occult scripts                  # List all available scripts
///   occult scripts build            # Run the build script
///   occult scripts br               # Abbreviation for build_runner
@cliSubcommand
class ScriptsCommand extends _$ScriptsCommand {
  final ScriptRunner _runner = ScriptRunner();

  /// List all available scripts (default when no script specified)
  @cliCommand
  void list() {
    _runner.listScripts();
  }

  /// Execute a script by name
  ///
  /// Supports exact names, abbreviations, and fuzzy matching.
  @cliCommand
  Future<void> exec(
    String script, {
    bool stream = false,
  }) async {
    final exitCode = stream
        ? await _runner.runStreaming(script)
        : await _runner.run(script);

    if (exitCode != 0) {
      exit(exitCode);
    }
  }
}
