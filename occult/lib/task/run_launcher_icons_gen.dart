import 'package:occult/all.dart';
import 'package:occult/util.dart';
import 'package:occult/util/tasks.dart';
import 'package:universal_io/io.dart';

class TRunLaunchIconsGen extends OTaskExclusiveJob {
  final OccultConfiguration config;

  TRunLaunchIconsGen(this.config) : super("Gen Launcher Icons");

  @override
  Future<void> run() async {
    await interactive(
        "dart",
        [
          "run",
          "flutter_launcher_icons",
        ],
        "${config.path}${Platform.pathSeparator}${config.name}");
  }
}
