library occult;

import 'package:cli_annotations/cli_annotations.dart';
import 'package:fast_log/fast_log.dart';

import 'commands/check_command.dart';
import 'commands/config_command.dart';
import 'commands/create_command.dart';
import 'commands/deploy_command.dart';
import 'commands/gui_command.dart';
import 'commands/hello_command.dart';

part 'occult.g.dart';

/// Occult CLI - Arcane Template System
///
/// Create production-ready Flutter and Dart projects using the Arcane UI framework.
/// Supports multi-project architecture with client, models, and server packages.
///
/// Usage:
///   occult                       # Launch interactive wizard
///   occult gui                   # Launch GUI wizard
///   occult create                # Create new project
///   occult check tools           # Verify CLI tools
///   occult deploy all            # Deploy Firebase resources
@cliRunner
class OccultRunner extends _$OccultRunner {
  OccultRunner() {
    verbose("OccultRunner initialized");
  }

  /// Create new Arcane projects
  @cliMount
  CreateCommand get create => CreateCommand();

  /// Check CLI tool availability
  @cliMount
  CheckCommand get check => CheckCommand();

  /// Firebase and server deployment
  @cliMount
  DeployCommand get deploy => DeployCommand();

  /// Configuration management
  @cliMount
  ConfigCommand get config => ConfigCommand();

  /// Launch the graphical wizard
  @cliMount
  GuiCommand get gui => GuiCommand();

  /// Hello world demo command
  @cliMount
  HelloCommand get hello => HelloCommand();
}
