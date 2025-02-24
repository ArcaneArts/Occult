import 'package:occult/util.dart';
import 'package:occult/util/tasks.dart';

class TGCloudLogin extends TRunInteractive {
  TGCloudLogin() : super(gcloudPlatformCommand, const ["auth", "login"]);
}
