import 'package:occult/task/gen_firebase.dart';
import 'package:occult/task/gen_firebaserc.dart';
import 'package:occult/task/gen_firestore_indexes.dart';
import 'package:occult/task/gen_firestore_rules.dart';
import 'package:occult/task/gen_storage_rules.dart';
import 'package:occult/util/tasks.dart';
import 'package:universal_io/io.dart';

class TGenFirebaseConfigs extends OTaskJob {
  final String project;
  final String app;

  TGenFirebaseConfigs({required this.project, required this.app})
      : super("Generate Firebase Configs for $project using app $app");

  static final String sl = Platform.pathSeparator;

  @override
  Future<void> run() => Future.wait([
        add(TGenFirebaseRC(project)),
        add(TGenFirebaseJson(project: project, app: app)),
        add(TGenFirestoreIndexes()),
        add(TGenFirestoreRules()),
        add(TGenStorageRules())
      ]);
}
