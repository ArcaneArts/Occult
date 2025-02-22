import 'dart:io';

import 'package:occult/all.dart';
import 'package:occult/task/build_prod_server.dart';
import 'package:occult/util.dart';
import 'package:occult/util/tasks.dart';

class TDeployProdServer extends OTaskExclusiveJob {
  final OccultConfiguration config;

  TDeployProdServer(this.config) : super("Deploy Prod Server to Cloud Run");

  @override
  Future<void> run() async {
    await TBuildProdServer(config).run();
    await interactive(
        "gcloud",
        [
          "beta",
          "run",
          "deploy",
          "${config.name}-server",
          "--project=${config.firebaseProjectId}",
          "--image=us-central1-docker.pkg.dev/${config.firebaseProjectId}/cloud-run-source-deploy/${config.name}-server:latest",
          "--min-instances=0",
          "--memory",
          "2Gi",
          "--cpu",
          "2",
          "--concurrency",
          "4",
          "--cpu-boost"
        ],
        "${config.path}${Platform.pathSeparator}${config.name}_server");
  }
}
