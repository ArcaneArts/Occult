import 'package:occult/all.dart';
import 'package:occult/util.dart';
import 'package:occult/util/tasks.dart';

class TDeployStorage extends OTaskExclusiveJob {
  final OccultConfiguration config;

  TDeployStorage(this.config) : super("Deploy Storage");

  @override
  Future<void> run() async {
    await interactive("firebase", [
      "deploy",
      "--only",
      "storage",
    ]);
  }
}
