import 'dart:io';

import 'package:cli_annotations/cli_annotations.dart';
import 'package:fast_log/fast_log.dart';
import 'package:path/path.dart' as p;

import '../models/setup_config.dart';
import '../services/config_generator.dart';
import '../services/firebase_service.dart';
import '../services/server_setup.dart';
import '../utils/user_prompt.dart';

part 'deploy_command.g.dart';

/// Firebase and server deployment commands
///
/// Deploy Firebase resources (Firestore, Storage, Hosting) and
/// server applications to Cloud Run.
@cliSubcommand
class DeployCommand extends _$DeployCommand {
  /// Load configuration from the current directory
  Future<SetupConfig?> _loadConfig() async {
    final configPath = p.join(Directory.current.path, 'config', 'setup_config.env');
    return await SetupConfig.loadFromFile(configPath);
  }

  /// Deploy Firestore rules and indexes
  ///
  /// Deploys Firestore security rules and indexes to Firebase.
  @cliCommand
  Future<void> firestore() async {
    final config = await _loadConfig();
    if (config == null) {
      error('No configuration found. Run "occult create" first.');
      return;
    }

    if (!config.useFirebase) {
      error('Firebase is not enabled for this project.');
      return;
    }

    final firebase = FirebaseService(config);
    if (await firebase.deployFirestore()) {
      success('Firestore deployed successfully');
    } else {
      error('Firestore deployment failed');
    }
  }

  /// Deploy Storage rules
  ///
  /// Deploys Firebase Storage security rules.
  @cliCommand
  Future<void> storage() async {
    final config = await _loadConfig();
    if (config == null) {
      error('No configuration found. Run "occult create" first.');
      return;
    }

    if (!config.useFirebase) {
      error('Firebase is not enabled for this project.');
      return;
    }

    final firebase = FirebaseService(config);
    if (await firebase.deployStorage()) {
      success('Storage rules deployed successfully');
    } else {
      error('Storage deployment failed');
    }
  }

  /// Deploy to Firebase Hosting (release)
  ///
  /// Builds the web app and deploys to the release hosting site.
  @cliCommand
  Future<void> hosting() async {
    final config = await _loadConfig();
    if (config == null) {
      error('No configuration found. Run "occult create" first.');
      return;
    }

    if (!config.useFirebase) {
      error('Firebase is not enabled for this project.');
      return;
    }

    final firebase = FirebaseService(config);

    // Build first
    if (!await firebase.buildWeb()) {
      error('Web build failed');
      return;
    }

    if (await firebase.deployHostingRelease()) {
      success('Hosting deployed successfully');
    } else {
      error('Hosting deployment failed');
    }
  }

  /// Deploy to Firebase Hosting (beta)
  ///
  /// Builds the web app and deploys to the beta hosting site.
  @cliCommand
  Future<void> hostingBeta() async {
    final config = await _loadConfig();
    if (config == null) {
      error('No configuration found. Run "occult create" first.');
      return;
    }

    if (!config.useFirebase) {
      error('Firebase is not enabled for this project.');
      return;
    }

    final firebase = FirebaseService(config);

    // Build first
    if (!await firebase.buildWeb()) {
      error('Web build failed');
      return;
    }

    if (await firebase.deployHostingBeta()) {
      success('Beta hosting deployed successfully');
    } else {
      error('Beta hosting deployment failed');
    }
  }

  /// Deploy all Firebase resources
  ///
  /// Deploys Firestore, Storage, and Hosting in sequence.
  @cliCommand
  Future<void> all() async {
    final config = await _loadConfig();
    if (config == null) {
      error('No configuration found. Run "occult create" first.');
      return;
    }

    if (!config.useFirebase) {
      error('Firebase is not enabled for this project.');
      return;
    }

    final firebase = FirebaseService(config);
    if (await firebase.deployAll()) {
      success('All Firebase resources deployed');
    } else {
      error('Some deployments failed');
    }
  }

  /// Setup Firebase for a new project
  ///
  /// Logs in to Firebase/gcloud, configures FlutterFire, and generates
  /// configuration files.
  @cliCommand
  Future<void> firebaseSetup() async {
    final config = await _loadConfig();
    if (config == null) {
      error('No configuration found. Run "occult create" first.');
      return;
    }

    if (!config.useFirebase || config.firebaseProjectId == null) {
      error('Firebase is not enabled or project ID not set.');
      return;
    }

    final firebase = FirebaseService(config);
    final configGen = ConfigGenerator(config);

    // Step 1: Login to Firebase
    info('Step 1: Firebase Login');
    if (!await firebase.login()) {
      warn('Firebase login may have failed. Continue anyway? [y/N]');
      if (!await UserPrompt.askYesNo('Continue?', defaultValue: false)) {
        return;
      }
    }

    // Step 2: Login to gcloud (for Cloud Run)
    if (config.setupCloudRun) {
      info('Step 2: Google Cloud Login');
      if (!await firebase.gcloudLogin()) {
        warn('gcloud login may have failed');
      }
    }

    // Step 3: Configure FlutterFire
    info('Step 3: FlutterFire Configuration');
    if (!await firebase.configureFlutterFire()) {
      error('FlutterFire configuration failed');
      return;
    }

    // Step 4: Generate configuration files
    info('Step 4: Generating configuration files');
    await configGen.generateAll();

    // Step 5: Enable Google APIs if Cloud Run is enabled
    if (config.setupCloudRun) {
      info('Step 5: Enabling Google Cloud APIs');
      await firebase.enableGoogleApis();
    }

    success('Firebase setup complete!');
    print('');
    print('Next steps:');
    print('  1. Review generated rules in config/');
    print('  2. Deploy with: occult deploy all');
  }

  /// Generate Firebase configuration files
  ///
  /// Creates firebase.json, .firebaserc, and security rules without deploying.
  @cliCommand
  Future<void> generateConfigs() async {
    final config = await _loadConfig();
    if (config == null) {
      error('No configuration found. Run "occult create" first.');
      return;
    }

    final configGen = ConfigGenerator(config);
    await configGen.generateAll();
  }

  /// Setup server for deployment
  ///
  /// Generates Dockerfiles and deployment scripts for the server.
  @cliCommand
  Future<void> serverSetup() async {
    final config = await _loadConfig();
    if (config == null) {
      error('No configuration found. Run "occult create" first.');
      return;
    }

    if (!config.createServer) {
      error('Server is not enabled for this project.');
      return;
    }

    final server = ServerSetup(config);
    await server.generateAll();
  }

  /// Build server Docker image
  ///
  /// Builds the production Docker image for the server.
  @cliCommand
  Future<void> serverBuild() async {
    final config = await _loadConfig();
    if (config == null) {
      error('No configuration found. Run "occult create" first.');
      return;
    }

    if (!config.createServer) {
      error('Server is not enabled for this project.');
      return;
    }

    final server = ServerSetup(config);
    if (await server.buildDockerImage()) {
      success('Server Docker image built successfully');
    } else {
      error('Docker build failed');
    }
  }
}
