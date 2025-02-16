library caremap_models;

import 'package:appname_models:models/user/user.dart';
import 'package:fire_crud/fire_crud.dart';

export 'package:appname_models:models/user/server_signature.dart';
export 'package:appname_models:models/user/user.dart';
export 'package:appname_models:models/user/user_capabilities.dart';
export 'package:appname_models:models/user/user_settings.dart';

void $registerModels() {
  $crud
    ..registerModel(FireModel<OccultUser>(
      collection: "user",
      toMap: (t) => t.toMap(),
      fromMap: (map) => OccultUserMapper.fromMap(map),
      model: OccultUser(
        email: '',
        firstName: '',
        lastName: '',
        lastLogin: DateTime.timestamp(),
        signedUpDate: DateTime.timestamp(),
        registered: false,
      ),
    ));
}
