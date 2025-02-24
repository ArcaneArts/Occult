import 'package:occult/util/tasks.dart';
import 'package:universal_io/io.dart';

class TGenFirebaseJson extends OTaskJob {
  final String project;
  final String app;

  TGenFirebaseJson({required this.project, required this.app})
      : super("Generate firebase.json for $project using app $app");

  static final String sl = Platform.pathSeparator;

  @override
  Future<void> run() => add(TMakeJson("firebase.json", {
        "firestore": {
          "rules": "config${sl}firebase${sl}firestore.rules",
          "indexes": "config${sl}firebase${sl}firestore.indexes.json"
        },
        "hosting": [
          {
            "site": "$project-beta",
            "public": "$app/build/web",
            "predeploy": ["cd $app && flutter build web --release --wasm"],
            "ignore": ["firebase.json", "**/node_modules/**"]
          },
          {
            "site": "$project",
            "public": "$app/build/web",
            "predeploy": ["cd $app && flutter build web --release --wasm"],
            "ignore": ["firebase.json", "**/node_modules/**"]
          }
        ],
        "storage": {"rules": "config${sl}firebase${sl}storage.rules"}
      }));
}
