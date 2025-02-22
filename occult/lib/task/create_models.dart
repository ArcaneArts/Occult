import 'dart:io';

import 'package:occult/util/tasks.dart';

class TCreateModelsProject extends OTaskJob {
  final String app;

  TCreateModelsProject(this.app) : super("Create ${app}_models project");

  @override
  Future<void> run() => add(TRun("flutter", [
        "create",
        "-t",
        "package",
        "--suppress-analytics",
        "--project-name",
        "${app}_models",
        "--no-pub",
        "--overwrite",
        "-v",
        "${app}_models",
      ]))
          .then((_) => add(TModelsDeps(app)))
          .then((_) => add(TModelsDevDeps(app)));
}

class TModelsDeps extends OTaskJob {
  final String app;

  TModelsDeps(this.app) : super("Get ${app}_models dependencies");

  @override
  Future<void> run() => add(TRun(
      "flutter",
      [
        "pub",
        "add",
        "crypto",
        "dart_mappable",
        "equatable",
        "fire_crud",
        "toxic",
        "rxdart",
        "rxdart",
        "fast_log",
        "fire_api",
        "jiffy",
        "throttled",
      ],
      workingDirectory:
          "${Directory.current.absolute.path}${Platform.pathSeparator}${app}_models"));
}

class TModelsDevDeps extends OTaskJob {
  final String app;

  TModelsDevDeps(this.app) : super("Get ${app}_models dev dependencies");

  @override
  Future<void> run() => add(TRun("flutter",
      ["pub", "add", "build_runner", "dart_mappable_builder", "--dev"],
      workingDirectory:
          "${Directory.current.absolute.path}${Platform.pathSeparator}${app}_models"));
}
