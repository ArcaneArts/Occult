import 'dart:io';

import 'package:occult/all.dart';
import 'package:occult/util/tasks.dart';

class TApplyTemplate extends OTaskJob {
  final String project;
  final String baseClassName;

  TApplyTemplate(this.project, this.baseClassName)
      : super("Apply Template to ${project} : ${baseClassName}");

  @override
  Future<void> run() async {
    Directory dir = Directory(".occult/Occult-main/template/${project}"
        .replaceAll("/", Platform.pathSeparator));

    if (await dir.exists()) {
      Directory output = Directory(project);

      for (File i in dir.listSync(recursive: true).whereType<File>().toList()) {
        if (i.path.endsWith(".t")) {
          List<String> seg =
              "${output.path}/${i.path.replaceFirst(dir.path, "")}"
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
  }
}
