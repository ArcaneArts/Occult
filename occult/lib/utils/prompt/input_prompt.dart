import 'package:interact/interact.dart';

/// Text input prompts (strings, numbers, validation)
class InputPrompt {
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
    int? min,
    int? max,
  }) async {
    final result = Input(
      prompt: question,
      defaultValue: defaultValue.toString(),
      validator: (value) {
        final num = int.tryParse(value);
        if (num == null) {
          throw ValidationError('Please enter a valid number');
        }
        if (min != null && num < min) {
          throw ValidationError('Value must be at least $min');
        }
        if (max != null && num > max) {
          throw ValidationError('Value must be at most $max');
        }
        return true;
      },
    ).interact();
    return int.parse(result);
  }

  /// Ask for a double/decimal input
  static Future<double> askDouble(
    String question, {
    required double defaultValue,
    double? min,
    double? max,
  }) async {
    final result = Input(
      prompt: question,
      defaultValue: defaultValue.toString(),
      validator: (value) {
        final num = double.tryParse(value);
        if (num == null) {
          throw ValidationError('Please enter a valid number');
        }
        if (min != null && num < min) {
          throw ValidationError('Value must be at least $min');
        }
        if (max != null && num > max) {
          throw ValidationError('Value must be at most $max');
        }
        return true;
      },
    ).interact();
    return double.parse(result);
  }

  /// Ask for email input with validation
  static Future<String> askEmail(String question, {String? defaultValue}) async {
    return Input(
      prompt: question,
      defaultValue: defaultValue ?? '',
      validator: (value) {
        if (value.contains('@') && value.contains('.')) return true;
        throw ValidationError('Please enter a valid email address');
      },
    ).interact();
  }

  /// Ask for URL input with validation
  static Future<String> askUrl(String question, {String? defaultValue}) async {
    return Input(
      prompt: question,
      defaultValue: defaultValue ?? '',
      validator: (value) {
        if (value.startsWith('http://') || value.startsWith('https://')) {
          return true;
        }
        throw ValidationError('Please enter a valid URL (http:// or https://)');
      },
    ).interact();
  }
}
