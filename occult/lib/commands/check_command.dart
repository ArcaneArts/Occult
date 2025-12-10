import 'package:cli_annotations/cli_annotations.dart';
import 'package:fast_log/fast_log.dart';

import '../services/tool_checker.dart';

part 'check_command.g.dart';

/// Commands for checking CLI tool availability
///
/// Verifies that required tools are installed and displays version information.
@cliSubcommand
class CheckCommand extends _$CheckCommand {
  final ToolChecker _checker = ToolChecker();

  /// Check all tools (required and optional)
  ///
  /// Displays a summary of all tools needed for Occultist operations,
  /// including Flutter, Dart, Firebase CLI, gcloud, Docker, etc.
  @cliCommand
  Future<void> tools() async {
    final result = await _checker.checkAll();
    result.printSummary();

    if (!result.allRequiredInstalled) {
      error(
        'Some required tools are missing. Please install them before continuing.',
      );
    } else {
      success('All required tools are installed!');
    }
  }

  /// Check Flutter installation
  ///
  /// Verifies Flutter is installed and displays version information.
  @cliCommand
  Future<void> flutter() async {
    final status = await _checker.checkFlutter();
    print('');
    print('Flutter Status:');
    print('\u2500' * 40);

    if (status.isInstalled) {
      success('Flutter is installed');
      print('Version: ${status.version}');
    } else {
      error('Flutter is not installed');
      print('Install: ${status.installInstructions}');
    }
  }

  /// Check Firebase CLI tools
  ///
  /// Verifies Firebase CLI and FlutterFire CLI are installed.
  @cliCommand
  Future<void> firebase() async {
    final result = await _checker.checkFirebaseTools();
    result.printSummary();
  }

  /// Check Docker installation
  ///
  /// Verifies Docker is installed for server deployment.
  @cliCommand
  Future<void> docker() async {
    final status = await _checker.checkDocker();
    print('');
    print('Docker Status:');
    print('\u2500' * 40);

    if (status.isInstalled) {
      success('Docker is installed');
      print('Version: ${status.version}');
    } else {
      warn('Docker is not installed (needed for server deployment)');
      print('Install: ${status.installInstructions}');
    }
  }

  /// Check Google Cloud SDK installation
  ///
  /// Verifies gcloud is installed for Cloud Run deployment.
  @cliCommand
  Future<void> gcloud() async {
    final status = await _checker.checkGcloud();
    print('');
    print('Google Cloud SDK Status:');
    print('\u2500' * 40);

    if (status.isInstalled) {
      success('Google Cloud SDK is installed');
      print('Version: ${status.version}');
    } else {
      warn(
        'Google Cloud SDK is not installed (needed for Cloud Run deployment)',
      );
      print('Install: ${status.installInstructions}');
    }
  }

  /// Run flutter doctor
  ///
  /// Runs `flutter doctor -v` and displays the output.
  @cliCommand
  Future<void> doctor() async {
    info('Running flutter doctor...');
    print('');

    final output = await _checker.runFlutterDoctor();
    print(output);
  }

  /// Check server deployment tools
  ///
  /// Verifies Docker and gcloud are installed for server deployment.
  @cliCommand
  Future<void> server() async {
    final result = await _checker.checkServerTools();
    result.printSummary();
  }
}
