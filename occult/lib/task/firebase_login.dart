import 'package:occult/util/tasks.dart';
import 'package:universal_io/io.dart';

class TFBLogin extends TRunInteractive {
  TFBLogin()
      : super(
          Platform.isWindows ? "firebase.cmd" : "firebase",
          const ["login"],
        );
}
