import 'dart:io';

import 'package:fast_log/fast_log.dart';

import '../models/tool_status.dart';
import '../utils/process_runner.dart';

/// Service for checking CLI tool availability
class ToolChecker {
  final ProcessRunner _runner;

  ToolChecker({ProcessRunner? runner}) : _runner = runner ?? ProcessRunner();

  /// Check if Flutter is installed and get version
  Future<ToolStatus> checkFlutter() async {
    final exists = await _runner.commandExists('flutter');
    if (!exists) {
      return ToolStatus.missing(
        'Flutter',
        'https://docs.flutter.dev/get-started/install',
        isRequired: true,
      );
    }

    final version = await _runner.getCommandVersion('flutter');
    return ToolStatus.installed('Flutter', version ?? 'unknown', isRequired: true);
  }

  /// Check if Dart is installed and get version
  Future<ToolStatus> checkDart() async {
    final exists = await _runner.commandExists('dart');
    if (!exists) {
      return ToolStatus.missing(
        'Dart',
        'Installed with Flutter, run: flutter doctor',
        isRequired: true,
      );
    }

    final version = await _runner.getCommandVersion('dart');
    return ToolStatus.installed('Dart', version ?? 'unknown', isRequired: true);
  }

  /// Check if Firebase CLI is installed
  Future<ToolStatus> checkFirebase() async {
    final exists = await _runner.commandExists('firebase');
    if (!exists) {
      return ToolStatus.missing(
        'Firebase CLI',
        'npm install -g firebase-tools',
        isRequired: false,
      );
    }

    final version = await _runner.getCommandVersion('firebase');
    return ToolStatus.installed('Firebase CLI', version ?? 'unknown', isRequired: false);
  }

  /// Check if FlutterFire CLI is installed
  Future<ToolStatus> checkFlutterFire() async {
    final exists = await _runner.commandExists('flutterfire');
    if (!exists) {
      return ToolStatus.missing(
        'FlutterFire CLI',
        'dart pub global activate flutterfire_cli',
        isRequired: false,
      );
    }

    final version = await _runner.getCommandVersion('flutterfire');
    return ToolStatus.installed('FlutterFire CLI', version ?? 'unknown', isRequired: false);
  }

  /// Check if gcloud is installed
  Future<ToolStatus> checkGcloud() async {
    final exists = await _runner.commandExists('gcloud');
    if (!exists) {
      return ToolStatus.missing(
        'Google Cloud SDK',
        'https://cloud.google.com/sdk/docs/install',
        isRequired: false,
      );
    }

    final version = await _runner.getCommandVersion('gcloud', versionArgs: ['--version']);
    // Extract just the first line with version info
    final versionLine = version?.split('\n').first ?? 'unknown';
    return ToolStatus.installed('Google Cloud SDK', versionLine, isRequired: false);
  }

  /// Check if Docker is installed
  Future<ToolStatus> checkDocker() async {
    final exists = await _runner.commandExists('docker');
    if (!exists) {
      return ToolStatus.missing(
        'Docker',
        'https://docs.docker.com/get-docker/',
        isRequired: false,
      );
    }

    final version = await _runner.getCommandVersion('docker');
    return ToolStatus.installed('Docker', version ?? 'unknown', isRequired: false);
  }

  /// Check if npm is installed (needed for Firebase CLI)
  Future<ToolStatus> checkNpm() async {
    final exists = await _runner.commandExists('npm');
    if (!exists) {
      return ToolStatus.missing(
        'npm',
        'https://nodejs.org/',
        isRequired: false,
      );
    }

    final version = await _runner.getCommandVersion('npm');
    return ToolStatus.installed('npm', version ?? 'unknown', isRequired: false);
  }

  /// Check if CocoaPods is installed (macOS only)
  Future<ToolStatus> checkCocoaPods() async {
    if (!Platform.isMacOS) {
      return ToolStatus(
        name: 'CocoaPods',
        isInstalled: true,
        version: 'N/A (not macOS)',
        isRequired: false,
      );
    }

    final exists = await _runner.commandExists('pod');
    if (!exists) {
      return ToolStatus.missing(
        'CocoaPods',
        'brew install cocoapods',
        isRequired: false,
      );
    }

    final version = await _runner.getCommandVersion('pod');
    return ToolStatus.installed('CocoaPods', version ?? 'unknown', isRequired: false);
  }

  /// Check if Homebrew is installed (macOS only)
  Future<ToolStatus> checkHomebrew() async {
    if (!Platform.isMacOS) {
      return ToolStatus(
        name: 'Homebrew',
        isInstalled: true,
        version: 'N/A (not macOS)',
        isRequired: false,
      );
    }

    final exists = await _runner.commandExists('brew');
    if (!exists) {
      return ToolStatus.missing(
        'Homebrew',
        '/bin/bash -c "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"',
        isRequired: false,
      );
    }

    final version = await _runner.getCommandVersion('brew');
    return ToolStatus.installed('Homebrew', version ?? 'unknown', isRequired: false);
  }

  /// Check all required tools
  Future<ToolCheckResult> checkRequired() async {
    info('Checking required tools...');

    final tools = await Future.wait([
      checkFlutter(),
      checkDart(),
    ]);

    return ToolCheckResult(tools: tools);
  }

  /// Check all tools (required and optional)
  Future<ToolCheckResult> checkAll() async {
    info('Checking all tools...');

    final tools = await Future.wait([
      checkFlutter(),
      checkDart(),
      checkFirebase(),
      checkFlutterFire(),
      checkGcloud(),
      checkDocker(),
      checkNpm(),
      checkCocoaPods(),
      checkHomebrew(),
    ]);

    return ToolCheckResult(tools: tools);
  }

  /// Check tools needed for Firebase
  Future<ToolCheckResult> checkFirebaseTools() async {
    info('Checking Firebase tools...');

    final tools = await Future.wait([
      checkFirebase(),
      checkFlutterFire(),
      checkNpm(),
    ]);

    return ToolCheckResult(tools: tools);
  }

  /// Check tools needed for server deployment
  Future<ToolCheckResult> checkServerTools() async {
    info('Checking server deployment tools...');

    final tools = await Future.wait([
      checkDocker(),
      checkGcloud(),
    ]);

    return ToolCheckResult(tools: tools);
  }

  /// Run flutter doctor and return the output
  Future<String> runFlutterDoctor() async {
    info('Running flutter doctor...');

    final result = await _runner.run('flutter', ['doctor', '-v']);
    return result.stdout;
  }
}
