```
  ██████╗  ██████╗ ██████╗██╗   ██╗██╗  ████████╗
 ██╔═══██╗██╔════╝██╔════╝██║   ██║██║  ╚══██╔══╝
 ██║   ██║██║     ██║     ██║   ██║██║     ██║
 ██║   ██║██║     ██║     ██║   ██║██║     ██║
 ╚██████╔╝╚██████╗╚██████╗╚██████╔╝███████╗██║
  ╚═════╝  ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝
```

Project scaffolding system for Arcane-based Flutter and Dart applications.

## Structure

```
Occult/
├── occult/        Dart CLI tool
└── occult_gui/    Flutter GUI wizard
```

## Installation

```bash
dart pub global activate occult
```

## Usage

```bash
occult              # Interactive wizard
occult gui          # Launch GUI wizard
occult create       # Create project via CLI
occult check tools  # Verify required tools
```

## Templates

| Name | Type | Description |
|------|------|-------------|
| arcane_template | Flutter | Multi-platform app |
| arcane_beamer | Flutter | Beamer navigation |
| arcane_dock | Flutter | Desktop system tray |
| arcane_cli | Dart | CLI application |

## Development

See individual package READMEs for development instructions.

## License

MIT
