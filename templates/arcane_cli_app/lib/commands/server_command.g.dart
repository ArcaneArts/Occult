// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_command.dart';

// **************************************************************************
// SubcommandGenerator
// **************************************************************************

class _$ServerCommand<T extends dynamic> extends Command<dynamic> {
  _$ServerCommand() {
    final upcastedType = (this as ServerCommand);
    addSubcommand(PingCommand(upcastedType.ping));
    addSubcommand(SinfoCommand(upcastedType.sinfo));
    addSubcommand(ConfigureCommand(upcastedType.configure));
    addSubcommand(TestCommand(upcastedType.test));
  }

  @override
  String get name => 'server';

  @override
  String get description => 'Server API interaction commands';
}

class PingCommand extends Command<void> {
  PingCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'ping';

  @override
  String get description => 'Ping the server to check if it\'s running';

  @override
  Future<void> run() {
    return userMethod();
  }
}

class SinfoCommand extends Command<void> {
  SinfoCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'sinfo';

  @override
  String get description => 'Get server information';

  @override
  Future<void> run() {
    return userMethod();
  }
}

class ConfigureCommand extends Command<void> {
  ConfigureCommand(this.userMethod) {
    argParser
      ..addOption(
        'url',
        mandatory: false,
      )
      ..addOption(
        'key',
        mandatory: false,
      );
  }

  final Future<void> Function({
    String? url,
    String? key,
  }) userMethod;

  @override
  String get name => 'configure';

  @override
  String get description => 'Configure server connection';

  @override
  Future<void> run() {
    final results = argResults!;
    return userMethod(
      url: (results['url'] as String?) ?? null,
      key: (results['key'] as String?) ?? null,
    );
  }
}

class TestCommand extends Command<void> {
  TestCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'test';

  @override
  String get description => 'Test authenticated API call';

  @override
  Future<void> run() {
    return userMethod();
  }
}
