// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_command.dart';

// **************************************************************************
// SubcommandGenerator
// **************************************************************************

class _$CreateCommand<T extends dynamic> extends Command<dynamic> {
  _$CreateCommand() {
    final upcastedType = (this as CreateCommand);
    addSubcommand(RunCommand(upcastedType.run));
    addSubcommand(TemplatesCommand(upcastedType.templates));
  }

  @override
  String get name => 'create';

  @override
  String get description => 'Create new Arcane projects';
}

class RunCommand extends Command<void> {
  RunCommand(this.userMethod) {
    argParser
      ..addOption(
        'app-name',
        mandatory: false,
      )
      ..addOption(
        'org',
        mandatory: false,
      )
      ..addOption(
        'template',
        mandatory: false,
      )
      ..addOption(
        'class-name',
        mandatory: false,
      )
      ..addOption(
        'output-dir',
        mandatory: false,
      )
      ..addFlag(
        'with-models',
        defaultsTo: false,
      )
      ..addFlag(
        'with-server',
        defaultsTo: false,
      )
      ..addFlag(
        'with-firebase',
        defaultsTo: false,
      )
      ..addOption(
        'firebase-project-id',
        mandatory: false,
      )
      ..addFlag(
        'with-cloud-run',
        defaultsTo: false,
      )
      ..addFlag(
        'yes',
        defaultsTo: false,
      )
      ..addFlag(
        'skip-check',
        defaultsTo: false,
      )
      ..addOption(
        'service-account-key',
        mandatory: false,
      );
  }

  final Future<void> Function({
    String? appName,
    String? org,
    String? template,
    String? className,
    String? outputDir,
    bool withModels,
    bool withServer,
    bool withFirebase,
    String? firebaseProjectId,
    bool withCloudRun,
    bool yes,
    bool skipCheck,
    String? serviceAccountKey,
  }) userMethod;

  @override
  String get name => 'run';

  @override
  String get description => 'Create a new Arcane project';

  @override
  Future<void> run() {
    final results = argResults!;
    return userMethod(
      appName: (results['app-name'] as String?) ?? null,
      org: (results['org'] as String?) ?? null,
      template: (results['template'] as String?) ?? null,
      className: (results['class-name'] as String?) ?? null,
      outputDir: (results['output-dir'] as String?) ?? null,
      withModels: (results['with-models'] as bool?) ?? false,
      withServer: (results['with-server'] as bool?) ?? false,
      withFirebase: (results['with-firebase'] as bool?) ?? false,
      firebaseProjectId: (results['firebase-project-id'] as String?) ?? null,
      withCloudRun: (results['with-cloud-run'] as bool?) ?? false,
      yes: (results['yes'] as bool?) ?? false,
      skipCheck: (results['skip-check'] as bool?) ?? false,
      serviceAccountKey: (results['service-account-key'] as String?) ?? null,
    );
  }
}

class TemplatesCommand extends Command<void> {
  TemplatesCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'templates';

  @override
  String get description => 'List available templates';

  @override
  Future<void> run() {
    return userMethod();
  }
}
