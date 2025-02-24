import 'package:occult/all.dart';
import 'package:occult/util/tasks.dart';
import 'package:universal_io/io.dart';

class TSetIMacOSPlatformVersion extends OTaskJob {
  final OccultConfiguration config;
  final String value;

  TSetIMacOSPlatformVersion(this.config, this.value)
      : super("Update macOS Platform Version to $value in ${config.name}");

  @override
  Future<void> run() async {
    File file = File(
        "${config.path}/${config.name}/macos/Runner.xcodeproj/project.pbxproj");

    if (!await file.exists()) {
      throw Exception(
          "File not found: ${file.path} to patch macos target version");
    }

    String content = await file.readAsString();
    List<String> lines = content.split("\n");
    List<String> output = [];

    for (String i in lines) {
      if (i.trim().startsWith("MACOSX_DEPLOYMENT_TARGET = ")) {
        List<String> c = i.split(" = ");
        output.add("${c[0]} = $value;");
      } else {
        output.add(i);
      }
    }

    await file.writeAsString(output.join("\n"));

    file = File("${config.path}/${config.name}/macos/Podfile");

    if (!await file.exists()) {
      throw Exception(
          "File not found: ${file.path} to patch macos target version");
    }

    content = await file.readAsString();
    lines = content.split("\n");
    output = [];

    for (String i in lines) {
      if (i.trim().startsWith("platform :osx, ")) {
        List<String> c = i.split(" :osx, ");
        output.add("${c[0]} :osx, '$value'");
      } else {
        output.add(i);
      }
    }

    await file.writeAsString(output.join("\n"));
  }
}
