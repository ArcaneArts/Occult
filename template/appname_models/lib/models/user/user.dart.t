import 'package:appname_models/appname_models.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:fire_crud/fire_crud.dart';

part 'user.mapper.dart';

@MappableClass()
class AppNameUser with AppNameUserMappable, ModelCrud {
  final String firstName;
  final String lastName;
  final String email;
  final bool registered;
  final DateTime signedUpDate;
  final DateTime lastLogin;

  AppNameUser({
    required this.registered,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.signedUpDate,
    required this.lastLogin,
  });

  String get name => "$firstName $lastName";

  @override
  List<FireModel<ModelCrud>> get childModels => [
        FireModel<AppNameUserCapabilities>(
          collection: "data",
          exclusiveDocumentId: "capabilities",
          toMap: (m) => m.toMap(),
          fromMap: (m) => AppNameUserCapabilitiesMapper.fromMap(m),
          model: AppNameUserCapabilities(),
        ),
        FireModel<AppNameUserSettings>(
          collection: "data",
          exclusiveDocumentId: "settings",
          toMap: (m) => m.toMap(),
          fromMap: (m) => AppNameUserSettingsMapper.fromMap(m),
          model: AppNameUserSettings(),
        ),
      ];
}
