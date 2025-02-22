import 'package:occult/util/tasks.dart';

class TGCloudLogin extends TRunInteractive {
  TGCloudLogin() : super("gcloud", const ["auth", "login"]);
}
