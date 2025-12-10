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
    // Calculate width based on longest content
    int maxContentLen = title.length;
    for (final entry in config.entries) {
      final lineLen = '${entry.key}: ${entry.value}'.length;
      if (lineLen > maxContentLen) maxContentLen = lineLen;
    }
    // Box structure: │ content │ = content + 4 chars for "│ " and " │"
    // Line width = content width + 2 for the spaces inside borders
    final innerWidth = (maxContentLen + 2).clamp(38, 78);
    final line = '\u2500' * innerWidth;

    print('');
    print('\u256d$line\u256e');
    _printBoxLine(title, innerWidth, center: true);
    print('\u251c$line\u2524');

    for (final entry in config.entries) {
      _printBoxLine('${entry.key}: ${entry.value}', innerWidth);
    }

    print('\u2570$line\u256f');
  }

  static void _printBoxLine(String text, int innerWidth, {bool center = false}) {
    // innerWidth is the width between the │ chars (includes the space padding)
    // So actual content area is innerWidth - 2 for the spaces
    final contentWidth = innerWidth - 2;
    String content;
    if (center) {
      final leftPad = (contentWidth - text.length) ~/ 2;
      final rightPad = contentWidth - text.length - leftPad;
      content = ' ' * leftPad + text + ' ' * rightPad;
    } else {
      content = text.length > contentWidth
          ? text.substring(0, contentWidth)
          : text.padRight(contentWidth);
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
    // Calculate width based on content
    int maxContentLen = title.length;
    if (subtitle != null && subtitle.length > maxContentLen) {
      maxContentLen = subtitle.length;
    }
    // Inner width includes space padding on each side
    final innerWidth = (maxContentLen + 4).clamp(38, 78);
    final line = '\u2550' * innerWidth;

    print('');
    print('\u2554$line\u2557');
    _printBannerLine(title, innerWidth);
    if (subtitle != null) {
      _printBannerLine(subtitle, innerWidth);
    }
    print('\u255a$line\u255d');
    print('');
  }

  static void _printBannerLine(String text, int innerWidth) {
    // Content width is innerWidth minus 2 for space padding
    final contentWidth = innerWidth - 2;
    final leftPad = (contentWidth - text.length) ~/ 2;
    final rightPad = contentWidth - text.length - leftPad;
    final content = ' ' * leftPad + text + ' ' * rightPad;
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
