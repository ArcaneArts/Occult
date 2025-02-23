import 'package:occult/util/tasks.dart';
import 'package:universal_io/io.dart';

class TEnableGoogleAPIs extends OTaskJob {
  final List<String> apis;
  final String project;

  TEnableGoogleAPIs(this.project, this.apis)
      : super("Enable Google APIs $apis on $project");

  @override
  Future<void> run() => add(TRun(
        Platform.isWindows ? "gcloud.cmd" : "gcloud",
        [
          "services",
          "enable",
          ...apis,
          "--project=$project",
        ],
      ));
}
