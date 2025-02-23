import 'package:occult/util/tasks.dart';
import 'package:universal_io/io.dart';

class TCreateAppProject extends OTaskJob {
  final String app;
  final String org;

  TCreateAppProject(this.app, this.org)
      : super("Create ${app} project with org ${org}");

  @override
  Future<void> run() => add(
        TRun(
          Platform.isWindows ? "flutter.bat" : "flutter",
          [
            "create",
            "--platforms=android,ios,web,linux,windows,macos",
            "-a",
            "java",
            "-t",
            "app",
            "--suppress-analytics",
            "-e",
            "--org",
            org,
            "--project-name",
            app,
            "--no-pub",
            "--overwrite",
            "-v",
            app
          ],
        ),
      ).then((_) => add(TAppDeps(app))).then((_) => add(TAppDevDeps(app)));
}

class TAppDeps extends OTaskJob {
  final String app;

  TAppDeps(this.app) : super("Get ${app} dependencies");

  @override
  Future<void> run() => add(
        TRun(
          Platform.isWindows ? "flutter.bat" : "flutter",
          [
            "pub",
            "add",
            "fire_crud",
            "fire_crud_flutter",
            "arcane",
            "arcane_auth",
            "toxic",
            "toxic_flutter",
            "pylon",
            "rxdart",
            "firebase_core",
            "firebase_auth",
            "cloud_firestore",
            "firebase_analytics",
            "firebase_crashlytics",
            "firebase_performance",
            "firebase_storage",
            "hive",
            "hive_flutter",
            "flutter_native_splash",
            "serviced",
            "fast_log",
            "fire_api",
            "fire_api_flutter",
            "file_picker",
            "jiffy",
            "http",
            "throttled",
            "crypto",
          ],
          workingDirectory:
              "${Directory.current.absolute.path}${Platform.pathSeparator}$app",
        ),
      );
}

class TAppDevDeps extends OTaskJob {
  final String app;

  TAppDevDeps(this.app) : super("Get ${app} dev dependencies");

  @override
  Future<void> run() => add(
        TRun(
          Platform.isWindows ? "flutter.bat" : "flutter",
          ["pub", "add", "flutter_launcher_icons", "--dev"],
          workingDirectory:
              "${Directory.current.absolute.path}${Platform.pathSeparator}$app",
        ),
      );
}
