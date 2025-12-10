// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deploy_command.dart';

// **************************************************************************
// SubcommandGenerator
// **************************************************************************

class _$DeployCommand<T extends dynamic> extends Command<dynamic> {
  _$DeployCommand() {
    final upcastedType = (this as DeployCommand);
    addSubcommand(FirestoreCommand(upcastedType.firestore));
    addSubcommand(StorageCommand(upcastedType.storage));
    addSubcommand(HostingCommand(upcastedType.hosting));
    addSubcommand(HostingBetaCommand(upcastedType.hostingBeta));
    addSubcommand(AllCommand(upcastedType.all));
    addSubcommand(FirebaseSetupCommand(upcastedType.firebaseSetup));
    addSubcommand(GenerateConfigsCommand(upcastedType.generateConfigs));
    addSubcommand(ServerSetupCommand(upcastedType.serverSetup));
    addSubcommand(ServerBuildCommand(upcastedType.serverBuild));
  }

  @override
  String get name => 'deploy';

  @override
  String get description => 'Firebase and server deployment commands';
}

class FirestoreCommand extends Command<void> {
  FirestoreCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'firestore';

  @override
  String get description => 'Deploy Firestore rules and indexes';

  @override
  Future<void> run() {
    return userMethod();
  }
}

class StorageCommand extends Command<void> {
  StorageCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'storage';

  @override
  String get description => 'Deploy Storage rules';

  @override
  Future<void> run() {
    return userMethod();
  }
}

class HostingCommand extends Command<void> {
  HostingCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'hosting';

  @override
  String get description => 'Deploy to Firebase Hosting (release)';

  @override
  Future<void> run() {
    return userMethod();
  }
}

class HostingBetaCommand extends Command<void> {
  HostingBetaCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'hosting-beta';

  @override
  String get description => 'Deploy to Firebase Hosting (beta)';

  @override
  Future<void> run() {
    return userMethod();
  }
}

class AllCommand extends Command<void> {
  AllCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'all';

  @override
  String get description => 'Deploy all Firebase resources';

  @override
  Future<void> run() {
    return userMethod();
  }
}

class FirebaseSetupCommand extends Command<void> {
  FirebaseSetupCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'firebase-setup';

  @override
  String get description => 'Setup Firebase for a new project';

  @override
  Future<void> run() {
    return userMethod();
  }
}

class GenerateConfigsCommand extends Command<void> {
  GenerateConfigsCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'generate-configs';

  @override
  String get description => 'Generate Firebase configuration files';

  @override
  Future<void> run() {
    return userMethod();
  }
}

class ServerSetupCommand extends Command<void> {
  ServerSetupCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'server-setup';

  @override
  String get description => 'Setup server for deployment';

  @override
  Future<void> run() {
    return userMethod();
  }
}

class ServerBuildCommand extends Command<void> {
  ServerBuildCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'server-build';

  @override
  String get description => 'Build server Docker image';

  @override
  Future<void> run() {
    return userMethod();
  }
}
