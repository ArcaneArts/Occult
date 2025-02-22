import 'package:occult/task/apply_template.dart';
import 'package:occult/task/download_templates.dart';
import 'package:occult/task/run_build_runner.dart';
import 'package:occult/util/tasks.dart';

class TApplyTemplates extends OTaskJob {
  final String project;
  final String baseClassName;
  final String jsonfilename;
  final String firebaseprojectid;

  TApplyTemplates(
      {required this.project,
      required this.baseClassName,
      required this.jsonfilename,
      required this.firebaseprojectid})
      : super(
            "Apply Templates to ${project} : ${baseClassName}, ${jsonfilename}, ${firebaseprojectid}");

  @override
  Future<void> run() => add(TDownloadTemplates(
          project: project,
          baseClassName: baseClassName,
          jsonfilename: jsonfilename,
          firebaseprojectid: firebaseprojectid))
      .then((_) => Future.wait([
            add(TApplyTemplate("${project}_models", baseClassName))
                .then((_) => add(TRunBuildRunner("${project}_models"))),
            add(TApplyTemplate(project, baseClassName)),
            add(TApplyTemplate("${project}_server", baseClassName)),
          ]));
}
