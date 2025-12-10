// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'script_command.dart';

// **************************************************************************
// SubcommandGenerator
// **************************************************************************

class _$ScriptsCommand<T extends dynamic> extends Command<dynamic> {
  _$ScriptsCommand() {
    final upcastedType = (this as ScriptsCommand);
    addSubcommand(ListCommand(upcastedType.list));
    addSubcommand(ExecCommand(upcastedType.exec));
  }

  @override
  String get name => 'scripts';

  @override
  String get description => 'Manage and run scripts defined in pubspec.yaml';
}

class ListCommand extends Command<void> {
  ListCommand(this.userMethod);

  final void Function() userMethod;

  @override
  String get name => 'list';

  @override
  String get description =>
      'List all available scripts (default when no script specified)';

  @override
  void run() {
    return userMethod();
  }
}

class ExecCommand extends Command<void> {
  ExecCommand(this.userMethod) {
    argParser
      ..addOption(
        'script',
        mandatory: true,
      )
      ..addFlag(
        'stream',
        defaultsTo: false,
      );
  }

  final Future<void> Function(
    String, {
    bool stream,
  }) userMethod;

  @override
  String get name => 'exec';

  @override
  String get description => 'Execute a script by name';

  @override
  Future<void> run() {
    final results = argResults!;
    var [String script] = results.rest;
    return userMethod(
      script,
      stream: (results['stream'] as bool?) ?? false,
    );
  }
}
