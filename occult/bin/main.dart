import 'package:occult/occult.dart';
import 'package:occult/services/interactive_wizard.dart';

/// Entry point for occult CLI application
void main(List<String> arguments) async {
  // If no arguments provided, launch interactive wizard
  if (arguments.isEmpty) {
    final wizard = InteractiveWizard();
    await wizard.run();
    return;
  }

  // Otherwise, run the CLI with provided arguments
  final runner = OccultRunner();
  await runner.run(arguments);
}
