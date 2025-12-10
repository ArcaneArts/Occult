```
  ██████╗  ██████╗ ██████╗██╗   ██╗██╗  ████████╗     ██████╗██╗     ██╗
 ██╔═══██╗██╔════╝██╔════╝██║   ██║██║  ╚══██╔══╝    ██╔════╝██║     ██║
 ██║   ██║██║     ██║     ██║   ██║██║     ██║       ██║     ██║     ██║
 ██║   ██║██║     ██║     ██║   ██║██║     ██║       ██║     ██║     ██║
 ╚██████╔╝╚██████╗╚██████╗╚██████╔╝███████╗██║       ╚██████╗███████╗██║
  ╚═════╝  ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝        ╚═════╝╚══════╝╚═╝
```

Command-line interface for Arcane project scaffolding and script running.

## Installation

```bash
dart pub global activate occult
```

## Commands

### Project Creation

```bash
occult                          # Interactive wizard
occult gui                      # Launch GUI wizard
occult create app               # Create new project
occult create templates         # List available templates
```

### Script Runner

Run scripts from `pubspec.yaml` with fuzzy matching:

```bash
occult scripts list             # List all available scripts
occult scripts exec <name>      # Execute a script
occult scripts exec build       # Exact match
occult scripts exec br          # Abbreviation (build_runner)
occult scripts exec tv          # Abbreviation (test_verbose)
occult scripts exec --stream    # Stream output in real-time
```

**Matching modes:**
- Exact: `build_runner`
- Case-insensitive: `Build_Runner`
- Prefix: `build` (if unique)
- Contains: `runner` (if unique)
- Abbreviation: `br` = `build_runner`, `df` = `deploy_firebase`

### Tool Verification

```bash
occult check tools              # Verify all required CLI tools
occult check flutter            # Check Flutter installation
occult check firebase           # Check Firebase CLI tools
occult check docker             # Check Docker installation
occult check gcloud             # Check Google Cloud SDK
occult check server             # Check server deployment tools
occult check doctor             # Run flutter doctor -v
```

### Firebase Deployment

```bash
occult deploy all               # Deploy all Firebase resources
occult deploy firestore         # Deploy Firestore rules/indexes
occult deploy storage           # Deploy Storage rules
occult deploy hosting           # Build web & deploy to release
occult deploy hosting-beta      # Build web & deploy to beta
occult deploy firebase-setup    # Initial Firebase/FlutterFire setup
occult deploy generate-configs  # Generate Firebase config files
```

### Server Deployment

```bash
occult deploy server-setup      # Generate Dockerfiles & scripts
occult deploy server-build      # Build production Docker image
```

### Configuration

```bash
occult config show              # Display current configuration
occult config path              # Show config file path
```

## Templates

| # | Name | Type | Platforms | Description |
|---|------|------|-----------|-------------|
| 1 | Basic Arcane | Flutter | All | Multi-platform app with Arcane UI |
| 2 | Beamer Navigation | Flutter | All | Declarative routing with Beamer |
| 3 | Desktop Tray | Flutter | Desktop | System tray/menu bar app |
| 4 | Dart CLI | Dart | - | Command-line interface |

### Additional Packages

- **Models Package** (`<app>_models`) - Shared data models with Artifact serialization
- **Server App** (`<app>_server`) - Shelf REST API with FireCrud integration

## Development

### Setup

```bash
dart pub get
dart run build_runner build --delete-conflicting-outputs
```

### Run Locally

```bash
dart run bin/main.dart --help
dart run bin/main.dart scripts list
```

### Local Testing

```bash
# Activate from source
dart pub global activate . --source=path

# Test commands
occult --help
occult scripts list

# Deactivate
dart pub global deactivate occult
```

### Watch Mode

```bash
dart run build_runner watch -d
```

### Scripts (via Occult)

```bash
occult scripts exec build       # Run build_runner
occult scripts exec test        # Run tests
occult scripts exec activate    # Activate locally
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
  Future<void> action(String param, {bool flag = false}) async {
    info("Running with $param, flag=$flag");
  }
}
```

2. Register in `lib/occult.dart`

```dart
import 'commands/my_command.dart';

// In OccultRunner class:
@cliMount
MyCommand get my => MyCommand();
```

3. Generate code

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Architecture

```
lib/
├── occult.dart              CLI runner & command mounts
├── commands/                Command implementations
│   ├── check_command.dart      Tool verification
│   ├── config_command.dart     Configuration management
│   ├── create_command.dart     Project creation
│   ├── deploy_command.dart     Firebase/server deployment
│   ├── gui_command.dart        GUI launcher
│   └── script_command.dart     Script runner
├── services/                Business logic
│   ├── script_runner.dart      Pubspec script execution
│   ├── template_copier.dart    Template file copying
│   ├── project_creator.dart    Flutter/Dart project creation
│   ├── dependency_manager.dart Dependency management
│   └── ...
├── models/                  Data structures
└── utils/                   Utilities
```

## Publishing

```bash
dart pub publish --dry-run      # Verify
dart pub publish                # Publish to pub.dev
```
