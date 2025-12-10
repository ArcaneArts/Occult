import 'dart:io';

import 'package:fast_log/fast_log.dart';
import 'package:path/path.dart' as p;

import '../models/setup_config.dart';
import '../models/template_info.dart';
import '../utils/string_utils.dart';
import '../utils/user_prompt.dart';
import '../utils/validators.dart';
import 'config_generator.dart';
import 'dependency_manager.dart';
import 'firebase_service.dart';
import 'project_creator.dart';
import 'server_setup.dart';
import 'template_copier.dart';
import 'tool_checker.dart';

/// Interactive wizard for project setup
class InteractiveWizard {
  final ToolChecker _toolChecker = ToolChecker();

  /// Run the full interactive wizard
  Future<void> run() async {
    _printWelcome();

    // Step 1: Check tools
    if (!await _checkTools()) {
      return;
    }

    // Step 2: Gather configuration
    final config = await _gatherConfiguration();
    if (config == null) {
      warn('Setup cancelled');
      return;
    }

    // Step 3: Confirm configuration
    if (!await _confirmConfiguration(config)) {
      warn('Setup cancelled');
      return;
    }

    // Step 4: Execute setup
    await _executeSetup(config);

    // Step 5: Optional Firebase setup
    if (config.useFirebase) {
      await _offerFirebaseSetup(config);
    }

    _printSuccess(config);
  }

  void _printWelcome() {
    print('');
    print('\u2554' + '\u2550' * 60 + '\u2557');
    print('\u2551' + ' ' * 60 + '\u2551');
    print(
      '\u2551' +
          '              Welcome to Occult Setup Wizard'.padRight(60) +
          '\u2551',
    );
    print(
      '\u2551' +
          '               Arcane Template System'.padRight(60) +
          '\u2551',
    );
    print('\u2551' + ' ' * 60 + '\u2551');
    print('\u255a' + '\u2550' * 60 + '\u255d');
    print('');
    info('This wizard will help you create a new Arcane project.');
    print('');
  }

  Future<bool> _checkTools() async {
    info('Checking required tools...');
    print('');

    final result = await _toolChecker.checkRequired();

    if (!result.allRequiredInstalled) {
      result.printSummary();
      error('Please install the required tools before continuing.');
      return false;
    }

    success('All required tools are installed!');
    print('');
    return true;
  }

  Future<SetupConfig?> _gatherConfiguration() async {
    print('\u2500' * 60);
    print('Project Configuration');
    print('\u2500' * 60);
    print('');

    // App name
    final appName = await UserPrompt.askString(
      'Enter app name (snake_case)',
      defaultValue: 'my_app',
      validator: (s) => validateAppName(s).isValid,
      validationMessage:
          'App name must be lowercase with underscores (e.g., my_app)',
    );

    // Organization domain
    final orgDomain = await UserPrompt.askString(
      'Enter organization domain',
      defaultValue: 'com.example',
    );

    // Base class name (auto-generate suggestion)
    final suggestedClassName = snakeToPascal(appName);
    final baseClassName = await UserPrompt.askString(
      'Enter base class name',
      defaultValue: suggestedClassName,
    );

    // Template selection
    print('');
    print('Available Templates:');
    final templateIndex = await UserPrompt.showMenu(
      'Select a template:',
      TemplateType.values
          .map((t) => '${t.displayName}\n     ${t.description}')
          .toList(),
      defaultIndex: 0,
    );
    final template = TemplateType.values[templateIndex];

    // Output directory
    print('');
    final outputDir = await UserPrompt.askString(
      'Output directory',
      defaultValue: Directory.current.path,
    );

    // Models package
    print('');
    final createModels = await UserPrompt.askYesNo(
      'Create shared models package?',
      defaultValue: true,
    );

    // Server app
    final createServer = await UserPrompt.askYesNo(
      'Create server application?',
      defaultValue: false,
    );

    // Firebase
    print('');
    final useFirebase = await UserPrompt.askYesNo(
      'Enable Firebase integration?',
      defaultValue: false,
    );

    String? firebaseProjectId;
    if (useFirebase) {
      firebaseProjectId = await UserPrompt.askString(
        'Enter Firebase project ID',
        validator: (s) => validateFirebaseProjectId(s).isValid,
        validationMessage: 'Invalid Firebase project ID',
      );
    }

    // Cloud Run (only if server is enabled)
    bool setupCloudRun = false;
    if (createServer && useFirebase) {
      setupCloudRun = await UserPrompt.askYesNo(
        'Setup Cloud Run for server deployment?',
        defaultValue: false,
      );
    }

    return SetupConfig(
      appName: appName,
      orgDomain: orgDomain,
      baseClassName: baseClassName,
      template: template,
      outputDir: outputDir,
      createModels: createModels,
      createServer: createServer,
      useFirebase: useFirebase,
      firebaseProjectId: firebaseProjectId,
      setupCloudRun: setupCloudRun,
      platforms: template.supportedPlatforms,
    );
  }

  Future<bool> _confirmConfiguration(SetupConfig config) async {
    print('');
    UserPrompt.printConfigPreview(config.toDisplayMap());
    print('');

    return await UserPrompt.askYesNo('Proceed with these settings?');
  }

  Future<void> _executeSetup(SetupConfig config) async {
    print('');
    print('\u2500' * 60);
    print('Creating Project');
    print('\u2500' * 60);
    print('');

    // Create projects
    info('Creating project structure...');
    final creator = ProjectCreator(config);
    if (!await creator.createAllProjects()) {
      error('Failed to create projects');
      exit(1);
    }

    // Copy templates
    info('Copying template files...');
    final copier = TemplateCopier(config);
    await copier.copyAll();

    // Clean up test folders
    await creator.deleteTestFolders();

    // Get dependencies
    info('Installing dependencies...');
    final depManager = DependencyManager(config);

    if (config.createModels) {
      await depManager.linkModelsToProjects();
    }

    await depManager.getAllDependencies();

    // Run build_runner
    info('Running code generation...');
    await depManager.runAllBuildRunners();

    // Generate Firebase configs if enabled
    if (config.useFirebase) {
      info('Generating Firebase configuration...');
      final configGen = ConfigGenerator(config);
      await configGen.generateAll();
    }

    // Generate server files if enabled
    if (config.createServer) {
      info('Setting up server deployment...');
      final serverSetup = ServerSetup(config);
      await serverSetup.generateAll();
    }

    // Save configuration
    final configDir = Directory(p.join(config.outputDir, 'config'));
    if (!configDir.existsSync()) {
      await configDir.create(recursive: true);
    }
    await config.saveToFile(p.join(configDir.path, 'setup_config.env'));

    success('Project created successfully!');
  }

  Future<void> _offerFirebaseSetup(SetupConfig config) async {
    print('');
    print('\u2500' * 60);
    print('Firebase Setup');
    print('\u2500' * 60);
    print('');

    final setupNow = await UserPrompt.askYesNo(
      'Would you like to setup Firebase now?',
      defaultValue: true,
    );

    if (!setupNow) {
      info(
        'You can run Firebase setup later with: occult deploy firebase-setup',
      );
      return;
    }

    final firebase = FirebaseService(config);

    // Login to Firebase
    info('Logging in to Firebase...');
    await firebase.login();

    // Login to gcloud if Cloud Run enabled
    if (config.setupCloudRun) {
      info('Logging in to Google Cloud...');
      await firebase.gcloudLogin();
    }

    // Configure FlutterFire
    info('Configuring FlutterFire...');
    if (!await firebase.configureFlutterFire()) {
      warn('FlutterFire configuration failed. You can retry later.');
    }

    // Enable APIs
    if (config.setupCloudRun) {
      info('Enabling Google Cloud APIs...');
      await firebase.enableGoogleApis();
    }

    success('Firebase setup complete!');
  }

  void _printSuccess(SetupConfig config) {
    print('');
    print('\u2554' + '\u2550' * 60 + '\u2557');
    print('\u2551' + ' ' * 60 + '\u2551');
    print(
      '\u2551' +
          '              Project Created Successfully!'.padRight(60) +
          '\u2551',
    );
    print('\u2551' + ' ' * 60 + '\u2551');
    print('\u255a' + '\u2550' * 60 + '\u255d');
    print('');

    print('Created:');
    print('  \u2022 ${config.appName}/ - Main application');
    if (config.createModels) {
      print('  \u2022 ${config.modelsPackageName}/ - Shared models package');
    }
    if (config.createServer) {
      print('  \u2022 ${config.serverPackageName}/ - Server application');
    }
    print('  \u2022 config/ - Configuration files');
    print('  \u2022 references/ - Library documentation');

    print('');
    print('Next steps:');
    print('  cd ${config.outputDir}/${config.appName}');
    if (config.template.isFlutterApp) {
      print('  flutter run');
    } else {
      print('  dart run bin/main.dart --help');
    }

    if (config.useFirebase) {
      print('');
      print('Firebase deployment:');
      print('  occult deploy all');
    }

    if (config.createServer) {
      print('');
      print('Server deployment:');
      print('  cd ${config.serverPackageName}');
      print('  ./script_deploy.sh');
    }

    print('');
    success('Happy coding!');
  }
}
