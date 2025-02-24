import 'package:occult/util.dart';
import 'package:occult/util/tasks.dart';

class TEnableGoogleAPIs extends OTaskJob {
  final List<String> apis;
  final String project;

  TEnableGoogleAPIs(this.project, this.apis)
      : super("Enable Google APIs $apis on $project");

  @override
  Future<void> run() => add(TRun(
        gcloudPlatformCommand,
        [
          "services",
          "enable",
          ...apis,
          "--project=$project",
        ],
      ));
}
