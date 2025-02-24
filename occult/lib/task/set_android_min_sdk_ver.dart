import 'package:occult/all.dart';
import 'package:occult/util/tasks.dart';
import 'package:universal_io/io.dart';

class TSetAndroidMinSDKVersion extends OTaskJob {
  final OccultConfiguration config;
  final String value;

  TSetAndroidMinSDKVersion(this.config, this.value)
      : super("Update Android MinSDK Version to $value in ${config.name}");

  @override
  Future<void> run() async {
    File file =
        File("${config.path}/${config.name}/android/app/build.gradle.kts");

    if (!await file.exists()) {
      throw Exception("File not found: ${file.path} to patch sdk");
    }

    String content = await file.readAsString();
    List<String> lines = content.split("\n");
    List<String> output = [];

    for (String i in lines) {
      if (i.trim().startsWith("minSdk = ")) {
        List<String> c = i.split(" = ");
        output.add("${c[0]} = $value");
      } else {
        output.add(i);
      }
    }

    await file.writeAsString(output.join("\n"));
  }
}
