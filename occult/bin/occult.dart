import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:chat_color/chat_color.dart';
import 'package:cli_annotations/cli_annotations.dart';
import 'package:interact/interact.dart';
import 'package:tint/tint.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

part 'occult.g.dart';

void main(List<String> arguments) async => await OccultRunner().run(arguments);

Theme theme = Theme(
  inputPrefix: '?'.padRight(2).yellow(),
  inputSuffix: '›'.padLeft(2).grey(),
  successPrefix: '✔'.padRight(2).green(),
  successSuffix: '·'.padLeft(2).grey(),
  errorPrefix: '✘'.padRight(2).red(),
  hiddenPrefix: '****',
  messageStyle: (x) => x.bold(),
  errorStyle: (x) => x.red(),
  hintStyle: (x) => '($x)'.grey(),
  valueStyle: (x) => x.green(),
  defaultStyle: (x) => x.cyan(),
  activeItemPrefix: '❯'.green(),
  inactiveItemPrefix: ' ',
  activeItemStyle: (x) => x.cyan(),
  inactiveItemStyle: (x) => x,
  checkedItemPrefix: '✔'.green(),
  uncheckedItemPrefix: ' ',
  pickedItemPrefix: '❯'.green(),
  unpickedItemPrefix: ' ',
  showActiveCursor: false,
  progressPrefix: '',
  progressSuffix: '',
  emptyProgress: '░',
  filledProgress: '█',
  leadingProgress: '█',
  emptyProgressStyle: (x) => x,
  filledProgressStyle: (x) => x,
  leadingProgressStyle: (x) => x,
  spinners: '⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'.split(''),
  spinningInterval: 80,
);

void instruct(String message) {
  print(message.spin(0xfff49e, 0xffdd9e).chatColor);
}

void confirmMain(String message) {
  if (!Confirm.withTheme(
          theme: theme,
          prompt: message.spin(0x524fff, 0xd175ff).chatColor,
          defaultValue: true,
          waitForNewLine: true)
      .interact()) {
    exit(0);
  }
}

@cliRunner
class OccultRunner extends _$OccultRunner {
  @cliCommand
  Future<void> create() async {
    if (!await ensureShitInstalled()) {
      exit(0);
    }

    instruct("The current directory is ${Directory.current.path}");
    await Directory("config${Platform.pathSeparator}keys")
        .create(recursive: true);
    instruct(
        "Your project will be created as a subfolder in this directory, along with the server & other configs. This should be the root of your git.");
    confirmMain(
        "Welcome to Occult CLI! You are about to create a new project. Do you want to continue?");
    instruct(
        "1. Create a new Firebase Project at https://console.firebase.google.com/");
    instruct("2. Obtain the Firebase Project ID from the Firebase Console URL");
    String firebaseProjectID = Input(
      prompt: 'Firebase Project ID',
      defaultValue: '',
      initialText: '',
      validator: (String x) {
        if (x.trim().isEmpty) {
          return throw ValidationError('Firebase Project ID cannot be empty');
        }

        return true;
      },
    ).interact();
    confirmMain(
        "1. Create a new Firestore Database at https://console.firebase.google.com/project/$firebaseProjectID/firestore (use nam5 if us based)");
    instruct("Setup at least one auth provider. ");
    instruct("- Email/Password (optional)");
    instruct("- Google (optional, requires setup later)");
    instruct("- Apple (optional, requires setup later, ios/macos only)");
    confirmMain(
        "2. Hit Get Started & setup auth at https://console.firebase.google.com/project/$firebaseProjectID/authentication");
    confirmMain("3. Enable Billing in Firebase (upgrade to pay as you go)");
    instruct(
        "4. Create a service account in google cloud at https://console.cloud.google.com/iam-admin/serviceaccounts/create?hl=en&project=${firebaseProjectID}");
    instruct("Service account name: ${firebaseProjectID}-server");
    instruct("Service account id: ${firebaseProjectID}-server");
    confirmMain("4.1. Click Create and Continue in Google Cloud");
    confirmMain(
        "4.2. Add the role Basic > Owner to the service account & Click Continue & Click Done");
    confirmMain(
        "4.3. Select ${firebaseProjectID}-server@${firebaseProjectID}.iam.gserviceaccount.com in the list");
    confirmMain(
        "4.4. Under the KEYS tab click ADD KEY > Create new key > JSON");

    String? sak;
    while (sak == null) {
      confirmMain(
          "4.5. Put the JSON file into ${Directory.current.path}${Platform.pathSeparator}config${Platform.pathSeparator}keys/<HERE>");

      Directory keysDir = Directory("config${Platform.pathSeparator}keys");
      if (!await keysDir.exists()) {
        await keysDir.create(recursive: true);
      }

      sak = (await keysDir
              .list(recursive: false, followLinks: false)
              .where((i) =>
                  i is File &&
                  i.path.endsWith(".json") &&
                  i.path
                      .split(Platform.pathSeparator)
                      .last
                      .startsWith("${firebaseProjectID}-"))
              .toList())
          .whereType<File>()
          .firstOrNull
          ?.path;
    }

    instruct("Service Account Key Found!");
    instruct("  $sak");

    String appDomainOrg = Input(
      prompt:
          '5. ROOT Organization Name (dont append your app name to the end!!!)',
      defaultValue: 'art.arcane',
      initialText: '',
      validator: (String x) => true,
    ).interact();
    String appProjectName = Input(
      prompt: '6. Flutter App Name (lower_road_kill)',
      defaultValue: 'app',
      initialText: '',
      validator: (String x) {
        if (x.trim().isEmpty) {
          return throw ValidationError('App Name cannot be empty');
        }

        if (x.trim().contains(" ")) {
          return throw ValidationError(
              'App Name cannot contain spaces "My Camera App" -> "my_camera_app"');
        }

        if (x.trim().contains("-") ||
            x.trim().contains(".") ||
            x.trim().contains("/") ||
            x.trim().contains(",") ||
            x.trim().contains("\\")) {
          return throw ValidationError(
              'App Name cannot contain (-,./\\). Use underscores! "My Camera App" -> "my_camera_app"');
        }

        if (x.trim().toLowerCase() != x.trim()) {
          return throw ValidationError(
              'App Name cannot contain uppercase letters. "My Camera App" -> "my_camera_app"');
        }

        return true;
      },
    ).interact();

    String defBaseClassName = appProjectName
        .split("_")
        .map((e) =>
            e.substring(0, 1).toUpperCase() + e.substring(1).toLowerCase())
        .join();
    String baseClassName = Input(
      prompt: '7. Flutter App Base Class Name (UpperCamelCase)',
      defaultValue: defBaseClassName,
      initialText: '',
      validator: (String x) {
        if (x.trim().isEmpty) {
          return throw ValidationError('App Name cannot be empty');
        }

        if (x.trim().contains(" ")) {
          return throw ValidationError(
              'App Name cannot contain spaces "My Camera App" -> "MyCameraApp"');
        }

        if (x.trim().contains("-") ||
            x.trim().contains(".") ||
            x.trim().contains("/") ||
            x.trim().contains(",") ||
            x.trim().contains("\\")) {
          return throw ValidationError(
              'App Name cannot contain (-,./\\). Use underscores! "My Camera App" -> "MyCameraApp"');
        }

        return true;
      },
    ).interact();

    instruct("${Directory.current.absolute.path}");
    instruct("  /${appProjectName} - Flutter App (client)");
    instruct("  /${appProjectName}_models - Dart Package (models)");
    instruct("  /${appProjectName}_server - Flutter App (server)");
    print("");
    confirmMain("Are you ready to create your projects?");
    await setupAll(
        jsonfilename: sak.split(Platform.pathSeparator).last,
        name: appProjectName,
        org: appDomainOrg,
        firebaseProjectId: firebaseProjectID,
        baseClassName: baseClassName);
  }
}

Future<bool> ensureShitInstalled() async {
  bool flutterInstalled = await harassInstallCLI(
      tool: "flutter",
      check: 'Checking if Flutter is setup'.spin(0xd303fc, 0xfc03c6).chatColor,
      good: 'Flutter is setup at least'.spin(0x7dff7f, 0x03fc6b).chatColor,
      bad:
          'Flutter is not setup correctly. Idk fix your path bro. use which/where flutter'
              .spin(0xeb5b34, 0xfa0060)
              .chatColor);

  bool dartInstalled = await harassInstallCLI(
      tool: "dart",
      check: 'Checking if Dart is setup (it really should be)'
          .spin(0xd303fc, 0xfc03c6)
          .chatColor,
      good: 'Dart is setup (i would have been terrified if it wanst)'
          .spin(0x7dff7f, 0x03fc6b)
          .chatColor,
      bad:
          'I dont know how, I dont know why, but for some reason dart isnt setup correctly. Try which/where dart? idfk man.'
              .spin(0xeb5b34, 0xfa0060)
              .chatColor);

  bool npmInstalled = await harassInstallCLI(
      tool: "npm",
      check: 'Checking if npm is installed'.spin(0xd303fc, 0xfc03c6).chatColor,
      good: 'NPM is installed'.spin(0x7dff7f, 0x03fc6b).chatColor,
      bad:
          "${'NPM is not installed! Install v18+ it at '.spin(0xeb5b34, 0xfa0060)}&r@4&fhttps://nodejs.org/en&r"
              .chatColor);

  bool firebaseInstalled = await harassInstallCLI(
      tool: "firebase",
      check: 'Checking if Firebase CLI is installed'
          .spin(0xd303fc, 0xfc03c6)
          .chatColor,
      good: 'Firebase CLI is installed'.spin(0x7dff7f, 0x03fc6b).chatColor,
      bad:
          "${'Firebase CLI is not installed! Install it with '.spin(0xeb5b34, 0xfa0060)}&r@4&fnpm install -g firebase-tools&r"
              .chatColor);

  bool flutterfireInstalled = await harassInstallCLI(
      tool: "flutterfire",
      check: 'Checking if FlutterFire is installed'
          .spin(0xd303fc, 0xfc03c6)
          .chatColor,
      good: 'FlutterFire is installed'.spin(0x7dff7f, 0x03fc6b).chatColor,
      bad:
          "${'FlutterFire is not installed! Install it with '.spin(0xeb5b34, 0xfa0060)}&r@4&fdart pub global activate flutterfire_cli&r"
              .chatColor);

  bool gcloudInstalled = await harassInstallCLI(
      tool: "gcloud",
      check:
          'Checking if gcloud is installed'.spin(0xd303fc, 0xfc03c6).chatColor,
      good: 'gcloud is installed'.spin(0x7dff7f, 0x03fc6b).chatColor,
      bad:
          "${'gcloud is not installed! Install it at '.spin(0xeb5b34, 0xfa0060)}&r@4&fhttps://cloud.google.com/sdk/docs/install&r"
              .chatColor);

  bool dockerInstalled = await harassInstallCLI(
      tool: "docker",
      check:
          'Checking if Docker is installed'.spin(0xd303fc, 0xfc03c6).chatColor,
      good: 'Docker is installed'.spin(0x7dff7f, 0x03fc6b).chatColor,
      bad:
          "${'Docker is not installed! Install Docker Desktop it at '.spin(0xeb5b34, 0xfa0060)}&r@4&fhttps://www.docker.com/get-started/&r"
              .chatColor);

  return flutterInstalled &&
      dartInstalled &&
      firebaseInstalled &&
      npmInstalled &&
      flutterfireInstalled &&
      gcloudInstalled &&
      dockerInstalled;
}

Future<void> setupAll(
    {required String name,
    required String org,
    required String firebaseProjectId,
    required String baseClassName,
    required String jsonfilename}) async {
  await Directory("config${Platform.pathSeparator}firebase")
      .create(recursive: true);
  await runGcloudLogin();
  await enableGcloudArtifactRegistry(firebaseProjectId);
  await enableGcloudRun(firebaseProjectId);
  await createFirebaseRC(firebaseProjectId);
  await createFirebaseJson(firebaseProjectId, name);
  await createFirebaseIndexesJson();
  await createFirestoreRules();
  await createStorageRules();
  await createModelsPackage("${name}_models");
  await createFlutterProject(name, org);
  await createServerProject("${name}_server", name, org);
  await addPathDependency(name, "${name}_models");
  await addPathDependency("${name}_server", "${name}_models");
  await patchAppPubspec(name);
  await installLibMagick("${name}_server");
  await runFirebaseLogin();
  await runFlutterFireInteractive(firebaseProjectId, name);
  await downloadTemplates(
      project: name,
      baseClassName: baseClassName,
      firebaseprojectid: firebaseProjectId,
      jsonfilename: jsonfilename);
  await applyTemplate("${name}_models", baseClassName);
  await runBuildRunner("${name}_models");
  await applyTemplate(name, baseClassName);
  await applyTemplate("${name}_server", baseClassName);
  await copyFile(
      "config/keys/$jsonfilename".replaceAll("/", Platform.pathSeparator),
      "${name}_server/$jsonfilename".replaceAll("/", Platform.pathSeparator));
  await deleteFolder(".occult");
  await deleteFolder("${name}_models${Platform.pathSeparator}test");
  await deleteFolder("${name}${Platform.pathSeparator}test");
  await deleteFolder("${name}_server${Platform.pathSeparator}test");
}

bool _debugFailures = false;

Future<bool> harassInstallCLI(
    {required String tool,
    required String check,
    required String good,
    required String bad}) async {
  bool gotIt = false;
  final checker = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) => done
        ? gotIt
            ? good
            : bad
        : check,
  ).interact();
  gotIt = _debugFailures ? false : await isGarbageCLIInstalled(tool);
  checker.done();
  return gotIt;
}

Future<bool> isGarbageCLIInstalled(String tool) async {
  try {
    final command = Platform.isWindows ? 'where' : 'which';
    final result = await Process.run(command, [tool]);
    return result.exitCode == 0;
  } catch (e) {
    return false;
  }
}

//    confirmMain(
//         "4.6. ENSURE gcloud is authenticated & signed in with an account that can access $firebaseProjectID! (gcloud auth login)");
//     confirmMain(
//         "4.7. ENSURE firebase is authenticated & signed in with an account that can access $firebaseProjectID! (firebase login)");

Future<void> copyFile(String i, String o, {bool strict = true}) async {
  final loader = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) => done
        ? 'Installed /${o}'.spin(0x7dff7f, 0x03fc6b).chatColor
        : 'Installing /${o}'.spin(0xd303fc, 0xfc03c6).chatColor,
  ).interact();

  File fi = File(i);
  File fo = File(o);

  if (!await fi.exists()) {
    if (strict) {
      throw Exception("File $i does not exist");
    }

    loader.done();
    return;
  }

  if (!await fo.parent.exists()) {
    await fo.parent.create(recursive: true);
  }

  if (await fo.exists()) {
    await fo.delete();
  }

  if (await fi.exists()) {
    await fi.copy(o);
  }

  loader.done();
}

Future<void> deleteFolder(String name) async {
  final loader = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) => done
        ? 'Deleting /${name}'.spin(0x7dff7f, 0x03fc6b).chatColor
        : 'Deleted /${name}'.spin(0xd303fc, 0xfc03c6).chatColor,
  ).interact();

  Directory dir = Directory(name);

  if (await dir.exists()) {
    await dir.delete(recursive: true);
  }

  loader.done();
}

Future<void> patchAppPubspec(String name) async {
  final loader = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) => done
        ? 'Patched /$name/pubspec.yaml'.spin(0x7dff7f, 0x03fc6b).chatColor
        : 'Patching /$name/pubspec.yaml'.spin(0xd303fc, 0xfc03c6).chatColor,
  ).interact();
  String contents = await HttpClient()
      .getUrl(Uri.parse(
          "https://raw.githubusercontent.com/ArcaneArts/arcane/refs/heads/main/example/pubspec.yaml"))
      .then((request) => request.close())
      .then((response) => response.transform(Utf8Decoder()).join());

  var doc = loadYaml(contents);
  YamlEditor app = YamlEditor(
      File("$name${Platform.pathSeparator}pubspec.yaml").readAsStringSync());
  app.update(["flutter"], doc["flutter"]);
  File("$name${Platform.pathSeparator}pubspec.yaml")
      .writeAsStringSync(app.toString().replaceAll("\\/", "/"));

  loader.done();
}

Future<void> runFirebaseLogin() async {
  instruct("Signing into Firebase CLI");
  final process = await Process.start(
    'firebase',
    ['login'],
    mode: ProcessStartMode.inheritStdio,
  );

  int exitCode = await process.exitCode;

  if (exitCode != 0) {
    throw Exception("Failed to run firebase login");
  }
}

Future<void> runGcloudLogin() async {
  instruct("Signing into gcloud CLI");
  final process = await Process.start(
    'gcloud',
    ['auth', "login"],
    mode: ProcessStartMode.inheritStdio,
  );

  int exitCode = await process.exitCode;

  if (exitCode != 0) {
    throw Exception("Failed to run gcloud auth login");
  }
}

Future<void> runBuildRunner(String project) async {
  instruct("Setting Up /$project");
  final process = await Process.start(
    'dart',
    ['run', "build_runner", "build", "--delete-conflicting-outputs"],
    mode: ProcessStartMode.inheritStdio,
    workingDirectory:
        "${Directory.current.absolute.path}${Platform.pathSeparator}$project",
  );

  int exitCode = await process.exitCode;

  if (exitCode != 0) {
    throw Exception("Failed to run build_runner build on $project");
  }
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
    rightPrompt: (done) => done
        ? 'Acquired Arcane Templates'.spin(0x7dff7f, 0x03fc6b).chatColor
        : 'Acquiring Arcane Templates'.spin(0xd303fc, 0xfc03c6).chatColor,
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
            .spin(0x7dff7f, 0x03fc6b)
            .chatColor
        : 'Applying arcane Template for $baseClassName in /$project'
            .spin(0xd303fc, 0xfc03c6)
            .chatColor,
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
            .spin(0x7dff7f, 0x03fc6b)
            .chatColor
        : 'Installing Image Magick FFI in /$project'
            .spin(0xd303fc, 0xfc03c6)
            .chatColor,
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
    rightPrompt: (done) => done
        ? 'Created storage.rules config'.spin(0x7dff7f, 0x03fc6b).chatColor
        : 'Creating storage.rules config'.spin(0xd303fc, 0xfc03c6).chatColor,
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

Future<void> createFirestoreRules() async {
  final creatingLoader = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) => done
        ? 'Created firestore.rules config'.spin(0x7dff7f, 0x03fc6b).chatColor
        : 'Creating firestore.rules config'.spin(0xd303fc, 0xfc03c6).chatColor,
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
            .spin(0x7dff7f, 0x03fc6b)
            .chatColor
        : 'Creating firebase.indexes.json config'
            .spin(0xd303fc, 0xfc03c6)
            .chatColor,
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
    rightPrompt: (done) => done
        ? 'Created firebase.json config'.spin(0x7dff7f, 0x03fc6b).chatColor
        : 'Creating firebase.json config'.spin(0xd303fc, 0xfc03c6).chatColor,
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
    rightPrompt: (done) => done
        ? 'Created .firebaserc config'.spin(0x7dff7f, 0x03fc6b).chatColor
        : 'Creating .firebaserc config'.spin(0xd303fc, 0xfc03c6).chatColor,
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
        ? 'Enabled GCP Artifact Registry'.spin(0x7dff7f, 0x03fc6b).chatColor
        : 'Enabling GCP Artifact Registry'.spin(0xd303fc, 0xfc03c6).chatColor,
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
    rightPrompt: (done) => done
        ? 'Enabled GCP Cloud Run'.spin(0x7dff7f, 0x03fc6b).chatColor
        : 'Enabling GCP Cloud Run'.spin(0xd303fc, 0xfc03c6).chatColor,
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
    rightPrompt: (done) => done
        ? 'Linked /$dep to /$name'.spin(0x7dff7f, 0x03fc6b).chatColor
        : 'Linking /$dep to /$name'.spin(0xd303fc, 0xfc03c6).chatColor,
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
        ? 'Created /$name Flutter project'.spin(0x7dff7f, 0x03fc6b).chatColor
        : 'Creating /$name Flutter project'.spin(0xd303fc, 0xfc03c6).chatColor,
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
        ? 'Created /$name Flutter project'.spin(0x7dff7f, 0x03fc6b).chatColor
        : 'Creating /$name Flutter project'.spin(0xd303fc, 0xfc03c6).chatColor,
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
    rightPrompt: (done) => done
        ? 'Created /$name package'.spin(0x7dff7f, 0x03fc6b).chatColor
        : 'Creating /$name package'.spin(0xd303fc, 0xfc03c6).chatColor,
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
        ? 'Installed Dependencies for /$name'.spin(0x7dff7f, 0x03fc6b).chatColor
        : 'Installing Dependencies /$name'.spin(0xd303fc, 0xfc03c6).chatColor,
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

  setupDependencies.done();
}

Future<void> setupServerDependencies(String name, String rootName) async {
  final setupDependencies = Spinner(
    icon: '✔'.padRight(2).green(),
    leftPrompt: (done) => '',
    rightPrompt: (done) => done
        ? 'Installed Dependencies for /$name'.spin(0x7dff7f, 0x03fc6b).chatColor
        : 'Installing Dependencies /$name'.spin(0xd303fc, 0xfc03c6).chatColor,
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
        ? 'Installed Dependencies for /$name'.spin(0x7dff7f, 0x03fc6b).chatColor
        : 'Installing Dependencies for /$name'
            .spin(0xd303fc, 0xfc03c6)
            .chatColor,
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
        "threshold",
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
