// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_command.dart';

// **************************************************************************
// SubcommandGenerator
// **************************************************************************

class _$CheckCommand<T extends dynamic> extends Command<dynamic> {
  _$CheckCommand() {
    final upcastedType = (this as CheckCommand);
    addSubcommand(ToolsCommand(upcastedType.tools));
    addSubcommand(FlutterCommand(upcastedType.flutter));
    addSubcommand(FirebaseCommand(upcastedType.firebase));
    addSubcommand(DockerCommand(upcastedType.docker));
    addSubcommand(GcloudCommand(upcastedType.gcloud));
    addSubcommand(DoctorCommand(upcastedType.doctor));
    addSubcommand(ServerCommand(upcastedType.server));
  }

  @override
  String get name => 'check';

  @override
  String get description => 'Commands for checking CLI tool availability';
}

class ToolsCommand extends Command<void> {
  ToolsCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'tools';

  @override
  String get description => 'Check all tools (required and optional)';

  @override
  Future<void> run() {
    return userMethod();
  }
}

class FlutterCommand extends Command<void> {
  FlutterCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'flutter';

  @override
  String get description => 'Check Flutter installation';

  @override
  Future<void> run() {
    return userMethod();
  }
}

class FirebaseCommand extends Command<void> {
  FirebaseCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'firebase';

  @override
  String get description => 'Check Firebase CLI tools';

  @override
  Future<void> run() {
    return userMethod();
  }
}

class DockerCommand extends Command<void> {
  DockerCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'docker';

  @override
  String get description => 'Check Docker installation';

  @override
  Future<void> run() {
    return userMethod();
  }
}

class GcloudCommand extends Command<void> {
  GcloudCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'gcloud';

  @override
  String get description => 'Check Google Cloud SDK installation';

  @override
  Future<void> run() {
    return userMethod();
  }
}

class DoctorCommand extends Command<void> {
  DoctorCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'doctor';

  @override
  String get description => 'Run flutter doctor';

  @override
  Future<void> run() {
    return userMethod();
  }
}

class ServerCommand extends Command<void> {
  ServerCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'server';

  @override
  String get description => 'Check server deployment tools';

  @override
  Future<void> run() {
    return userMethod();
  }
}
