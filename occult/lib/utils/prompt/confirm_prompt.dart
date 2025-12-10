import 'package:interact/interact.dart';

/// Confirmation prompts (yes/no questions)
class ConfirmPrompt {
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

  /// Ask for confirmation with custom yes/no labels
  static Future<bool> askConfirm(
    String question, {
    bool defaultValue = true,
    String yesLabel = 'Yes',
    String noLabel = 'No',
  }) async {
    final choice = Select(
      prompt: question,
      options: [yesLabel, noLabel],
      initialIndex: defaultValue ? 0 : 1,
    ).interact();
    return choice == 0;
  }
}
