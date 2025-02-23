import 'package:occult/util/tasks.dart';
import 'package:universal_io/io.dart';

// Determine the correct command based on the platform.
final String gcloudCommand = Platform.isWindows ? 'gcloud.cmd' : 'gcloud';

class TGCloudLogin extends TRunInteractive {
  TGCloudLogin() : super(gcloudCommand, const ["auth", "login"]);
}
