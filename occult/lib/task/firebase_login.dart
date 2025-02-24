import 'package:occult/util.dart';
import 'package:occult/util/tasks.dart';

class TFBLogin extends TRunInteractive {
  TFBLogin()
      : super(
          firebasePlatformCommand,
          const ["login"],
        );
}
