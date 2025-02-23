import 'package:occult/all.dart';
import 'package:occult/util.dart';
import 'package:occult/util/tasks.dart';
import 'package:universal_io/io.dart';

class TDeployWeb extends OTaskExclusiveJob {
  final OccultConfiguration config;
  final bool beta;

  TDeployWeb(this.config, {this.beta = false})
      : super("Deploy Web ${beta ? "Beta" : "Release"}");

  @override
  Future<void> run() async {
    final firebaseCommand = Platform.isWindows ? "firebase.cmd" : "firebase";
    await interactive(firebaseCommand, [
      "deploy",
      "--only",
      "hosting:${config.firebaseProjectId}${beta ? "-beta" : ""}",
    ]);
  }
}
