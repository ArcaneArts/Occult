import 'dart:io';

import 'package:interact/interact.dart';
import 'package:tint/tint.dart';

Theme theme = Theme(
  inputPrefix: '?'.padRight(2).yellow(),
  inputSuffix: '›'.padLeft(2).grey(),
  successPrefix: '✔'.padRight(2).green(),
  successSuffix: '·'.padLeft(2).grey(),
  errorPrefix: '✘'.padRight(2).red(),
  hiddenPrefix: '****',
  messageStyle: (x) => x.bold(),
  errorStyle: (x) => x.red(),
  hintStyle: (x) => '($x)'.grey(),
  valueStyle: (x) => x.green(),
  defaultStyle: (x) => x.cyan(),
  activeItemPrefix: '❯'.green(),
  inactiveItemPrefix: ' ',
  activeItemStyle: (x) => x.cyan(),
  inactiveItemStyle: (x) => x,
  checkedItemPrefix: '✔'.green(),
  uncheckedItemPrefix: ' ',
  pickedItemPrefix: '❯'.green(),
  unpickedItemPrefix: ' ',
  showActiveCursor: false,
  progressPrefix: '',
  progressSuffix: '',
  emptyProgress: '░',
  filledProgress: '█',
  leadingProgress: '█',
  emptyProgressStyle: (x) => x,
  filledProgressStyle: (x) => x,
  leadingProgressStyle: (x) => x,
  spinners: '⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'.split(''),
  spinningInterval: 80,
);

Future<void> ensureCLIInstalled(String tool) async {
  if (!await isCLIInstalled(tool)) {
    print(
        'The CLI tool $tool is not installed. Please install it and try again.');
    exit(1);
  }

  print('CLI tool $tool is installed.');
}

Future<bool> isCLIInstalled(String tool) async {
  try {
    final command = Platform.isWindows ? 'where' : 'which';
    final result = await Process.run(command, [tool]);
    return result.exitCode == 0;
  } catch (e) {
    return false;
  }
}

Future<void> runProcess(String command, List<String> args,
    [String? runIn]) async {
  final process = await Process.start(
    command,
    args,
    workingDirectory: runIn,
  );

  int exitCode = await process.exitCode;

  if (exitCode != 0) {
    throw Exception("Failed to process $command ${args.join(" ")} in $runIn");
  }
}

Future<void> interactive(String command, List<String> args,
    [String? runIn]) async {
  final process = await Process.start(
    command,
    args,
    mode: ProcessStartMode.inheritStdio,
    workingDirectory: runIn,
  );

  int exitCode = await process.exitCode;

  if (exitCode != 0) {
    throw Exception("Failed to process $command ${args.join(" ")} in $runIn");
  }
}
