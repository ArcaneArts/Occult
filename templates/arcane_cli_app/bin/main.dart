import 'package:arcane_cli_app/arcane_cli_app.dart';

/// Entry point for arcane_cli_app CLI application
void main(List<String> arguments) async {
  final runner = ArcaneRunner();
  await runner.run(arguments);
}
