import 'dart:io';

import 'package:occult/all.dart';
import 'package:occult/util.dart';
import 'package:occult/util/tasks.dart';

class TBuildProdServer extends OTaskExclusiveJob {
  final OccultConfiguration config;

  TBuildProdServer(this.config)
      : super("Build Production Server to Artifact Registry");

  @override
  Future<void> run() async {
    await interactive(
        "cp",
        ["-r", "../${config.name}_models", "${config.name}_models"],
        "${config.path}${Platform.pathSeparator}${config.name}_server");
    await interactive("flutter", ["pub", "get"],
        "${config.path}${Platform.pathSeparator}${config.name}_server");
    await interactive("flutter", ["pub", "get"],
        "${config.path}${Platform.pathSeparator}${config.name}_server${Platform.pathSeparator}/${config.name}_models");
    await interactive("rm", ["-rf", ".dart_tool"],
        "${config.path}${Platform.pathSeparator}${config.name}_server${Platform.pathSeparator}/${config.name}_models");
    await interactive(
        "docker",
        [
          "build",
          "--platform",
          "linux/amd64",
          "-t",
          "us-central1-docker.pkg.dev/${config.firebaseProjectId}/cloud-run-source-deploy/${config.name}-server:latest",
          "."
        ],
        "${config.path}${Platform.pathSeparator}${config.name}_server");
    await interactive(
        "rm",
        [
          "-rf",
          "${config.name}_models",
        ],
        "${config.path}${Platform.pathSeparator}${config.name}_server");

    await interactive("gcloud", ["auth", "configure-docker", "us-central1"],
        "${config.path}${Platform.pathSeparator}${config.name}_server");
    await interactive(
        "docker",
        [
          "push",
          "--platform",
          "linux/amd64",
          "us-central1-docker.pkg.dev/${config.firebaseProjectId}/cloud-run-source-deploy/${config.name}-server:latest"
        ],
        "${config.path}${Platform.pathSeparator}${config.name}_server");
  }
}
