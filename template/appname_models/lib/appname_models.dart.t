library caremap_models;

import 'models/user/user.dart';
import 'package:fire_crud/fire_crud.dart';

export 'models/user/server_signature.dart';
export 'models/user/user.dart';
export 'models/user/user_capabilities.dart';
export 'models/user/user_settings.dart';

void $registerModels() {
  $crud
    // Register your own models here
    ..registerModel(FireModel<AppNameUser>(
      collection: "user",
      toMap: (t) => t.toMap(),
      fromMap: (map) => AppNameUserMapper.fromMap(map),
      model: AppNameUser(
        email: '',
        firstName: '',
        lastName: '',
        lastLogin: DateTime.timestamp(),
        signedUpDate: DateTime.timestamp(),
        registered: false,
      ),
    ));
}
