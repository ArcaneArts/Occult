import 'dart:math';

import 'package:appname/application.dart';
import 'package:appname/firebase_options.dart';
import 'package:appname/service/server_service.dart';
import 'package:appname/service/user_service.dart';
import 'package:appname_models/appname_models.dart';
import 'package:arcane/arcane.dart';
import 'package:arcane_auth/arcane_auth.dart';
import 'package:fire_api_flutter/fire_api_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:serviced/serviced.dart';

void main() => _init().then((_) => runApp(AppNameApplication()));

late Box hotBox;
late LazyBox coldBox;

bool isWideScreen(BuildContext context) =>
    MediaQuery.of(context).size.width > 600;

Future<void> _init() async {
  FlutterNativeSplash.preserve(
      widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
  setupArcaneDebug();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  $registerModels();
  FirebaseFirestoreDatabase.create().debugLogging = true;
  _initHive();
  services()
    ..register<CMSService>(() => CMSService())
    ..register<UserService>(() => UserService());
  await Future.wait([_initAuth(), services().waitForStartup()]);
}

Future<void> _initAuth() async {
  initArcaneAuth(
      allowAnonymous: false,
      autoLink: false,
      signInConfigs: [],
      onBind: svc<UserService>().bind,
      onUnbind: svc<UserService>().unbind);
}

Future<void> _initHive() async {
  await Hive.initFlutter("appname");
  await Future.wait([
    Hive.openBox("appname.AppName.hb",
            encryptionCipher: HiveAesCipher(
                Random("appname.AppName.hb".hashCode ^ 0x33EF69DF3D1)
                    .nextInts(32)))
        .then((box) => hotBox = box),
    Hive.openLazyBox("appname.AppName.cb",
            encryptionCipher: HiveAesCipher(
                Random("appname.AppName.cb".hashCode ^ 0x73DE39337F)
                    .nextInts(32)))
        .then((box) => coldBox = box),
  ]);
}

extension _XRand on Random {
  List<int> nextInts(int count) => List.generate(count, (_) => nextInt(256));
}
