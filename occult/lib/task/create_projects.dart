import 'package:occult/task/add_path_dep.dart';
import 'package:occult/task/create_app.dart';
import 'package:occult/task/create_models.dart';
import 'package:occult/task/create_server.dart';
import 'package:occult/task/patch_pubspec.dart';
import 'package:occult/util/tasks.dart';

class TCreateProjects extends OTaskJob {
  final String app;
  final String org;

  TCreateProjects(this.app, this.org) : super("Create Projects");

  @override
  Future<void> run() => Future.wait([
        add(TCreateModelsProject(app)),
        add(TCreateAppProject(app, org)),
        add(TCreateServerProject(app, org))
      ])
          .then((_) => Future.wait([
                add(TAddPathDep(app, "${app}_models")),
                add(TAddPathDep("${app}_server", "${app}_models")),
              ]))
          .then((_) => add(TPatchAppPubspec(app)));
}
