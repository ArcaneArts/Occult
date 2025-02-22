import 'package:occult/util/tasks.dart';

class TEnableGoogleAPIs extends OTaskJob {
  final List<String> apis;
  final String project;

  TEnableGoogleAPIs(this.project, this.apis)
      : super("Enable Google APIs $apis on $project");

  @override
  Future<void> run() => add(TRun("gcloud", [
        "services",
        "enable",
        "artifactregistry.googleapis.com",
        "run.googleapis.com",
        "--project=$project"
      ]));
}
