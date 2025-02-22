import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:interact/interact.dart';
import 'package:occult/util.dart';
import 'package:tint/tint.dart';

void instruct(String message) {
  print(message.yellow());
}

void success(String message) {
  print(message.green());
}

void confirmMain(String message) {
  if (!Confirm.withTheme(
          theme: theme,
          prompt: message,
          defaultValue: true,
          waitForNewLine: true)
      .interact()) {
    exit(0);
  }
}

class OccultConfiguration {
  final String path;
  final String name;
  final String org;
  final String firebaseProjectId;
  final String baseClassName;

  OccultConfiguration({
    required this.path,
    required this.name,
    required this.org,
    required this.firebaseProjectId,
    required this.baseClassName,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'organization': org,
      'id': firebaseProjectId,
      'className': baseClassName,
    };
  }

  factory OccultConfiguration.fromJson(String path, Map<String, dynamic> json) {
    return OccultConfiguration(
        path: path,
        name: json['name'],
        org: json['organization'],
        firebaseProjectId: json['id'],
        baseClassName: json['className']);
  }
}

Future<void> buildModels(OccultConfiguration config) async {
  final process = await Process.start(
    'dart',
    ['run', "build_runner", "build", "--delete-conflicting-outputs"],
    mode: ProcessStartMode.inheritStdio,
    workingDirectory:
        "${config.path}${Platform.pathSeparator}${config.name}_models",
  );

  int exitCode = await process.exitCode;

  if (exitCode != 0) {
    throw Exception(
        "Failed to run build_runner build on ${config.name}_models");
  }
}

Future<OccultConfiguration?> findOccultConfiguration() async {
  Directory d = Directory.current;
  OccultConfiguration? config = await getOccultConfiguration(d.path);
  if (config != null) return config;
  instruct("* Failed to find occult configuration in ${d.path}");
  config = await getOccultConfiguration(d.parent.path);
  if (config != null) return config;
  instruct("* Failed to find occult configuration in ${d.parent.path}");
  config = await getOccultConfiguration(d.parent.parent.path);
  if (config != null) return config;
  instruct("* Failed to find occult configuration in ${d.parent.parent.path}");
  return null;
}

Future<OccultConfiguration?> getOccultConfiguration(String path) async {
  File f = File(
      "${path}/config/occult.json".replaceAll("/", Platform.pathSeparator));

  if (await f.exists()) {
    OccultConfiguration configuration =
        OccultConfiguration.fromJson(path, jsonDecode(await f.readAsString()));
    success(
        "Found Occult Configuration ${configuration.baseClassName}, ${configuration.firebaseProjectId}");
    return configuration;
  }

  return null;
}

Future<void> runFlutterFireInteractive(String project, String app) async {
  final process = await Process.start(
    'flutterfire',
    [
      'configure',
      '--project',
      project,
      '--platforms',
      'android,ios,macos,web,linux,windows'
    ],
    mode: ProcessStartMode.inheritStdio,
    workingDirectory:
        "${Directory.current.absolute.path}${Platform.pathSeparator}$app",
  );

  int exitCode = await process.exitCode;

  if (exitCode != 0) {
    throw Exception("Failed to run flutterfire init");
  }
}

Future<void> downloadTemplates(
    {required String project,
    required String baseClassName,
    required String jsonfilename,
    required String firebaseprojectid}) async {
  final loader = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) =>
        done ? 'Acquired Arcane Templates' : 'Acquiring Arcane Templates',
  ).interact();
  File occult = File("occult.zip");
  instruct(
      "Downloading Arcane Templates in https://github.com/ArcaneArts/Occult/archive/refs/heads/main.zip");
  await HttpClient()
      .getUrl(Uri.parse(
          "https://github.com/ArcaneArts/Occult/archive/refs/heads/main.zip"))
      .then((request) => request.close())
      .then((response) => response.pipe(occult.openWrite()));

  final inputStream = InputFileStream('occult.zip');
  final archive = ZipDecoder().decodeStream(inputStream);

  for (final file in archive) {
    if (file.isFile) {
      List<String> comp = file.name.split("/");

      if (comp.length > 1) {
        comp = comp.sublist(1);
      }

      if (!file.name.endsWith(".t") &&
          comp.isNotEmpty &&
          comp.first == "assets") {
        comp.remove(0);
        File dest = File(
            "$project${Platform.pathSeparator}${comp.join(Platform.pathSeparator)}");
        await dest.parent.create(recursive: true);
        final os = OutputFileStream(dest.path);
        file.writeContent(os);
        instruct("EXTR ${dest.path}");
        continue;
      }

      if (!file.name.endsWith(".t")) {
        continue;
      }
      await Directory(
              '.occult/${file.name}'.replaceAll("/", Platform.pathSeparator))
          .parent
          .create(recursive: true);
      final outputStream = OutputFileStream(
          '.occult/${file.name}'.replaceAll("/", Platform.pathSeparator));
      instruct(
          "EXTR ${'.occult/${file.name}'.replaceAll("/", Platform.pathSeparator)}");
      file.writeContent(outputStream);
      await outputStream.close();
    }
  }

  await occult.delete();

  Directory dir = Directory(
      ".occult/Occult-main/template".replaceAll("/", Platform.pathSeparator));

  for (Directory i
      in dir.listSync(recursive: false).whereType<Directory>().toList()) {
    if (i.path.split(Platform.pathSeparator).last.contains("appname")) {
      List<String> seg = i.path.split(Platform.pathSeparator);
      seg[seg.length - 1] = seg[seg.length - 1].replaceAll("appname", project);
      await i.rename(seg.join(Platform.pathSeparator));
      instruct("MV ${i.path} to ${seg.join(Platform.pathSeparator)}");
    }
  }

  for (File i in dir.listSync(recursive: true).whereType<File>().toList()) {
    if (i.path.endsWith(".t") &&
        i.path.split(Platform.pathSeparator).last.contains("appname")) {
      List<String> seg = i.path.split(Platform.pathSeparator);
      seg[seg.length - 1] = seg[seg.length - 1].replaceAll("appname", project);
      await i.rename(seg.join(Platform.pathSeparator));
      instruct("MV ${i.path} to ${seg.join(Platform.pathSeparator)}");
    }
  }

  for (File i in dir.listSync(recursive: true).whereType<File>().toList()) {
    if (i.path.endsWith(".t")) {
      await i.writeAsString((await i.readAsString())
          .replaceAll("appname", project)
          .replaceAll("AppName", baseClassName)
          .replaceAll("firebaseprojectid", firebaseprojectid)
          .replaceAll("jsonfilename", jsonfilename));
      instruct("PATCH ${i.path}");
    }
  }

  loader.done();
}

Future<void> applyTemplate(String project, String baseClassName) async {
  final loader = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) => done
        ? 'Applied Arcane Template for $baseClassName in /$project'
        : 'Applying arcane Template for $baseClassName in /$project',
  ).interact();

  Directory dir = Directory(".occult/Occult-main/template/${project}"
      .replaceAll("/", Platform.pathSeparator));

  if (await dir.exists()) {
    Directory output = Directory(project);

    for (File i in dir.listSync(recursive: true).whereType<File>().toList()) {
      if (i.path.endsWith(".t")) {
        List<String> seg = "${output.path}/${i.path.replaceFirst(dir.path, "")}"
            .replaceAll("//", "/")
            .replaceAll("/", Platform.pathSeparator)
            .split(Platform.pathSeparator);
        seg[seg.length - 1] = seg[seg.length - 1].replaceAll(".t", "");
        File dest = File(seg.join(Platform.pathSeparator));
        instruct("INSTALL ${dest.path}");
        String src = await i.readAsString();
        await dest.parent.create(recursive: true);
        await dest.writeAsString(src);
      }
    }
  } else {
    instruct("SKIP /$project missing ${dir.path}");
  }

  loader.done();
}

Future<void> installLibMagick(String project) async {
  final loader = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) => done
        ? 'Installed Image Magick FFI in /$project'
        : 'Installing Image Magick FFI in /$project',
  ).interact();
  await Directory("$project${Platform.pathSeparator}ffi")
      .create(recursive: true);
  File file = File(
      "$project${Platform.pathSeparator}ffi${Platform.pathSeparator}libimage_magick_ffi.so");
  await HttpClient()
      .getUrl(Uri.parse(
          "https://raw.githubusercontent.com/ArcaneArts/multimedia/refs/heads/main/lib/libraries/libimage_magick_ffi.so"))
      .then((request) => request.close())
      .then((response) => response.pipe(file.openWrite()));
  loader.done();
}

Future<void> createStorageRules() async {
  final creatingLoader = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) =>
        done ? 'Created storage.rules config' : 'Creating storage.rules config',
  ).interact();
  await File(
          "config${Platform.pathSeparator}firebase${Platform.pathSeparator}storage.rules")
      .writeAsString("""
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
      """
          .trim());
  creatingLoader.done();
}

Future<void> createOccultConfig(
    {required String name,
    required String org,
    required String firebaseProjectId,
    required String baseClassName}) async {
  final creatingLoader = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) =>
        done ? 'Created occult config' : 'Creating occult config',
  ).interact();
  await File("config${Platform.pathSeparator}occult.json")
      .writeAsString(JsonEncoder.withIndent("  ").convert({
    "name": name,
    "organization": org,
    "id": firebaseProjectId,
    "className": baseClassName,
  }));
  creatingLoader.done();
}

Future<void> createFirestoreRules() async {
  final creatingLoader = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) => done
        ? 'Created firestore.rules config'
        : 'Creating firestore.rules config',
  ).interact();
  await File(
          "config${Platform.pathSeparator}firebase${Platform.pathSeparator}firestore.rules")
      .writeAsString(r"""
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
          .trim());
  creatingLoader.done();
}

Future<void> createFirebaseIndexesJson() async {
  final creatingLoader = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) => done
        ? 'Created firebase.indexes.json config'
        : 'Creating firebase.indexes.json config',
  ).interact();
  await File(
          "config${Platform.pathSeparator}firebase${Platform.pathSeparator}firebase.indexes.json")
      .writeAsString(JsonEncoder.withIndent("  ")
          .convert({"indexes": [], "fieldOverrides": []}));
  creatingLoader.done();
}

Future<void> createFirebaseJson(String project, String app) async {
  final creatingLoader = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) =>
        done ? 'Created firebase.json config' : 'Creating firebase.json config',
  ).interact();
  await File("firebase.json")
      .writeAsString(JsonEncoder.withIndent("  ").convert({
    "firestore": {
      "rules":
          "config${Platform.pathSeparator}firebase${Platform.pathSeparator}firestore.rules",
      "indexes":
          "config${Platform.pathSeparator}firebase${Platform.pathSeparator}firestore.indexes.json"
    },
    "hosting": [
      {
        "site": "$project-beta",
        "public": "$app/build/web",
        "predeploy": ["cd $app && flutter build web --release --wasm"],
        "ignore": ["firebase.json", "**/node_modules/**"]
      },
      {
        "site": "$project",
        "public": "$app/build/web",
        "predeploy": ["cd $app && flutter build web --release --wasm"],
        "ignore": ["firebase.json", "**/node_modules/**"]
      }
    ],
    "storage": {
      "rules":
          "config${Platform.pathSeparator}firebase${Platform.pathSeparator}storage.rules"
    }
  }));
  creatingLoader.done();
}

Future<void> createFirebaseRC(String projectname) async {
  final creatingLoader = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) =>
        done ? 'Created .firebaserc config' : 'Creating .firebaserc config',
  ).interact();
  await File(".firebaserc").writeAsString(JsonEncoder.withIndent("  ").convert({
    "projects": {"default": projectname}
  }));
  creatingLoader.done();
}

Future<void> enableGcloudArtifactRegistry(String project) async {
  final runner = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) => done
        ? 'Enabled GCP Artifact Registry'
        : 'Enabling GCP Artifact Registry',
  ).interact();
  //.// gcloud services enable run.googleapis.com artifactregistry.googleapis.com --project=YOUR_PROJECT_ID
  ProcessResult p = await Process.run("gcloud", [
    "services",
    "enable",
    "artifactregistry.googleapis.com",
    "--project=$project"
  ]);
  if (p.exitCode != 0) {
    print("FAILED TO RUN PROCESS! ${p.exitCode}");
    print(p.stdout);
    print("---");
    print(p.stderr);
    print("---");
    throw Exception("Failed to gcloud artifact registry");
  }

  runner.done();
}

Future<void> enableGcloudRun(String project) async {
  final runner = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) =>
        done ? 'Enabled GCP Cloud Run' : 'Enabling GCP Cloud Run',
  ).interact();
  //.// gcloud services enable run.googleapis.com artifactregistry.googleapis.com --project=YOUR_PROJECT_ID
  ProcessResult p = await Process.run("gcloud",
      ["services", "enable", "run.googleapis.com", "--project=$project"]);
  if (p.exitCode != 0) {
    print("FAILED TO RUN PROCESS! ${p.exitCode}");
    print(p.stdout);
    print("---");
    print(p.stderr);
    print("---");
    throw Exception("Failed to gcloud artifact registry");
  }

  runner.done();
}

Future<void> addPathDependency(String name, String dep) async {
  final setupDependencies = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) =>
        done ? 'Linked /$dep to /$name' : 'Linking /$dep to /$name',
  ).interact();
  ProcessResult p = await Process.run(
      "flutter", ["pub", "add", dep, "--path", "../$dep"],
      workingDirectory:
          "${Directory.current.absolute.path}${Platform.pathSeparator}$name");
  if (p.exitCode != 0) {
    print("FAILED TO RUN PROCESS! ${p.exitCode}");
    print(p.stdout);
    print("---");
    print(p.stderr);
    print("---");
    throw Exception("Failed to install $dep for $name");
  }

  setupDependencies.done();
}

Future<void> createFlutterProject(String name, String org) async {
  final creatingLoader = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) => done
        ? 'Created /$name Flutter project'
        : 'Creating /$name Flutter project',
  ).interact();
  ProcessResult p = await Process.run("flutter", [
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
    name,
    "--no-pub",
    "--overwrite",
    "-v",
    name
  ]);
  if (p.exitCode != 0) {
    print("FAILED TO RUN PROCESS! ${p.exitCode}");
    print(p.stdout);
    print("---");
    print(p.stderr);
    print("---");
    throw Exception("Failed to create Flutter project");
  }
  creatingLoader.done();
  await setupAppDependencies(name);
}

Future<void> createServerProject(
    String name, String rootName, String org) async {
  final creatingLoader = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) => done
        ? 'Created /$name Flutter project'
        : 'Creating /$name Flutter project',
  ).interact();
  ProcessResult p = await Process.run("flutter", [
    "create",
    "--platforms=linux",
    "-t",
    "app",
    "--suppress-analytics",
    "-e",
    "--org",
    org,
    "--project-name",
    name,
    "--no-pub",
    "--overwrite",
    "-v",
    name
  ]);
  if (p.exitCode != 0) {
    print("FAILED TO RUN PROCESS! ${p.exitCode}");
    print(p.stdout);
    print("---");
    print(p.stderr);
    print("---");
    throw Exception("Failed to create Flutter project");
  }
  creatingLoader.done();
  await setupServerDependencies(name, rootName);
}

Future<void> createModelsPackage(String name) async {
  final creatingLoader = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) =>
        done ? 'Created /$name package' : 'Creating /$name package',
  ).interact();
  ProcessResult p = await Process.run("flutter", [
    "create",
    "-t",
    "package",
    "--suppress-analytics",
    "--project-name",
    name,
    "--no-pub",
    "--overwrite",
    "-v",
    name
  ]);
  if (p.exitCode != 0) {
    print("FAILED TO RUN PROCESS! ${p.exitCode}");
    print(p.stdout);
    print("---");
    print(p.stderr);
    print("---");
    throw Exception("Failed to create Flutter models package");
  }
  creatingLoader.done();
  await setupModelsDependencies(name);
}

Future<void> setupAppDependencies(String name) async {
  final setupDependencies = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) => done
        ? 'Installed Dependencies for /$name'
        : 'Installing Dependencies /$name',
  ).interact();
  ProcessResult p = await Process.run(
      "flutter",
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
          "${Directory.current.absolute.path}${Platform.pathSeparator}$name");
  if (p.exitCode != 0) {
    print("FAILED TO RUN PROCESS! ${p.exitCode}");
    print(p.stdout);
    print("---");
    print(p.stderr);
    print("---");
    throw Exception("Failed to install deps for $name");
  }

  p = await Process.run(
      "flutter", ["pub", "add", "flutter_launcher_icons", "--dev"],
      workingDirectory:
          "${Directory.current.absolute.path}${Platform.pathSeparator}$name");
  if (p.exitCode != 0) {
    print("FAILED TO RUN PROCESS! ${p.exitCode}");
    print(p.stdout);
    print("---");
    print(p.stderr);
    print("---");
    throw Exception("Failed to install dev deps for $name");
  }

  setupDependencies.done();
}

Future<void> setupServerDependencies(String name, String rootName) async {
  final setupDependencies = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) => done
        ? 'Installed Dependencies for /$name'
        : 'Installing Dependencies /$name',
  ).interact();
  ProcessResult p = await Process.run(
      "flutter",
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
          "${Directory.current.absolute.path}${Platform.pathSeparator}$name");
  if (p.exitCode != 0) {
    print("FAILED TO RUN PROCESS! ${p.exitCode}");
    print(p.stdout);
    print("---");
    print(p.stderr);
    print("---");
    throw Exception("Failed to install deps for $name");
  }

  setupDependencies.done();
}

Future<void> setupModelsDependencies(String name) async {
  final setupDependencies = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) => done
        ? 'Installed Dependencies for /$name'
        : 'Installing Dependencies for /$name',
  ).interact();
  ProcessResult p = await Process.run(
      "flutter",
      [
        "pub",
        "add",
        "crypto",
        "dart_mappable",
        "equatable",
        "fire_crud",
        "toxic",
        "rxdart",
        "rxdart",
        "fast_log",
        "fire_api",
        "jiffy",
        "throttled",
      ],
      workingDirectory:
          "${Directory.current.absolute.path}${Platform.pathSeparator}$name");
  if (p.exitCode != 0) {
    print("FAILED TO RUN PROCESS! ${p.exitCode}");
    print(p.stdout);
    print("---");
    print(p.stderr);
    print("---");
    throw Exception("Failed to install deps for $name");
  }

  p = await Process.run("flutter",
      ["pub", "add", "build_runner", "dart_mappable_builder", "--dev"],
      workingDirectory:
          "${Directory.current.absolute.path}${Platform.pathSeparator}$name");
  if (p.exitCode != 0) {
    print("FAILED TO RUN PROCESS! ${p.exitCode}");
    print(p.stdout);
    print("---");
    print(p.stderr);
    print("---");
    throw Exception("Failed to install dev deps for $name");
  }

  setupDependencies.done();
}
