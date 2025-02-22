import 'package:occult/util/tasks.dart';

class TGenStorageRules extends OTaskJob {
  TGenStorageRules() : super("Generate storage.rules");

  @override
  Future<void> run() => add(TMakeFile(
      "config/firebase/storage.rules",
      r"""
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
      """
          .trim()));
}
