import 'dart:io';

import 'package:occult/util/tasks.dart';

class TRunBuildRunner extends OTaskJob {
  final String app;

  TRunBuildRunner(this.app) : super("Build Runner ${app}");

  @override
  Future<void> run() => add(TRun(
      'dart', ['run', "build_runner", "build", "--delete-conflicting-outputs"],
      workingDirectory:
          "${Directory.current.absolute.path}${Platform.pathSeparator}$app"));
}
