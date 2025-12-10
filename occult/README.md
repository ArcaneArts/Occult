```
  ██████╗  ██████╗ ██████╗██╗   ██╗██╗  ████████╗     ██████╗██╗     ██╗
 ██╔═══██╗██╔════╝██╔════╝██║   ██║██║  ╚══██╔══╝    ██╔════╝██║     ██║
 ██║   ██║██║     ██║     ██║   ██║██║     ██║       ██║     ██║     ██║
 ██║   ██║██║     ██║     ██║   ██║██║     ██║       ██║     ██║     ██║
 ╚██████╔╝╚██████╗╚██████╗╚██████╔╝███████╗██║       ╚██████╗███████╗██║
  ╚═════╝  ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝        ╚═════╝╚══════╝╚═╝
```

Command-line interface for Arcane project scaffolding.

## Installation

```bash
dart pub global activate occult
```

## Commands

```
occult                      Interactive wizard
occult gui                  Launch GUI wizard
occult create               Create new project
occult create templates     List available templates
occult check tools          Verify CLI tools
occult config <cmd>         Configuration management
occult deploy all           Deploy Firebase resources
```

## Development

```bash
dart pub get
dart run build_runner build --delete-conflicting-outputs
dart run bin/main.dart --help
```

### Local Testing

```bash
dart pub global activate . --source=path
occult --help
dart pub global deactivate occult
```

### Watch Mode

```bash
dart run build_runner watch -d
```

## Adding Commands

1. Create file in `lib/commands/`

```dart
import 'package:cli_annotations/cli_annotations.dart';
import 'package:fast_log/fast_log.dart';

part 'my_command.g.dart';

@cliSubcommand
class MyCommand extends _$MyCommand {
  @cliCommand
  Future<void> run(String param) async {
    info("Running...");
  }
}
```

2. Register in `lib/occult.dart`

```dart
@cliMount
MyCommand get my => MyCommand();
```

3. Generate code

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Publishing

```bash
dart pub publish --dry-run
dart pub publish
```
