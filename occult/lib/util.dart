import 'dart:io';

import 'package:interact/interact.dart';
import 'package:tint/tint.dart';

Theme theme = Theme(
  inputPrefix: '?'.padRight(2).brightCyan(),
  inputSuffix: '›'.padLeft(2).grey(),
  successPrefix: '✔'.padRight(2).brightGreen(),
  successSuffix: '·'.padLeft(2).grey(),
  errorPrefix: '✘'.padRight(2).brightRed(),
  hiddenPrefix: '****',
  messageStyle: (x) => x.bold(),
  errorStyle: (x) => x.red(),
  hintStyle: (x) => '($x)'.grey(),
  valueStyle: (x) => x.white(),
  defaultStyle: (x) => x.cyan(),
  activeItemPrefix: '❯'.green(),
  inactiveItemPrefix: ' ',
  activeItemStyle: (x) => x.cyan(),
  inactiveItemStyle: (x) => x,
  checkedItemPrefix: '✔'.brightGreen(),
  uncheckedItemPrefix: ' ',
  pickedItemPrefix: '❯'.brightGreen(),
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
