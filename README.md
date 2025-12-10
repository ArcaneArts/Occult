```
  ██████╗  ██████╗ ██████╗██╗   ██╗██╗  ████████╗
 ██╔═══██╗██╔════╝██╔════╝██║   ██║██║  ╚══██╔══╝
 ██║   ██║██║     ██║     ██║   ██║██║     ██║
 ██║   ██║██║     ██║     ██║   ██║██║     ██║
 ╚██████╔╝╚██████╗╚██████╗╚██████╔╝███████╗██║
  ╚═════╝  ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝
```

Project scaffolding and script runner for Arcane-based Flutter and Dart applications.

## Features

- **Project Scaffolding** - Create production-ready Flutter and Dart projects
- **Script Runner** - Execute pubspec.yaml scripts with fuzzy matching
- **Multi-Project Architecture** - Client, models, and server packages
- **Firebase Integration** - Automated setup and deployment
- **Platform Selection** - Choose which platforms to target

## Structure

```
Occult/
├── occult/          Dart CLI tool
├── occult_gui/      Flutter GUI wizard
└── templates/       Project templates (editable)
    ├── arcane_app/         Basic multi-platform Flutter app
    ├── arcane_beamer_app/  Beamer navigation Flutter app
    ├── arcane_dock_app/    Desktop system tray app
    ├── arcane_cli_app/     Dart CLI application
    ├── arcane_models/      Shared data models package
    └── arcane_server/      Shelf-based REST API server
```

## Installation

```bash
dart pub global activate occult
```

## Quick Start

```bash
# Interactive wizard
occult

# Launch GUI wizard
occult gui

# Create project directly
occult create app --name my_app --org com.example
```

## Commands

### Project Creation

```bash
occult                          # Interactive wizard
occult gui                      # Launch GUI wizard
occult create app               # Create project with prompts
occult create templates         # List available templates
```

### Script Runner

Run scripts defined in your `pubspec.yaml`:

```bash
occult scripts list             # List all scripts
occult scripts exec build       # Run a script
occult scripts exec br          # Abbreviation (build_runner)
occult scripts exec tv          # Abbreviation (test_verbose)
```

Supports fuzzy matching and abbreviations (first letter of each word).

### Tool Verification

```bash
occult check tools              # Verify all CLI tools
occult check flutter            # Check Flutter installation
occult check firebase           # Check Firebase CLI
occult check docker             # Check Docker
occult check gcloud             # Check Google Cloud SDK
occult check doctor             # Run flutter doctor
```

### Firebase Deployment

```bash
occult deploy all               # Deploy all Firebase resources
occult deploy firestore         # Deploy Firestore rules
occult deploy storage           # Deploy Storage rules
occult deploy hosting           # Deploy to release hosting
occult deploy hosting-beta      # Deploy to beta hosting
occult deploy firebase-setup    # Initial Firebase setup
```

### Server Deployment

```bash
occult deploy server-setup      # Generate Docker configs
occult deploy server-build      # Build Docker image
```

## Templates

| Template | Type | Platforms | Description |
|----------|------|-----------|-------------|
| Basic Arcane | Flutter | All | Multi-platform app with Arcane UI |
| Beamer Navigation | Flutter | All | Declarative routing with Beamer |
| Desktop Tray | Flutter | Desktop | System tray/menu bar application |
| Dart CLI | Dart | - | Command-line interface app |

### Additional Packages

- **Models Package** - Shared data models for client and server
- **Server App** - Shelf-based REST API with Firebase integration

## Script Runner Examples

Add scripts to your `pubspec.yaml`:

```yaml
scripts:
  build: flutter build web --release
  deploy: firebase deploy --project my-project
  build_runner: dart run build_runner build --delete-conflicting-outputs
  test_verbose: dart test --reporter=expanded
  pod_install: cd ios && pod install --repo-update
```

Then run with abbreviations:

```bash
occult scripts exec b           # build (unique prefix)
occult scripts exec br          # build_runner
occult scripts exec tv          # test_verbose
occult scripts exec pi          # pod_install
```

## Development

See individual package READMEs:
- [CLI Development](occult/README.md)
- [GUI Development](occult_gui/README.md)

## License

MIT
