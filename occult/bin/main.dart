import 'package:darted_cli/darted_cli.dart';

import 'package:occult/cli/commands.dart';
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
  await dartedEntry(
    input: arguments,
    commandsTree: commandsTree,
    customEntryHelper: (_) async => '''
╔═══════════════════════════════════════════════════════════╗
║                      OCCULT CLI                           ║
║               Arcane Template System                      ║
╚═══════════════════════════════════════════════════════════╝
''',
    customVersionResponse: () => 'Occult CLI v2.0.0',
  );
}
