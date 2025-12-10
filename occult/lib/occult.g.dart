// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'occult.dart';

// **************************************************************************
// CliRunnerGenerator
// **************************************************************************

const String version = '2.0.0';

/// Occult CLI - Arcane Template System
///
/// A class for invoking [Command]s based on raw command-line arguments.
///
/// The type argument `T` represents the type returned by [Command.run] and
/// [CommandRunner.run]; it can be ommitted if you're not using the return
/// values.
class _$OccultRunner<T extends dynamic> extends CommandRunner<dynamic> {
  _$OccultRunner()
      : super(
          'occult',
          'Occult CLI - Arcane Template System',
        ) {
    final upcastedType = (this as OccultRunner);
    addCommand(upcastedType.create);
    addCommand(upcastedType.check);
    addCommand(upcastedType.deploy);
    addCommand(upcastedType.config);
    addCommand(upcastedType.gui);
    addCommand(upcastedType.hello);

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
