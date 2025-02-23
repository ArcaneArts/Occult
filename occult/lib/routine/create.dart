import 'package:interact/interact.dart';
import 'package:occult/all.dart';
import 'package:occult/task/apply_templates.dart';
import 'package:occult/task/create_projects.dart';
import 'package:occult/task/deploy_firestore.dart';
import 'package:occult/task/deploy_storage.dart';
import 'package:occult/task/deploy_web.dart';
import 'package:occult/task/enable_googleapis.dart';
import 'package:occult/task/firebase_login.dart';
import 'package:occult/task/flutterfire_init.dart';
import 'package:occult/task/gcloud_login.dart';
import 'package:occult/task/gen_firebase_configs.dart';
import 'package:occult/task/run_launcher_icons_gen.dart';
import 'package:occult/task/run_splash_gen.dart';
import 'package:occult/task/set_android_min_sdk_ver.dart';
import 'package:occult/task/set_ios_platform_version.dart';
import 'package:occult/task/set_macos_platform_version.dart';
import 'package:occult/util/task_engine.dart';
import 'package:occult/util/tasks.dart';
import 'package:path/path.dart' as p;
import 'package:universal_io/io.dart';

String getCliCommand(String command) {
  if (Platform.isWindows) {
    if (command == "flutter") return "flutter.bat";
    if (command == "firebase") return "firebase.cmd";
    if (command == "gcloud") return "gcloud.cmd";
  }
  return command;
}

class RoutineSetup extends Routine {
  @override
  Future<void> onRun() async {
    await s(TCheckCLITools([
      getCliCommand("flutter"),
      "dart",
      getCliCommand("firebase"),
      "npm",
      "flutterfire",
      getCliCommand("gcloud"),
      "docker",
      if (Platform.isMacOS) ...["brew", "pod"]
    ]));

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
        "4.4. Under the KEYS tab click  ADD KEY > Create new key > JSON");

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
                  p.basename(i.path).startsWith("${firebaseProjectID}-"))
              .toList())
          .whereType<File>()
          .firstOrNull
          ?.path;
    }

    instruct("Service Account Key Found!");
    instruct("  $sak");

    instruct(
        "Create an Artifact Registry Repository at https://console.cloud.google.com/artifacts/create-repo?project=${firebaseProjectID}&hl=en");
    instruct("Name: cloud-run-source-deploy");
    instruct("Format: Docker");
    instruct("Mode: Standard");
    instruct("Location: Region");
    instruct("Region: us-central1 (Iowa)");
    instruct("Encryption: Google-managed key");
    instruct("Immutable image tags: Disabled");
    instruct("Cleanup Policies: Delete artifacts");
    confirmMain(
        "4.6. Fill out the new repository screen, then click ADD A CLEANUP POLICY");
    instruct("Name: Autoclean");
    instruct("Policy Type: Keep most recent versions");
    instruct("Keep Count: 2");
    confirmMain(
        "4.7. Press done on the cleanup policy, then ADD ANOTHER CLEANUP POLICY");
    instruct("Name: Autodelete");
    instruct("Policy Type: Conditional Delete");
    instruct("Tag State: Any Tag State");
    confirmMain(
        "4.8. Press done on the cleanup policy, then CREATE REPOSITORY");

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
    String jsonfilename = sak.split(Platform.pathSeparator).last;
    String project = firebaseProjectID;
    String name = appProjectName;
    String app = appProjectName;
    String org = appDomainOrg;
    await s(TMakeJson("config/occult.json", {
      "name": name,
      "organization": org,
      "id": project,
      "className": baseClassName,
    }));
    OccultConfiguration config = (await findOccultConfiguration())!;
    await s(TGCloudLogin());
    await s(TFBLogin());
    s(TEnableGoogleAPIs(
        project, ["artifactregistry.googleapis.com", "run.googleapis.com"]));
    s(TGenFirebaseConfigs(project: project, app: app));
    s(TCreateProjects(app, org));
    await s(TFlutterFireInit(app, project));
    s(TApplyTemplates(
        project: name,
        baseClassName: baseClassName,
        jsonfilename: jsonfilename,
        firebaseprojectid: project));
    s(TaskCopyFile(
        "config/keys/$jsonfilename", "${name}_server/$jsonfilename"));
    s(TSetAndroidMinSDKVersion(config, "23"));
    if (Platform.isMacOS) {
      s(TSetIMacOSPlatformVersion(config, "10.15"));
      s(TSetIOSPlatformVersion(config, "13.0"));
    }
    await TaskEngine.waitFor();
    s(TaskDeleteFolder(".occult"));
    s(TaskDeleteFolder("${name}_models${Platform.pathSeparator}test"));
    s(TaskDeleteFolder("${name}${Platform.pathSeparator}test"));
    s(TaskDeleteFolder("${name}_server${Platform.pathSeparator}test"));
    s(TDeployFirestore(config));
    s(TDeployStorage(config));
    await s(TRunSplashGen(config));
    await s(TRunLaunchIconsGen(config));
    await s(TDeployWeb(config));
    bool built = false;
    while (!built) {
      instruct(
          "8. Head to https://console.firebase.google.com/project/${firebaseProjectID}/hosting/sites/occult-test");
      instruct(
          "8.1. Scroll to the bottom & click Add Another Site (bottom right)");
      instruct("ID: ${firebaseProjectID}-beta");
      confirmMain("CONFIRM you have added the beta site");
      try {
        await s(TDeployWeb(config, beta: true));
      } catch (e) {
        print("ACTUALLY COMPLETE STEP 8, then TRY AGAIN!");
        continue;
      }
      built = true;
    }
  }
}
