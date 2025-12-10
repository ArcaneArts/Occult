import 'dart:io';

import 'package:fast_log/fast_log.dart';

/// Utility class for interactive user prompts
class UserPrompt {
  /// Ask a yes/no question
  static Future<bool> askYesNo(
    String question, {
    bool defaultValue = true,
  }) async {
    final defaultHint = defaultValue ? '[Y/n]' : '[y/N]';
    stdout.write('$question $defaultHint: ');

    final input = stdin.readLineSync()?.trim().toLowerCase();

    if (input == null || input.isEmpty) {
      return defaultValue;
    }

    return input == 'y' || input == 'yes';
  }

  /// Ask for a string input
  static Future<String> askString(
    String question, {
    String? defaultValue,
    bool Function(String)? validator,
    String? validationMessage,
  }) async {
    while (true) {
      if (defaultValue != null) {
        stdout.write('$question [$defaultValue]: ');
      } else {
        stdout.write('$question: ');
      }

      final input = stdin.readLineSync()?.trim();

      if (input == null || input.isEmpty) {
        if (defaultValue != null) {
          return defaultValue;
        }
        warn('Input required');
        continue;
      }

      if (validator != null && !validator(input)) {
        warn(validationMessage ?? 'Invalid input');
        continue;
      }

      return input;
    }
  }

  /// Ask for a number input
  static Future<int> askInt(
    String question, {
    required int defaultValue,
  }) async {
    stdout.write('$question [$defaultValue]: ');

    final input = stdin.readLineSync()?.trim();

    if (input == null || input.isEmpty) {
      return defaultValue;
    }

    return int.tryParse(input) ?? defaultValue;
  }

  /// Show a menu and get user selection
  static Future<int> showMenu(
    String title,
    List<String> options, {
    int? defaultIndex,
  }) async {
    print('\n$title');
    print('\u2500' * 60);

    for (int i = 0; i < options.length; i++) {
      final marker = (defaultIndex != null && i == defaultIndex) ? '*' : ' ';
      print('$marker ${i + 1}. ${options[i]}');
    }

    print('\u2500' * 60);
    final defaultHint = defaultIndex != null ? ' [${defaultIndex + 1}]' : '';
    stdout.write('Enter selection (1-${options.length})$defaultHint: ');

    final input = stdin.readLineSync()?.trim();

    if (input == null || input.isEmpty) {
      return defaultIndex ?? 0;
    }

    final selection = int.tryParse(input);

    if (selection == null || selection < 1 || selection > options.length) {
      warn('Invalid selection, defaulting to ${(defaultIndex ?? 0) + 1}');
      return defaultIndex ?? 0;
    }

    return selection - 1;
  }

  /// Show a pretty configuration preview box
  static void printConfigPreview(
    Map<String, String> config, {
    String title = 'Configuration Preview',
  }) {
    const int width = 60;
    final line = '\u2500' * width;

    print('');
    print('\u256d$line\u256e');
    _printBoxLine(title, width, center: true);
    print('\u251c$line\u2524');

    for (final entry in config.entries) {
      _printBoxLine('${entry.key}: ${entry.value}', width);
    }

    print('\u2570$line\u256f');
  }

  static void _printBoxLine(String text, int width, {bool center = false}) {
    String content;
    if (center) {
      final padding = (width - text.length) ~/ 2;
      content = ' ' * padding + text + ' ' * (width - padding - text.length);
    } else {
      content = text.length > width
          ? text.substring(0, width)
          : text.padRight(width);
    }
    print('\u2502 $content \u2502');
  }

  /// Show progress during operations
  static void showProgress(int current, int total, String message) {
    final percent = (current / total * 100).toStringAsFixed(0);
    final bar = _makeProgressBar(current, total, 30);

    // Use carriage return to overwrite the line
    stdout.write('\r[$bar] $percent% ($current/$total) $message'.padRight(100));

    // If complete, move to next line
    if (current == total) {
      print('');
    }
  }

  static String _makeProgressBar(int current, int total, int width) {
    final filled = (current / total * width).round();
    final empty = width - filled;
    return '\u2588' * filled + '\u2591' * empty;
  }

  /// Print a header banner
  static void printBanner(String title, {String? subtitle}) {
    const width = 60;
    final line = '\u2550' * width;

    print('');
    print('\u2554$line\u2557');
    _printBannerLine(title, width);
    if (subtitle != null) {
      _printBannerLine(subtitle, width);
    }
    print('\u255a$line\u255d');
    print('');
  }

  static void _printBannerLine(String text, int width) {
    final padding = (width - text.length) ~/ 2;
    final content =
        ' ' * padding + text + ' ' * (width - padding - text.length);
    print('\u2551 $content \u2551');
  }

  /// Ask user for retry choice after failure
  /// Returns: 'r' = retry, 's' = skip, 'a' = abort
  static Future<String> askRetryChoice(String operationName) async {
    print('');
    warn('$operationName failed.');
    stdout.write('(r)etry, (s)kip, or (a)bort? [r]: ');

    final input = stdin.readLineSync()?.trim().toLowerCase();

    if (input == null || input.isEmpty || input == 'r' || input == 'retry') {
      return 'r';
    } else if (input == 's' || input == 'skip') {
      return 's';
    } else if (input == 'a' || input == 'abort') {
      return 'a';
    }

    return 'r'; // Default to retry
  }

  /// Press enter to continue
  static Future<void> pressEnter({
    String message = 'Press Enter to continue...',
  }) async {
    stdout.write(message);
    stdin.readLineSync();
  }

  /// Show a multi-select checkbox menu for platforms
  /// Returns list of selected platform names
  static Future<List<String>> askMultiSelect(
    String title,
    List<String> options, {
    List<String>? defaultSelected,
  }) async {
    final selected = Set<String>.from(defaultSelected ?? options);

    print('\n$title');
    print('\u2500' * 60);
    print('Toggle with number, Enter when done:');
    print('\u2500' * 60);

    while (true) {
      // Display options with checkboxes
      for (int i = 0; i < options.length; i++) {
        final isSelected = selected.contains(options[i]);
        final checkbox = isSelected ? '[\u2713]' : '[ ]';
        print('  ${i + 1}. $checkbox ${options[i]}');
      }
      print('\u2500' * 60);
      stdout.write('Toggle (1-${options.length}) or Enter to confirm: ');

      final input = stdin.readLineSync()?.trim();

      if (input == null || input.isEmpty) {
        // User pressed Enter, return selection
        return selected.toList();
      }

      final selection = int.tryParse(input);
      if (selection != null && selection >= 1 && selection <= options.length) {
        final option = options[selection - 1];
        if (selected.contains(option)) {
          selected.remove(option);
        } else {
          selected.add(option);
        }
        // Clear and redraw (move cursor up)
        for (int i = 0; i < options.length + 3; i++) {
          stdout.write('\x1B[1A\x1B[2K'); // Move up and clear line
        }
      }
    }
  }
}
