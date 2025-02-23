import 'dart:io';

import 'package:occult/util/tasks.dart';

class TFlutterFireInit extends OTaskExclusiveJob {
  final String app;
  final String fbProject;

  TFlutterFireInit(this.app, this.fbProject)
      : super("Flutterfire Init $app $fbProject");

  @override
  Future<void> run() async {
    final process = await Process.start(
        'flutterfire',
        [
          'configure',
          '--project',
          fbProject,
          '--platforms',
          'android,ios,macos,web,linux,windows'
        ],
        mode: ProcessStartMode.inheritStdio,
        workingDirectory:
            "${Directory.current.absolute.path}${Platform.pathSeparator}$app");

    int exitCode = await process.exitCode;

    if (exitCode != 0) {
      throw Exception(
          "Failed to process interactively flutterfire configure --project $fbProject --platforms android,ios,macos,web,linux,windows in $app");
    }
  }
}
