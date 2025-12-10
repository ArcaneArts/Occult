// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gui_command.dart';

// **************************************************************************
// SubcommandGenerator
// **************************************************************************

class _$GuiCommand<T extends dynamic> extends Command<dynamic> {
  _$GuiCommand() {
    final upcastedType = (this as GuiCommand);
    addSubcommand(LaunchCommand(upcastedType.launch));
    addSubcommand(BuildCommand(upcastedType.build));
  }

  @override
  String get name => 'gui';

  @override
  String get description => 'GUI command - launch the Occult GUI wizard';
}

class LaunchCommand extends Command<void> {
  LaunchCommand(this.userMethod) {
    argParser
      ..addOption(
        'platform',
        mandatory: false,
      )
      ..addFlag(
        'release',
        defaultsTo: false,
      );
  }

  final Future<void> Function({
    String? platform,
    bool release,
  }) userMethod;

  @override
  String get name => 'launch';

  @override
  String get description => 'Launch the Occult GUI wizard application';

  @override
  Future<void> run() {
    final results = argResults!;
    return userMethod(
      platform: (results['platform'] as String?) ?? null,
      release: (results['release'] as bool?) ?? false,
    );
  }
}

class BuildCommand extends Command<void> {
  BuildCommand(this.userMethod) {
    argParser.addOption(
      'platform',
      defaultsTo: 'macos',
      mandatory: false,
    );
  }

  final Future<void> Function({String platform}) userMethod;

  @override
  String get name => 'build';

  @override
  String get description => 'Build the Occult GUI for distribution';

  @override
  Future<void> run() {
    final results = argResults!;
    return userMethod(platform: (results['platform'] as String?) ?? 'macos');
  }
}
