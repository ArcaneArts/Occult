import 'dart:io';

import 'package:occult/all.dart';
import 'package:occult/task/build_dev_server.dart';
import 'package:occult/util.dart';
import 'package:occult/util/tasks.dart';

class TRunDevServer extends OTaskExclusiveJob {
  final OccultConfiguration config;

  TRunDevServer(this.config) : super("Run Dev Server");

  @override
  Future<void> run() async {
    await TBuildDevServer(config).run();
    await interactive(
        "docker",
        [
          "run",
          "--platform",
          "linux/amd64",
          "-it",
          "--init",
          "--rm",
          "-p",
          "8080:8080",
          "${config.name}-dev",
        ],
        "${config.path}${Platform.pathSeparator}${config.name}_server");
  }
}
