import 'package:occult/util/tasks.dart';
import 'package:tint/tint.dart';

class TaskEngine {
  static int _id = 0;

  static int get nextId => _id++;
  static List<OTask> runningTasks = [];

  static Future<void> waitFor() async {
    int x = _id;
    while (runningTasks.isNotEmpty) {
      await Future.delayed(Duration(milliseconds: 10));
    }

    if (x != _id) {
      await waitFor();
    }
  }

  static Future<void> add(OTask task) async {
    if (task is OTaskExclusiveJob ||
        runningTasks.any((i) => i is OTaskExclusiveJob)) {
      await waitFor();
    }

    runningTasks.add(task);
    print(
        "${"▶ ".brightMagenta()} ${"[".brightBlue()}${(runningTasks.length).toString().brightMagenta()}${" / ".grey()}${_id.toString().brightGreen()}${"]".brightBlue()} ${task.taskName.gray()}");
    await task.run();
    runningTasks.remove(task);
    print(
        "${"✓ ".brightGreen()} ${"[".brightBlue()}${(runningTasks.length).toString().brightMagenta()}${" / ".grey()}${_id.toString().brightGreen()}${"]".brightBlue()} ${task.taskName.gray()}");
  }
}
