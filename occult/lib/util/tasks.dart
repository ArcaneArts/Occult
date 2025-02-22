import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:occult/util/task_engine.dart';
import 'package:path/path.dart' as p;

abstract class OTask {
  final int id = TaskEngine.nextId;
  final String taskName;
  int? parentId;

  OTask(this.taskName);

  Future<void> run();

  Future<void> add(OTask task) => TaskEngine.add(task..parentId = id);
}

abstract class OTaskJob extends OTask {
  OTaskJob(super.taskName);
}

abstract class OTaskExclusiveJob extends OTask {
  OTaskExclusiveJob(super.taskName);
}

class TCheckCLITools extends OTask {
  final List<String> tools;

  TCheckCLITools(this.tools) : super("Check CLI Tools $tools");

  @override
  Future<void> run() => Future.wait(tools.map((tool) => add(TCheckCLI(tool))));
}

class TCheckCLI extends OTask {
  final String tool;

  TCheckCLI(this.tool) : super("Check CLI $tool");

  @override
  Future<void> run() async =>
      add(TRun(Platform.isWindows ? 'where' : 'which', [tool]));
}

class TRunInteractive extends OTaskExclusiveJob {
  final String command;
  final List<String> args;
  final String? workingDirectory;

  TRunInteractive(this.command, this.args, {this.workingDirectory})
      : super(
            "Run Interactive $command $args${workingDirectory == null ? "" : " in $workingDirectory"}");

  @override
  Future<void> run() async {
    final process = await Process.start(
      command,
      args,
      mode: ProcessStartMode.inheritStdio,
      workingDirectory: workingDirectory,
    );

    int exitCode = await process.exitCode;

    if (exitCode != 0) {
      throw Exception(
          "Failed to process interactively $command ${args.join(" ")} in ${workingDirectory ?? Directory.current.path}");
    }
  }
}

class TRun extends OTaskJob {
  final String command;
  final List<String> args;
  final String? workingDirectory;

  TRun(this.command, this.args, {this.workingDirectory})
      : super(
            "Run $command $args${workingDirectory == null ? "" : " in $workingDirectory"}");

  @override
  Future<void> run() async {
    ProcessResult p =
        await Process.run(command, args, workingDirectory: workingDirectory);
    if (p.exitCode != 0) {
      print("FAILED TO RUN PROCESS! ${p.exitCode}");
      print(
          "Tried to run $command $args in ${workingDirectory ?? Directory.current.path}");
      print(p.stdout);
      print("---");
      print(p.stderr);
      print("---");
      throw Exception("Failed to run process check console above.");
    }
  }
}

class TaskCopyDirectory extends OTaskJob {
  final String fromPath;
  final String toPath;

  TaskCopyDirectory(this.fromPath, this.toPath)
      : super("Copy dir $fromPath to $toPath");

  @override
  Future<void> run() async {
    Directory dir = Directory(fromPath);
    bool dirExists = await dir.exists();

    if (dirExists) {
      List<Future<void>> work = <Future<void>>[];

      await for (FileSystemEntity entity in dir.list(recursive: true)) {
        if (entity is File) {
          File file = entity;
          String relativePath = p.relative(file.path, from: fromPath);
          String newPath = p.join(toPath, relativePath);

          work.add(add(
            TaskCopyFile(file.path, newPath),
          ));
        }
      }

      await Future.wait(work);
    }
  }
}

class TMakeJson extends OTaskJob {
  final String path;
  final Map<String, dynamic> content;

  TMakeJson(this.path, this.content) : super("Make json file $path");

  Future<void> run() async {
    File file = File(path.replaceAll("/", Platform.pathSeparator));
    await file.parent.create(recursive: true);
    await file.writeAsString(JsonEncoder.withIndent("  ").convert(content));
  }
}

class TMakeFile extends OTaskJob {
  final String path;
  final String content;

  TMakeFile(this.path, this.content) : super("Make file $path");

  Future<void> run() async {
    File file = File(path.replaceAll("/", Platform.pathSeparator));
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }
}

class TMkdir extends OTaskJob {
  final String path;

  TMkdir(this.path) : super("Make dir $path");

  Future<void> run() async {
    Directory dir = Directory(path.replaceAll("/", Platform.pathSeparator));
    await dir.create(recursive: true);
  }
}

class TaskCopyFile extends OTaskJob {
  final String fromPath;
  final String toPath;

  TaskCopyFile(this.fromPath, this.toPath)
      : super("Copy file $fromPath to $toPath");

  Future<void> run() async {
    File file = File(fromPath.replaceAll("/", Platform.pathSeparator));
    await File(toPath.replaceAll("/", Platform.pathSeparator))
        .parent
        .create(recursive: true);
    await file.copy(toPath.replaceAll("/", Platform.pathSeparator));
  }
}

class TaskMoveFile extends OTaskJob {
  final String fromPath;
  final String toPath;

  TaskMoveFile(this.fromPath, this.toPath)
      : super("Move file $fromPath to $toPath");

  Future<void> run() async {
    File file = File(fromPath);

    if (await file.exists() && fromPath != toPath) {
      await file.rename(toPath);
    }
  }
}

class TaskDeleteFolder extends OTaskJob {
  final String path;

  TaskDeleteFolder(this.path) : super("Delete dir $path");

  Future<void> run() async {
    Directory dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}

class TaskDeleteFile extends OTaskJob {
  final String path;

  TaskDeleteFile(this.path) : super("Delete file $path");

  Future<void> run() async {
    File file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

class TaskDownload extends OTaskJob {
  final String url;
  final String path;

  TaskDownload(this.url, this.path) : super("Download $url to $path");

  Future<void> run() async {
    File file = File(path);
    await file.parent.create(recursive: true);
    await HttpClient()
        .getUrl(Uri.parse(url))
        .then((request) => request.close())
        .then((response) => response.pipe(file.openWrite()));
  }
}

abstract class Routine {
  Future<void> onRun();

  Future<void> run() async {
    await onRun();
    await TaskEngine.waitFor();
  }

  Future<void> s(OTask task) => TaskEngine.add(task);
}
