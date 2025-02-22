import 'dart:io';

import 'package:cli_annotations/cli_annotations.dart';
import 'package:occult/all.dart';
import 'package:occult/routine/create.dart';
import 'package:occult/task/build_dev_server.dart';
import 'package:occult/task/deploy_prod_server.dart';
import 'package:occult/task/deploy_web.dart';
import 'package:occult/task/run_build_runner.dart';
import 'package:occult/task/run_dev_server.dart';
import 'package:occult/task/run_launcher_icons_gen.dart';
import 'package:occult/task/run_splash_gen.dart';
import 'package:occult/util/task_engine.dart';

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
      TaskEngine.add(TRunDevServer(config));
      await TaskEngine.waitFor();
      ran = true;
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
      TaskEngine.add(TDeployProdServer(config));
      await TaskEngine.waitFor();
      ran = true;
    }

    if (webRelease) {
      TaskEngine.add(TDeployWeb(config, beta: true));
      await TaskEngine.waitFor();
      ran = true;
    }

    if (web) {
      TaskEngine.add(TDeployWeb(config, beta: true));
      await TaskEngine.waitFor();
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
      TaskEngine.add(TRunBuildRunner("${config.name}_models"));
      await TaskEngine.waitFor();
    }

    if (server) {
      TaskEngine.add(TBuildDevServer(config));
      await TaskEngine.waitFor();
      ran = true;
    }

    if (serverRelease) {
      TaskEngine.add(TBuildDevServer(config));
      await TaskEngine.waitFor();
      ran = true;
    }

    if (splashScreen) {
      TaskEngine.add(TRunSplashGen(config));
      await TaskEngine.waitFor();
      ran = true;
    }

    if (launcherIcons) {
      TaskEngine.add(TRunLaunchIconsGen(config));
      await TaskEngine.waitFor();
      ran = true;
    }

    if (!ran) {
      instruct(
          "No targets were specified to build. Try occult build -h for help.");
    }
  }

  @CliCommand(description: "Creates a new project in the current directory")
  Future<void> create() async {
    await RoutineSetup().run();
    exit(0);
  }
}
