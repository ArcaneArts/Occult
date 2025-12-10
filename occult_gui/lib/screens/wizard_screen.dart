import 'dart:io';

import 'package:arcane/arcane.dart';
import 'package:file_picker/file_picker.dart' as fp;

import '../main.dart';
import '../models/wizard_config.dart';
import '../services/project_service.dart';

/// Main wizard screen for project creation
class WizardScreen extends StatefulWidget {
  const WizardScreen({super.key});

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  final _config = WizardConfig();
  final _projectService = ProjectService();
  int _currentStep = 0;

  final _appNameController = TextEditingController(text: 'my_app');
  final _orgDomainController = TextEditingController(text: 'com.example');
  final _classNameController = TextEditingController(text: 'MyApp');
  final _firebaseIdController = TextEditingController();
  final _outputDirController = TextEditingController();

  String? _appNameError;
  String? _orgDomainError;
  String? _firebaseIdError;

  final List<LogEntry> _logs = [];
  bool _isCreating = false;
  bool _isComplete = false;
  double _currentProgress = 0;

  @override
  void initState() {
    super.initState();
    _outputDirController.text = Directory.current.path;
    _config.outputDir = Directory.current.path;

    // Listen to log stream
    _projectService.logStream.listen((entry) {
      setState(() {
        _logs.add(entry);
      });
    });

    // Listen to progress stream
    _projectService.progressStream.listen((progress) {
      setState(() {
        _currentProgress = progress;
      });
    });
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _orgDomainController.dispose();
    _classNameController.dispose();
    _firebaseIdController.dispose();
    _outputDirController.dispose();
    _projectService.dispose();
    super.dispose();
  }

  void _updateClassName() {
    final name = _appNameController.text;
    if (name.isNotEmpty) {
      _classNameController.text = snakeToPascal(name);
      _config.baseClassName = _classNameController.text;
    }
  }

  void _validateAppName(String value) {
    final result = WizardValidators.validateAppName(value);
    setState(() {
      _appNameError = result.isValid ? null : result.errorMessage;
      if (result.isValid) {
        _config.appName = value;
        _updateClassName();
      }
    });
  }

  void _validateOrgDomain(String value) {
    final result = WizardValidators.validateOrgDomain(value);
    setState(() {
      _orgDomainError = result.isValid ? null : result.errorMessage;
      if (result.isValid) {
        _config.orgDomain = value;
      }
    });
  }

  void _validateFirebaseId(String value) {
    if (value.isEmpty && _config.useFirebase) {
      setState(() {
        _firebaseIdError = 'Firebase project ID is required';
      });
      return;
    }

    if (value.isNotEmpty) {
      final result = WizardValidators.validateFirebaseProjectId(value);
      setState(() {
        _firebaseIdError = result.isValid ? null : result.errorMessage;
        if (result.isValid) {
          _config.firebaseProjectId = value;
        }
      });
    } else {
      setState(() {
        _firebaseIdError = null;
        _config.firebaseProjectId = null;
      });
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _appNameError == null && _appNameController.text.isNotEmpty;
      case 1:
        return true;
      case 2:
        if (_config.useFirebase) {
          return _firebaseIdError == null && _firebaseIdController.text.isNotEmpty;
        }
        return true;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _createProject();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _selectOutputDir() async {
    final result = await fp.FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select Output Directory',
      initialDirectory: _outputDirController.text,
    );

    if (result != null) {
      setState(() {
        _outputDirController.text = result;
        _config.outputDir = result;
      });
    }
  }

  Future<void> _createProject() async {
    setState(() {
      _isCreating = true;
      _logs.clear();
      _currentProgress = 0;
    });

    final success = await _projectService.createProject(_config);

    setState(() {
      _isCreating = false;
      _isComplete = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Screen(
      header: Bar(
        titleText: 'Occult Project Wizard',
        subtitleText: 'Create Arcane Flutter Projects',
        trailing: [
          IconButton(
            icon: const Icon(Icons.moon_stars),
            onPressed: () => context.toggleTheme(),
          ),
        ],
      ),
      gutter: true,
      child: _isCreating || _isComplete
          ? _buildCreationProgress(context)
          : _buildWizardContent(context),
    );
  }

  Widget _buildWizardContent(BuildContext context) {
    return Collection(
      children: [
        _buildStepIndicator(context),
        const Gap(24),
        _buildStepContent(context),
        const Gap(24),
        _buildNavigationButtons(context),
      ],
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _stepDot(theme, 0, 'Basics'),
        _stepLine(theme, 0),
        _stepDot(theme, 1, 'Template'),
        _stepLine(theme, 1),
        _stepDot(theme, 2, 'Options'),
        _stepLine(theme, 2),
        _stepDot(theme, 3, 'Review'),
      ],
    );
  }

  Widget _stepDot(ThemeData theme, int index, String label) {
    final isActive = _currentStep == index;
    final isComplete = _currentStep > index;
    final color = isActive || isComplete
        ? theme.colorScheme.primary
        : theme.colorScheme.mutedForeground;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive || isComplete ? color : Colors.transparent,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: isComplete
                  ? Icon(Icons.check, size: 16, color: theme.colorScheme.primaryForeground)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive ? theme.colorScheme.primaryForeground : color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const Gap(4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? theme.colorScheme.foreground : theme.colorScheme.mutedForeground,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepLine(ThemeData theme, int index) {
    final isComplete = _currentStep > index;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isComplete ? theme.colorScheme.primary : theme.colorScheme.border,
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildBasicsStep(context);
      case 1:
        return _buildTemplateStep(context);
      case 2:
        return _buildOptionsStep(context);
      case 3:
        return _buildReviewStep(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicsStep(BuildContext context) {
    final theme = Theme.of(context);
    return Collection(
      children: [
        Text('Project Basics', style: theme.typography.h3),
        const Gap(8),
        Text(
          'Enter the basic information for your new project.',
          style: TextStyle(color: theme.colorScheme.mutedForeground),
        ),
        const Gap(24),
        Section(
          titleText: 'App Name',
          subtitleText: 'Use snake_case (e.g., my_awesome_app)',
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _appNameController,
                  onChanged: _validateAppName,
                ),
                if (_appNameError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _appNameError!,
                      style: TextStyle(color: theme.colorScheme.destructive, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Gap(16),
        Section(
          titleText: 'Organization Domain',
          subtitleText: 'Reverse domain notation (e.g., com.example)',
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _orgDomainController,
                  onChanged: _validateOrgDomain,
                ),
                if (_orgDomainError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _orgDomainError!,
                      style: TextStyle(color: theme.colorScheme.destructive, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const Gap(16),
        Section(
          titleText: 'Class Name',
          subtitleText: 'Auto-generated from app name (PascalCase)',
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _classNameController,
              onChanged: (v) => _config.baseClassName = v,
            ),
          ),
        ),
        const Gap(16),
        Section(
          titleText: 'Output Directory',
          subtitleText: 'Where to create the project',
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _outputDirController,
                    onChanged: (v) => _config.outputDir = v,
                  ),
                ),
                const Gap(8),
                OutlineButton(
                  onPressed: _selectOutputDir,
                  child: const Text('Browse'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateStep(BuildContext context) {
    final theme = Theme.of(context);
    return Collection(
      children: [
        Text('Choose Template', style: theme.typography.h3),
        const Gap(8),
        Text(
          'Select the project template that best fits your needs.',
          style: TextStyle(color: theme.colorScheme.mutedForeground),
        ),
        const Gap(24),
        ...TemplateType.values.map((template) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTemplateCard(theme, template),
            )),
      ],
    );
  }

  Widget _buildTemplateCard(ThemeData theme, TemplateType template) {
    final isSelected = _config.template == template;

    return GestureDetector(
      onTap: () => setState(() => _config.updateTemplate(template)),
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: isSelected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.primary, width: 2),
                )
              : null,
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.border,
                    width: 2,
                  ),
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 14, color: theme.colorScheme.primaryForeground)
                    : null,
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.displayName,
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.foreground),
                    ),
                    const Gap(4),
                    Text(
                      template.description,
                      style: TextStyle(color: theme.colorScheme.mutedForeground, fontSize: 13),
                    ),
                    const Gap(4),
                    Text(
                      template.platforms.isEmpty
                          ? 'Pure Dart CLI'
                          : 'Platforms: ${template.platforms.join(", ")}',
                      style: TextStyle(color: theme.colorScheme.mutedForeground, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle_fill, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsStep(BuildContext context) {
    final theme = Theme.of(context);
    return Collection(
      children: [
        Text('Project Options', style: theme.typography.h3),
        const Gap(8),
        Text(
          'Configure additional features for your project.',
          style: TextStyle(color: theme.colorScheme.mutedForeground),
        ),
        const Gap(24),
        // Platform selection (only for templates that allow it)
        if (_config.template.allowsPlatformSelection) ...[
          Section(
            titleText: 'Target Platforms',
            subtitleText: 'Select which platforms to build for',
            child: Column(
              children: _config.template.platforms
                  .map((platform) => Tile(
                        title: Text(_getPlatformDisplayName(platform)),
                        leading: Icon(_getPlatformIcon(platform)),
                        trailing: Switch(
                          value: _config.isPlatformSelected(platform),
                          onChanged: (v) {
                            setState(() => _config.togglePlatform(platform));
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
          const Gap(16),
        ],
        Section(
          titleText: 'Additional Packages',
          child: Column(
            children: [
              Tile(
                title: const Text('Create Models Package'),
                subtitle: const Text('Shared data models for client and server'),
                trailing: Switch(
                  value: _config.createModels,
                  onChanged: (v) => setState(() => _config.createModels = v),
                ),
              ),
              Tile(
                title: const Text('Create Server App'),
                subtitle: const Text('Backend REST API with Shelf'),
                trailing: Switch(
                  value: _config.createServer,
                  onChanged: (v) => setState(() => _config.createServer = v),
                ),
              ),
            ],
          ),
        ),
        const Gap(16),
        Section(
          titleText: 'Firebase Integration',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Tile(
                title: const Text('Enable Firebase'),
                subtitle: const Text('Add Firebase configuration'),
                trailing: Switch(
                  value: _config.useFirebase,
                  onChanged: (v) {
                    setState(() {
                      _config.useFirebase = v;
                      if (!v) {
                        _firebaseIdError = null;
                        _config.firebaseProjectId = null;
                      }
                    });
                  },
                ),
              ),
              if (_config.useFirebase)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Firebase Project ID',
                        style: TextStyle(fontWeight: FontWeight.w500, color: theme.colorScheme.foreground),
                      ),
                      const Gap(8),
                      TextField(
                        controller: _firebaseIdController,
                        onChanged: _validateFirebaseId,
                      ),
                      if (_firebaseIdError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _firebaseIdError!,
                            style: TextStyle(color: theme.colorScheme.destructive, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (_config.createServer && _config.useFirebase) ...[
          const Gap(16),
          Section(
            titleText: 'Cloud Deployment',
            child: Tile(
              title: const Text('Setup Cloud Run'),
              subtitle: const Text('Configure Docker deployment for server'),
              trailing: Switch(
                value: _config.setupCloudRun,
                onChanged: (v) => setState(() => _config.setupCloudRun = v),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewStep(BuildContext context) {
    final theme = Theme.of(context);
    final displayMap = _config.toDisplayMap();

    return Collection(
      children: [
        Text('Review Configuration', style: theme.typography.h3),
        const Gap(8),
        Text(
          'Review your configuration before creating the project.',
          style: TextStyle(color: theme.colorScheme.mutedForeground),
        ),
        const Gap(24),
        Section(
          titleText: 'Project Summary',
          child: Column(
            children: displayMap.entries
                .map((e) => Tile(
                      title: Text(e.key),
                      trailing: Text(e.value, style: TextStyle(color: theme.colorScheme.mutedForeground)),
                    ))
                .toList(),
          ),
        ),
        const Gap(16),
        Section(
          titleText: 'What will be created',
          child: Column(
            children: [
              Tile(
                leading: const Icon(Icons.app_window),
                title: Text(_config.appName),
                subtitle: Text(_config.template.displayName),
              ),
              if (_config.createModels)
                Tile(
                  leading: const Icon(Icons.package),
                  title: Text(_config.modelsPackageName),
                  subtitle: const Text('Shared models package'),
                ),
              if (_config.createServer)
                Tile(
                  leading: const Icon(Icons.cloud),
                  title: Text(_config.serverPackageName),
                  subtitle: const Text('Server application'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          OutlineButton(
            onPressed: _prevStep,
            leading: const Icon(Icons.arrow_left),
            child: const Text('Previous'),
          )
        else
          const SizedBox.shrink(),
        PrimaryButton(
          onPressed: _canProceed() ? _nextStep : null,
          trailing: _currentStep < 3 ? const Icon(Icons.arrow_right) : null,
          leading: _currentStep == 3 ? const Icon(Icons.magic_wand) : null,
          child: Text(_currentStep < 3 ? 'Next' : 'Create Project'),
        ),
      ],
    );
  }

  Widget _buildCreationProgress(BuildContext context) {
    final theme = Theme.of(context);
    return Collection(
      children: [
        Text(_isComplete ? 'Project Created!' : 'Creating Project...', style: theme.typography.h3),
        const Gap(24),
        SizedBox(
          width: double.infinity,
          child: LinearProgressIndicator(value: _currentProgress / 100),
        ),
        const Gap(8),
        Text(
          '${_currentProgress.toInt()}% complete',
          style: TextStyle(color: theme.colorScheme.mutedForeground),
        ),
        const Gap(24),
        Container(
          height: 300,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.border),
          ),
          child: ListView.builder(
            itemCount: _logs.length,
            itemBuilder: (context, index) {
              final log = _logs[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  log.message,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: _getLogColor(theme, log.level),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isComplete) ...[
          const Gap(16),
          Section(
            titleText: 'Next Steps',
            child: Column(
              children: [
                Tile(
                  leading: const Icon(Icons.terminal),
                  title: Text('cd ${_config.outputDir}/${_config.appName}'),
                  subtitle: const Text('Navigate to project'),
                ),
                Tile(
                  leading: const Icon(Icons.play),
                  title: Text(_config.template.isFlutter ? 'flutter run' : 'dart run bin/main.dart'),
                  subtitle: const Text('Run the application'),
                ),
              ],
            ),
          ),
          const Gap(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlineButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 0;
                    _isCreating = false;
                    _isComplete = false;
                    _logs.clear();
                    _currentProgress = 0;
                  });
                },
                child: const Text('Create Another'),
              ),
              const Gap(8),
              PrimaryButton(
                onPressed: () => exit(0),
                leading: const Icon(Icons.check),
                child: const Text('Done'),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Color _getLogColor(ThemeData theme, LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return theme.colorScheme.foreground;
      case LogLevel.success:
        return Colors.green;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return theme.colorScheme.destructive;
      case LogLevel.verbose:
        return theme.colorScheme.mutedForeground;
    }
  }

  String _getPlatformDisplayName(String platform) {
    switch (platform) {
      case 'android':
        return 'Android';
      case 'ios':
        return 'iOS';
      case 'web':
        return 'Web';
      case 'linux':
        return 'Linux';
      case 'macos':
        return 'macOS';
      case 'windows':
        return 'Windows';
      default:
        return platform;
    }
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'android':
        return Icons.device_mobile;
      case 'ios':
        return Icons.device_mobile;
      case 'web':
        return Icons.globe;
      case 'linux':
        return Icons.desktop;
      case 'macos':
        return Icons.desktop;
      case 'windows':
        return Icons.desktop;
      default:
        return Icons.device_mobile;
    }
  }
}
