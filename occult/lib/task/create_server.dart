import 'package:occult/task/install_libmagick.dart';
import 'package:occult/util.dart';
import 'package:occult/util/tasks.dart';
import 'package:universal_io/io.dart';

class TCreateServerProject extends OTaskJob {
  final String app;
  final String org;

  TCreateServerProject(this.app, this.org)
      : super("Create ${app}_server project with org ${org}");

  @override
  Future<void> run() => add(
        TRun(
          flutterPlatformCommand,
          [
            "create",
            "--platforms=linux",
            "-t",
            "app",
            "--suppress-analytics",
            "-e",
            "--org",
            org,
            "--project-name",
            "${app}_server",
            "--no-pub",
            "--overwrite",
            "-v",
            "${app}_server",
          ],
        ),
      ).then((_) =>
          Future.wait([add(TServerDeps(app)), add(TInstallLibMagick(app))]));
}

class TServerDeps extends OTaskJob {
  final String app;

  TServerDeps(this.app) : super("Get ${app}_server dependencies");

  @override
  Future<void> run() => add(TRun(
        flutterPlatformCommand,
        [
          "pub",
          "add",
          "fire_api",
          "fire_api_dart",
          "fire_crud",
          "shelf",
          "shelf_router",
          "precision_stopwatch",
          "google_cloud",
          "http",
          "toxic",
          "shelf_cors_headers",
          "memcached",
          "multimedia",
          "fast_log",
          "uuid",
          "rxdart",
          "crypto",
          "dart_jsonwebtoken",
          "x509",
          "jiffy",
        ],
        workingDirectory:
            "${Directory.current.absolute.path}${Platform.pathSeparator}${app}_server",
      ));
}
