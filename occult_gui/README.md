```
  ██████╗  ██████╗ ██████╗██╗   ██╗██╗  ████████╗     ██████╗ ██╗   ██╗██╗
 ██╔═══██╗██╔════╝██╔════╝██║   ██║██║  ╚══██╔══╝    ██╔════╝ ██║   ██║██║
 ██║   ██║██║     ██║     ██║   ██║██║     ██║       ██║  ███╗██║   ██║██║
 ██║   ██║██║     ██║     ██║   ██║██║     ██║       ██║   ██║██║   ██║██║
 ╚██████╔╝╚██████╗╚██████╗╚██████╔╝███████╗██║       ╚██████╔╝╚██████╔╝██║
  ╚═════╝  ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝        ╚═════╝  ╚═════╝ ╚═╝
```

Visual project creation wizard for Arcane Templates.

## Platforms

- macOS
- Linux
- Windows

## Development

```bash
flutter pub get
flutter run
```

### Run on Specific Platform

```bash
flutter run -d macos
flutter run -d linux
flutter run -d windows
```

### Build

```bash
flutter build macos
flutter build linux
flutter build windows
```

## Architecture

```
lib/
├── main.dart           App entry point
├── screens/
│   └── wizard_screen.dart   Project configuration UI
├── models/
│   └── wizard_config.dart   Configuration state
└── services/           Business logic
```

## Dependencies

- arcane - UI framework
- pylon - UI toolkit
- file_picker - Directory selection
