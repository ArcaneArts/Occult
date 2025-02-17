import 'dart:async';

import 'package:appname_models/appname_models.dart';
import 'package:arcane/arcane.dart';
import 'package:arcane_auth/arcane_auth.dart';
import 'package:fire_crud/fire_crud.dart';
import 'package:serviced/serviced.dart';

Stream<AppNameUser?> get $userStream => svc<UserService>()._user;
Stream<AppNameUserSettings?> get $settingsStream =>
    svc<UserService>()._settings;
Stream<AppNameUserCapabilities?> get $capabilitiesStream =>
    svc<UserService>()._capabilities;
AppNameUser get $user => svc<UserService>()._user.value!;
AppNameUserSettings get $settings => svc<UserService>()._settings.value!;
AppNameUserCapabilities get $capabilities =>
    svc<UserService>()._capabilities.value!;

class UserService extends StatelessService {
  final BehaviorSubject<AppNameUser?> _user = BehaviorSubject.seeded(null);
  final BehaviorSubject<AppNameUserSettings?> _settings =
      BehaviorSubject.seeded(null);
  final BehaviorSubject<AppNameUserCapabilities?> _capabilities =
      BehaviorSubject.seeded(null);
  StreamSubscription<AppNameUser?>? _uSubscription;
  StreamSubscription<AppNameUserSettings?>? _sSubscription;
  StreamSubscription<AppNameUserCapabilities?>? _cSubscription;

  Future<void> bind(UserMeta user) async {
    List<Future> work = [];
    work.add($crud
        .ensureExists<AppNameUser>(
            user.user.uid,
            AppNameUser(
                registered: true,
                firstName: "",
                lastName: "",
                email: user.email ?? user.user.email ?? "",
                signedUpDate: DateTime.timestamp(),
                lastLogin: DateTime.timestamp()))
        .bang
        .then((i) => _user.add(i)));
    work.add($crud
        .model<AppNameUser>(user.user.uid)
        .ensureExistsUnique<AppNameUserSettings>(AppNameUserSettings())
        .bang
        .then((i) => _settings.add(i)));
    work.add($crud
        .model<AppNameUser>(user.user.uid)
        .getUnique<AppNameUserCapabilities>()
        .then((i) => i ?? AppNameUserCapabilities())
        .then((i) => _capabilities.add(i)));
    await Future.wait(work);
    _uSubscription = $crud.stream<AppNameUser>(user.user.uid).listen(_user.add);
    _sSubscription = $crud
        .model<AppNameUser>(user.user.uid)
        .streamUnique<AppNameUserSettings>()
        .listen(_settings.add);
    _cSubscription = $crud
        .model<AppNameUser>(user.user.uid)
        .streamUnique<AppNameUserCapabilities>()
        .map((i) => i ?? AppNameUserCapabilities())
        .listen(_capabilities.add);
    $user.setSelfAtomic<AppNameUser>((i) => i!.copyWith(
          lastLogin: DateTime.timestamp(),
        ));
  }

  Future<void> unbind() async {
    await Future.wait([
      _uSubscription?.cancel() ?? Future.value(),
      _sSubscription?.cancel() ?? Future.value(),
      _cSubscription?.cancel() ?? Future.value(),
    ]);
    _user.add(null);
    _settings.add(null);
    _capabilities.add(null);
  }
}
