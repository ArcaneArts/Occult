import 'package:occult/all.dart';
import 'package:occult/util.dart';
import 'package:occult/util/tasks.dart';

class TDeployFirestore extends OTaskExclusiveJob {
  final OccultConfiguration config;

  TDeployFirestore(this.config) : super("Deploy Firestore");

  @override
  Future<void> run() async {
    await interactive("firebase", [
      "deploy",
      "--only",
      "firestore",
    ]);
  }
}
