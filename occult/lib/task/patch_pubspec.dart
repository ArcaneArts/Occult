import 'dart:convert';
import 'dart:io';

import 'package:occult/util/tasks.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

class TPatchAppPubspec extends OTaskJob {
  final String app;

  TPatchAppPubspec(this.app) : super("Patch ${app} pubspec.yaml");

  @override
  Future<void> run() async {
    String contents = await HttpClient()
        .getUrl(Uri.parse(
            "https://raw.githubusercontent.com/ArcaneArts/arcane/refs/heads/main/example/pubspec.yaml"))
        .then((request) => request.close())
        .then((response) => response.transform(Utf8Decoder()).join());

    var doc = loadYaml(contents);
    YamlEditor pubspec = YamlEditor(
        File("$app${Platform.pathSeparator}pubspec.yaml").readAsStringSync());
    pubspec.update(["flutter"], doc["flutter"]);
    pubspec.update(["flutter_native_splash"],
        {"color": "#230055", "image": "assets/icon/splash.png"});
    pubspec.update([
      "flutter_launcher_icons"
    ], {
      "ios": true,
      "image_path": "assets/icon/icon.png",
      "android": "launcher_icon",
      "web": {"generate": true},
      "windows": {"generate": true},
      "macos": {"generate": true}
    });
    pubspec.update([
      "scripts"
    ], {
      "update_occult": "dart pub global activate occult",
      "build_models": "occult build --models",
      "build_launcher_icons": "occult build --launcher-icons",
      "build_splash_screen": "occult build --splash-screen",
      "run_server": "occult run --server",
      "deploy_web_release": "occult deploy --web-release",
      "deploy_web_beta": "occult deploy --web",
      "deploy_server": "occult deploy --server-release"
    });
    return add(TMakeFile("$app${Platform.pathSeparator}pubspec.yaml",
        pubspec.toString().replaceAll("\\/", "/")));
  }
}
