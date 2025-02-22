import 'dart:io';

import 'package:occult/all.dart';
import 'package:occult/util.dart';
import 'package:occult/util/tasks.dart';

class TRunSplashGen extends OTaskExclusiveJob {
  final OccultConfiguration config;

  TRunSplashGen(this.config) : super("Gen Native Splash");

  @override
  Future<void> run() async {
    await interactive(
        "dart",
        [
          "run",
          "flutter_native_splash:create",
        ],
        "${config.path}${Platform.pathSeparator}${config.name}");
  }
}
