import 'package:occult/util/tasks.dart';
import 'package:universal_io/io.dart';

class TAddPathDep extends OTaskJob {
  final String app;
  final String dep;

  TAddPathDep(this.app, this.dep) : super("Add ${dep} to ${app} dependencies");

  @override
  Future<void> run() => add(TRun(Platform.isWindows ? "flutter.bat" : "flutter",
      ["pub", "add", dep, "--path", "../$dep"],
      workingDirectory:
          "${Directory.current.absolute.path}${Platform.pathSeparator}$app"));
}
