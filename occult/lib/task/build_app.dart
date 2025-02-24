import 'package:occult/all.dart';
import 'package:occult/task/set_android_min_sdk_ver.dart';
import 'package:occult/task/set_ios_platform_version.dart';
import 'package:occult/task/set_macos_platform_version.dart';
import 'package:occult/util.dart';
import 'package:occult/util/tasks.dart';
import 'package:universal_io/io.dart';

class TBuildApp extends OTaskExclusiveJob {
  final OccultConfiguration config;
  final String target;

  TBuildApp(this.config, this.target) : super("Build App $target");

  @override
  Future<void> run() async {
    (int, String, String) out = await interactiveSpy(
        flutterPlatformCommand,
        ["build", target, if (target == "web") "--wasm", "--release"],
        "${config.path}${Platform.pathSeparator}${config.name}");

    if (out.$1 != 0) {
      bool reRun = false;
      String so = out.$2;
      String se = out.$3;

      if (so.contains("requires a higher Android SDK version.") &&
          so.contains("defaultConfig {")) {
        List<String> sl = so
            .split("\n")
            .where((i) => i.trim().startsWith("│     minSdkVersion 23 "))
            .map((i) => i.trim().substring(1).trim())
            .toList();

        if (sl.isNotEmpty) {
          String minSdkVersion = sl.first.split(" ")[1].trim();
          instruct(
              "Detected Required Android MinSDK is $minSdkVersion... Updating automatically!");
          await TSetAndroidMinSDKVersion(config, minSdkVersion).run();
          reRun = true;
        }
      } else if (se.contains(
              "requires a higher minimum iOS deployment version than your application is targeting.") &&
          se.contains(
              "To build, increase your application's deployment target to at least ")) {
        List<String> sl = se
            .split("\n")
            .where((i) => i.trim().startsWith(
                "To build, increase your application's deployment target to at least "))
            .toList();

        if (sl.isNotEmpty) {
          String ver = sl.first
              .split(" application's deployment target to at least ")[1]
              .trim()
              .split(" ")
              .first
              .trim();
          instruct(
              "Detected Required iOS Deployment Target is $ver... Updating automatically!");
          await TSetIOSPlatformVersion(config, ver).run();
          reRun = true;
        }
      } else if (se.contains(
              "requires a higher minimum macOS deployment version than your application is targeting.") &&
          se.contains(
              "To build, increase your application's deployment target to at least ")) {
        List<String> sl = se
            .split("\n")
            .where((i) => i.trim().startsWith(
                "To build, increase your application's deployment target to at least "))
            .toList();

        if (sl.isNotEmpty) {
          String ver = sl.first
              .split(" application's deployment target to at least ")[1]
              .trim()
              .split(" ")
              .first
              .trim();
          instruct(
              "Detected Required macOS Deployment Target is $ver... Updating automatically!");
          await TSetIMacOSPlatformVersion(config, ver).run();
          reRun = true;
        }
      } else if (se.contains(
          "It appears that there was a problem signing your application prior to installation on the device.")) {
        instruct(
            "---------------------------------------------------------------------------------------------");
        instruct("1. Open XCode and select the Runner project.");
        instruct("2. Go to the Signing & Capabilities tab.");
        instruct(
            "3. Select the Team dropdown and select your development team.");
        instruct("4. Close XCode and re-run the build.");
        instruct(
            "---------------------------------------------------------------------------------------------");
      }

      if (reRun) {
        instruct("Re-running build...");
        await run();
      }
    }
  }
}
