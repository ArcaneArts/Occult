// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hello_command.dart';

// **************************************************************************
// SubcommandGenerator
// **************************************************************************

class _$HelloCommand<T extends dynamic> extends Command<dynamic> {
  _$HelloCommand() {
    final upcastedType = (this as HelloCommand);
    addSubcommand(GreetCommand(upcastedType.greet));
    addSubcommand(VersionCommand(upcastedType.version));
  }

  @override
  String get name => 'hello';

  @override
  String get description =>
      'Hello world command - demonstrates basic CLI structure';
}

class GreetCommand extends Command<void> {
  GreetCommand(this.userMethod) {
    argParser
      ..addOption(
        'name',
        mandatory: true,
      )
      ..addOption(
        'times',
        defaultsTo: '1',
        mandatory: false,
      )
      ..addFlag(
        'enthusiastic',
        defaultsTo: false,
      );
  }

  final Future<void> Function(
    String, {
    int times,
    bool enthusiastic,
  }) userMethod;

  @override
  String get name => 'greet';

  @override
  String get description => 'Say hello with optional customization';

  @override
  Future<void> run() {
    final results = argResults!;
    var [String name] = results.rest;
    return userMethod(
      name,
      times: results['times'] != null ? int.parse(results['times']) : 1,
      enthusiastic: (results['enthusiastic'] as bool?) ?? false,
    );
  }
}

class VersionCommand extends Command<void> {
  VersionCommand(this.userMethod);

  final Future<void> Function() userMethod;

  @override
  String get name => 'version';

  @override
  String get description => 'Display version information';

  @override
  Future<void> run() {
    return userMethod();
  }
}
