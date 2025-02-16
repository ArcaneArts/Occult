// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'occult.dart';

// **************************************************************************
// CliRunnerGenerator
// **************************************************************************

const String version = '0.0.1';

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

class CreateCommand extends Command<void> {
  CreateCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'create';

  @override
  String get description => '';

  @override
  Future<void> run() {
    return userMethod();
  }
}
