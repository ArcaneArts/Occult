import 'package:appname_models/appname_models.dart';
import 'package:arcane/arcane.dart';

extension XContext on BuildContext {
  AppNameUser get user => pylon<AppNameUser>();
  AppNameUserSettings get userSettings => pylon<AppNameUserSettings>();
  AppNameUserCapabilities get userCapabilities =>
      pylon<AppNameUserCapabilities>();
}
