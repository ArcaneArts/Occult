import 'package:occult/util/tasks.dart';

class TGenFirebaseRC extends OTaskJob {
  final String project;

  TGenFirebaseRC(this.project) : super("Generate .firebaserc for $project");

  @override
  Future<void> run() => add(TMakeJson(".firebaserc", {
        "projects": {"default": project}
      }));
}
