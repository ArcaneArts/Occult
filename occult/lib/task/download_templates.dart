import 'dart:io';

import 'package:archive/archive.dart';
import 'package:occult/all.dart';
import 'package:occult/util/tasks.dart';

class TDownloadTemplates extends OTaskJob {
  final String project;
  final String baseClassName;
  final String jsonfilename;
  final String firebaseprojectid;

  TDownloadTemplates(
      {required this.project,
      required this.baseClassName,
      required this.jsonfilename,
      required this.firebaseprojectid})
      : super(
            "Download Templates for $project project with base class $baseClassName and json file $jsonfilename and firebase project id $firebaseprojectid");

  @override
  Future<void> run() async {
    File occult = File("occult.zip");
    await add(TaskDownload(
        "https://github.com/ArcaneArts/Occult/archive/refs/heads/main.zip",
        "occult.zip"));
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
        seg[seg.length - 1] =
            seg[seg.length - 1].replaceAll("appname", project);
        await i.rename(seg.join(Platform.pathSeparator));
        instruct("MV ${i.path} to ${seg.join(Platform.pathSeparator)}");
      }
    }

    for (File i in dir.listSync(recursive: true).whereType<File>().toList()) {
      if (i.path.endsWith(".t") &&
          i.path.split(Platform.pathSeparator).last.contains("appname")) {
        List<String> seg = i.path.split(Platform.pathSeparator);
        seg[seg.length - 1] =
            seg[seg.length - 1].replaceAll("appname", project);
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
  }
}
