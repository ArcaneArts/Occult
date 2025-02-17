// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'occult.dart';

// **************************************************************************
// CliRunnerGenerator
// **************************************************************************

const String version = '0.0.1-dev.1';

/// A class for invoking [Command]s based on raw command-line arguments.
///
/// The type argument `T` represents the type returned by [Command.run] and
/// [CommandRunner.run]; it can be ommitted if you're not using the return
/// values.
class _$OccultRunner<T extends dynamic> extends CommandRunner<dynamic> {
  _$OccultRunner()
      : super(
          'occult',
          '',
        ) {
    final upcastedType = (this as OccultRunner);
    addCommand(RunCommand(upcastedType.runn));
    addCommand(DeployCommand(upcastedType.deploy));
    addCommand(BuildCommand(upcastedType.build));
    addCommand(CreateCommand(upcastedType.create));

    argParser.addFlag(
      'version',
      help: 'Reports the version of this tool.',
    );
  }

  @override
  Future<dynamic> runCommand(ArgResults topLevelResults) async {
    try {
      if (topLevelResults['version'] == true) {
        return showVersion();
      }

      return await super.runCommand(topLevelResults);
    } on UsageException catch (e) {
      stdout.writeln('${e.message}\n');
      stdout.writeln(e.usage);
    }
  }

  void showVersion() {
    return stdout.writeln('occult $version');
  }
}

class RunCommand extends Command<void> {
  RunCommand(this.userMethod) {
    argParser.addFlag(
      'server',
      defaultsTo: false,
    );
  }

  final Future<void> Function({bool server}) userMethod;

  @override
  String get name => 'run';

  @override
  String get description =>
      'Runs a target such as the server. You need to specify at least one target';

  @override
  Future<void> run() {
    final results = argResults!;
    return userMethod(server: (results['server'] as bool?) ?? false);
  }
}

class DeployCommand extends Command<void> {
  DeployCommand(this.userMethod) {
    argParser
      ..addFlag(
        'server-release',
        defaultsTo: false,
      )
      ..addFlag(
        'web',
        defaultsTo: false,
      )
      ..addFlag(
        'web-release',
        defaultsTo: false,
      );
  }

  final Future<void> Function({
    bool serverRelease,
    bool web,
    bool webRelease,
  }) userMethod;

  @override
  String get name => 'deploy';

  @override
  String get description =>
      'Deploys a target such as the server or web app. You need to specify at least one target';

  @override
  Future<void> run() {
    final results = argResults!;
    return userMethod(
      serverRelease: (results['server-release'] as bool?) ?? false,
      web: (results['web'] as bool?) ?? false,
      webRelease: (results['web-release'] as bool?) ?? false,
    );
  }
}

class BuildCommand extends Command<void> {
  BuildCommand(this.userMethod) {
    argParser
      ..addFlag(
        'server',
        defaultsTo: false,
      )
      ..addFlag(
        'server-release',
        defaultsTo: false,
      )
      ..addFlag(
        'web',
        defaultsTo: false,
      )
      ..addFlag(
        'apk',
        defaultsTo: false,
      )
      ..addFlag(
        'ios',
        defaultsTo: false,
      )
      ..addFlag(
        'macos',
        defaultsTo: false,
      )
      ..addFlag(
        'windows',
        defaultsTo: false,
      )
      ..addFlag(
        'linux',
        defaultsTo: false,
      )
      ..addFlag(
        'appbundle',
        defaultsTo: false,
      )
      ..addFlag(
        'launcher-icons',
        defaultsTo: false,
      )
      ..addFlag(
        'oss',
        defaultsTo: false,
      )
      ..addFlag(
        'models',
        defaultsTo: false,
      )
      ..addFlag(
        'splash-screen',
        defaultsTo: false,
      );
  }

  final Future<void> Function({
    bool server,
    bool serverRelease,
    bool web,
    bool apk,
    bool ios,
    bool macos,
    bool windows,
    bool linux,
    bool appbundle,
    bool launcherIcons,
    bool oss,
    bool models,
    bool splashScreen,
  }) userMethod;

  @override
  String get name => 'build';

  @override
  String get description =>
      'Builds a target. You need to specify at least one target';

  @override
  Future<void> run() {
    final results = argResults!;
    return userMethod(
      server: (results['server'] as bool?) ?? false,
      serverRelease: (results['server-release'] as bool?) ?? false,
      web: (results['web'] as bool?) ?? false,
      apk: (results['apk'] as bool?) ?? false,
      ios: (results['ios'] as bool?) ?? false,
      macos: (results['macos'] as bool?) ?? false,
      windows: (results['windows'] as bool?) ?? false,
      linux: (results['linux'] as bool?) ?? false,
      appbundle: (results['appbundle'] as bool?) ?? false,
      launcherIcons: (results['launcher-icons'] as bool?) ?? false,
      oss: (results['oss'] as bool?) ?? false,
      models: (results['models'] as bool?) ?? false,
      splashScreen: (results['splash-screen'] as bool?) ?? false,
    );
  }
}

class CreateCommand extends Command<void> {
  CreateCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'create';

  @override
  String get description => 'Creates a new project in the current directory';

  @override
  Future<void> run() {
    return userMethod();
  }
}
