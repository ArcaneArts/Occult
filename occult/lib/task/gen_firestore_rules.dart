import 'package:occult/util/tasks.dart';

class TGenFirestoreRules extends OTaskJob {
  TGenFirestoreRules() : super("Generate firestore.rules");

  @override
  Future<void> run() => add(TMakeFile(
      "config/firebase/firestore.rules",
      r"""
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    function isAuth(){
      return request.auth != null;
    }

    function isUser(id){
      return isAuth() && request.auth.uid == id;
    }

    function getCapabilities(){
      return get(/databases/$(database)/documents/user/$(request.auth.uid)/data/capabilities).data;
    }

    // Block all documents by default (whitelist mode)
    match /{document=**} {
      allow read, write: if false;
    } 

    match /user/{user} {
      allow read, create, update: if isUser(user)

      match /data/settings {
        allow read, write: if isUser(user);
      }

      match /data/capabilities {
        allow read: if isUser(user)
      }
    }
  }
}
      """
          .trim()));
}
