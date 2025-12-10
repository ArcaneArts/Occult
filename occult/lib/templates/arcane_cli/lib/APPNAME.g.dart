// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'APPNAME.dart';

// **************************************************************************
// CliRunnerGenerator
// **************************************************************************

const String version = '1.0.0';

/// CLI application for APPNAME
///
/// A class for invoking [Command]s based on raw command-line arguments.
///
/// The type argument `T` represents the type returned by [Command.run] and
/// [CommandRunner.run]; it can be ommitted if you're not using the return
/// values.
class _$APPNAMERunner<T extends dynamic> extends CommandRunner<dynamic> {
  _$APPNAMERunner()
      : super(
          'appname',
          'CLI application for APPNAME',
        ) {
    final upcastedType = (this as APPNAMERunner);
    addCommand(upcastedType.hello);
    addCommand(upcastedType.config);

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
    return stdout.writeln('appname $version');
  }
}
