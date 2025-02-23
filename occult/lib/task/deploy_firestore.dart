import 'package:occult/all.dart';
import 'package:occult/util.dart';
import 'package:occult/util/tasks.dart';
import 'package:universal_io/io.dart';

class TDeployFirestore extends OTaskExclusiveJob {
  final OccultConfiguration config;

  TDeployFirestore(this.config) : super("Deploy Firestore");

  @override
  Future<void> run() async {
    final firebaseCommand = Platform.isWindows ? "firebase.cmd" : "firebase";
    await interactive(firebaseCommand, [
      "deploy",
      "--only",
      "firestore",
    ]);
  }
}
