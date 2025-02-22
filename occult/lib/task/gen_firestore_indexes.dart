import 'package:occult/util/tasks.dart';

class TGenFirestoreIndexes extends OTaskJob {
  TGenFirestoreIndexes() : super("Generate firestore.indexes.json");

  @override
  Future<void> run() => add(TMakeJson("config/firebase/firestore.indexes.json",
      {"indexes": [], "fieldOverrides": []}));
}
