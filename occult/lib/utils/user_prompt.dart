import 'dart:io';

import 'package:fast_log/fast_log.dart';
import 'package:interact/interact.dart';

/// Modern interactive CLI prompts with arrow key navigation
class UserPrompt {
  /// Ask a yes/no question with arrow key selection
  static Future<bool> askYesNo(
    String question, {
    bool defaultValue = true,
  }) async {
    return Confirm(
      prompt: question,
      defaultValue: defaultValue,
      waitForNewLine: true,
    ).interact();
  }

  /// Ask for a string input with validation
  static Future<String> askString(
    String question, {
    String? defaultValue,
    bool Function(String)? validator,
    String? validationMessage,
  }) async {
    return Input(
      prompt: question,
      defaultValue: defaultValue ?? '',
      validator: validator != null
          ? (value) {
              if (validator(value)) return true;
              throw ValidationError(validationMessage ?? 'Invalid input');
            }
          : null,
    ).interact();
  }

  /// Ask for a number input
  static Future<int> askInt(
    String question, {
    required int defaultValue,
  }) async {
    final result = Input(
      prompt: question,
      defaultValue: defaultValue.toString(),
      validator: (value) {
        if (int.tryParse(value) != null) return true;
        throw ValidationError('Please enter a valid number');
      },
    ).interact();
    return int.parse(result);
  }

  /// Show a menu with arrow key navigation and get user selection
  static Future<int> showMenu(
    String title,
    List<String> options, {
    int? defaultIndex,
  }) async {
    print('');
    return Select(
      prompt: title,
      options: options,
      initialIndex: defaultIndex ?? 0,
    ).interact();
  }

  /// Multi-select with checkboxes and arrow key navigation
  static Future<List<int>> askMultiSelect(
    String title,
    List<String> options, {
    List<String>? defaultSelected,
  }) async {
    // Convert defaultSelected names to boolean list
    final defaults = options.map((opt) {
      return defaultSelected?.contains(opt) ?? true;
    }).toList();

    print('');
    return MultiSelect(
      prompt: title,
      options: options,
      defaults: defaults,
    ).interact();
  }

  /// Multi-select that returns the selected option names
  static Future<List<String>> askMultiSelectNames(
    String title,
    List<String> options, {
    List<String>? defaultSelected,
  }) async {
    final indices = await askMultiSelect(
      title,
      options,
      defaultSelected: defaultSelected,
    );
    return indices.map((i) => options[i]).toList();
  }

  /// Show a spinner while performing an async operation
  static Future<T> withSpinner<T>(
    String message,
    Future<T> Function() action,
  ) async {
    final spinner = Spinner(
      icon: '⠋',
      rightPrompt: (done) => done ? 'Done!' : message,
    ).interact();

    try {
      final result = await action();
      spinner.done();
      return result;
    } catch (e) {
      spinner.done();
      rethrow;
    }
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

  /// Show progress bar during operations
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
  static Future<String> askRetryChoice(String operationName) async {
    print('');
    warn('$operationName failed.');

    final options = ['Retry', 'Skip', 'Abort'];
    final choice = Select(
      prompt: 'What would you like to do?',
      options: options,
      initialIndex: 0,
    ).interact();

    return ['r', 's', 'a'][choice];
  }

  /// Press enter to continue
  static Future<void> pressEnter({
    String message = 'Press Enter to continue...',
  }) async {
    stdout.write(message);
    stdin.readLineSync();
  }

  /// Password input (hidden)
  static Future<String> askPassword(
    String prompt, {
    bool confirm = false,
  }) async {
    return Password(
      prompt: prompt,
      confirmation: confirm,
    ).interact();
  }

  /// Theme selector with preview
  static Future<int> askTheme(
    String prompt,
    List<String> themes,
    List<String> descriptions, {
    int initialIndex = 0,
  }) async {
    // Build options with descriptions
    final options = <String>[];
    for (int i = 0; i < themes.length; i++) {
      if (i < descriptions.length) {
        options.add('${themes[i]} - ${descriptions[i]}');
      } else {
        options.add(themes[i]);
      }
    }

    return Select(
      prompt: prompt,
      options: options,
      initialIndex: initialIndex,
    ).interact();
  }
}
