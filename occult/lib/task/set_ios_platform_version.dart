import 'dart:io';

import 'package:occult/all.dart';
import 'package:occult/util/tasks.dart';

class TSetIOSPlatformVersion extends OTaskJob {
  final OccultConfiguration config;
  final String value;

  TSetIOSPlatformVersion(this.config, this.value)
      : super("Update IOS Platform Version to $value in ${config.name}");

  @override
  Future<void> run() async {
    File file = File(
        "${config.path}/${config.name}/ios/Runner.xcodeproj/project.pbxproj");

    if (!await file.exists()) {
      throw Exception(
          "File not found: ${file.path} to patch ios target version");
    }

    String content = await file.readAsString();
    List<String> lines = content.split("\n");
    List<String> output = [];

    for (String i in lines) {
      if (i.trim().startsWith("IPHONEOS_DEPLOYMENT_TARGET = ")) {
        List<String> c = i.split(" = ");
        output.add("${c[0]} = $value;");
      } else {
        output.add(i);
      }
    }

    await file.writeAsString(output.join("\n"));
  }
}
