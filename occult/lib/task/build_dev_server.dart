import 'package:occult/all.dart';
import 'package:occult/util.dart';
import 'package:occult/util/tasks.dart';
import 'package:universal_io/io.dart';

class TBuildDevServer extends OTaskExclusiveJob {
  final OccultConfiguration config;

  TBuildDevServer(this.config) : super("Build Dev Server Image");

  @override
  Future<void> run() async {
    await interactive(
        "cp",
        ["-r", "../${config.name}_models", "${config.name}_models"],
        "${config.path}${Platform.pathSeparator}${config.name}_server");
    final flutterCommand = Platform.isWindows ? "flutter.bat" : "flutter";
    await interactive(flutterCommand, ["pub", "get"],
        "${config.path}${Platform.pathSeparator}${config.name}_server");
    await interactive(flutterCommand, ["pub", "get"],
        "${config.path}${Platform.pathSeparator}${config.name}_server${Platform.pathSeparator}${config.name}_models");
    await interactive("rm", ["-rf", ".dart_tool"],
        "${config.path}${Platform.pathSeparator}${config.name}_server${Platform.pathSeparator}${config.name}_models");
    await interactive(
        "docker",
        [
          "build",
          "--platform",
          "linux/amd64",
          "-t",
          "${config.name}-dev",
          "-f",
          "Dockerfile-dev",
          "."
        ],
        "${config.path}${Platform.pathSeparator}${config.name}_server");
    await interactive("rm", ["-rf", "${config.name}_models"],
        "${config.path}${Platform.pathSeparator}${config.name}_server");
  }
}
