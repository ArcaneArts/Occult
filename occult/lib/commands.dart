import 'dart:io';

import 'package:cli_annotations/cli_annotations.dart';
import 'package:interact/interact.dart';
import 'package:occult/all.dart';

part 'commands.g.dart';

@cliRunner
class OccultRunner extends _$OccultRunner {
  @CliCommand(
      name: 'run',
      description:
          "Runs a target such as the server. You need to specify at least one target")
  Future<void> runn(
      {
      /// Runs the server locally at localhost:8080 and will terminate if occult is terminated (ctrl+c)
      bool server = false}) async {
    OccultConfiguration? config = await findOccultConfiguration();

    if (config == null) {
      instruct(
          "No Occult Configuration Found in this directory or its parent or its grandparent!");
      exit(0);
    }
    bool ran = false;
    if (server) {
      success("Running Development Server in ${config.name}_server");
      await runDevServer(config);
      success("Ran Development Server in ${config.name}_server");
    }

    if (!ran) {
      instruct(
          "No targets were specified to build. Try occult build -h for help.");
    }
  }

  @CliCommand(
      description:
          "Deploys a target such as the server or web app. You need to specify at least one target")
  Future<void> deploy({
    /// Deploys the docker image for the server to google cloud & releases it
    bool serverRelease = false,

    /// Deploys the beta web app to firebase hosting
    bool web = false,

    /// Deploys the release web app to firebase hosting
    bool webRelease = false,
  }) async {
    OccultConfiguration? config = await findOccultConfiguration();
    if (config == null) {
      instruct(
          "No Occult Configuration Found in this directory or its parent or its grandparent!");
      exit(0);
    }
    bool ran = false;
    if (serverRelease) {
      success(
          "Deploying Release Server in ${config.name}_server with Dockerfile-dev");
      await deployProdServer(config);
      success("Deployed Release Server in ${config.name}_server");
      ran = true;
    }

    if (webRelease) {
      success("Deploying Release Web App in ${config.name}");
      await firebaseDeployWeb(config.firebaseProjectId);
      success("Deployed Release Web App in ${config.name}");
      ran = true;
    }

    if (web) {
      success("Deploying Beta Web App in ${config.name}");
      await firebaseDeployWeb("${config.firebaseProjectId}-beta");
      success("Deployed Beta Web App in ${config.name}");
      ran = true;
    }

    if (!ran) {
      instruct(
          "No targets were specified to deploy. Try occult build -h for help.");
    }
  }

  @CliCommand(
      description: "Builds a target. You need to specify at least one target")
  Future<void> build(
      {
      /// Builds the dev server into a local docker image
      bool server = false,

      /// Builds the release server into a local docker image & uploads it to GCP artifact registry without releasing it
      bool serverRelease = false,

      /// Builds the web app in release mode
      bool web = false,

      /// Builds an android APK for the app in release mode
      bool apk = false,

      /// Builds the ios app in release mode
      bool ios = false,

      /// Builds the macos app in release mode
      bool macos = false,

      /// Builds the windows app in release mode
      bool windows = false,

      /// Builds the linux app in release mode
      bool linux = false,

      /// Builds the app bundle for android in release mode
      bool appbundle = false,

      /// Builds the launcher icons generator for the app
      bool launcherIcons = false,

      /// Builds the oss licenses generator for the app
      bool oss = false,

      /// Builds the models for the app & server in the models project
      bool models = false,

      /// Builds the splash screen generator for the app
      bool splashScreen = false}) async {
    OccultConfiguration? config = await findOccultConfiguration();
    if (config == null) {
      instruct(
          "No Occult Configuration Found in this directory or its parent or its grandparent!");
      exit(0);
    }
    bool ran = false;
    if (models) {
      success("Building Models in ${config.name}_models");
      await buildModels(config);
      success("Built Models in ${config.name}_models");
      ran = true;
    }

    if (server) {
      success(
          "Building Development Server in ${config.name}_server with Dockerfile-dev");
      await buildDevServer(config);
      success("Built Development Server in ${config.name}_server");
      ran = true;
    }

    if (serverRelease) {
      success(
          "Building Release Server in ${config.name}_server to GCP Artifact Registry");
      await buildProdServer(config);
      success(
          "Building Release Server in ${config.name}_server to GCP Artifact Registry");
      ran = true;
    }

    if (splashScreen) {
      success("Building Splash Screen in ${config.name}");
      await runSplashGen(config);
      success("Built Splash Screen in ${config.name}");
      ran = true;
    }

    if (launcherIcons) {
      success("Building Splash Screen in ${config.name}");
      await runLauncherIconsGen(config);
      success("Built Splash Screen in ${config.name}");
      ran = true;
    }

    if (!ran) {
      instruct(
          "No targets were specified to build. Try occult build -h for help.");
    }
  }

  @CliCommand(description: "Creates a new project in the current directory")
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
    await setupAll(
        jsonfilename: sak.split(Platform.pathSeparator).last,
        name: appProjectName,
        org: appDomainOrg,
        firebaseProjectId: firebaseProjectID,
        baseClassName: baseClassName);
  }
}
