import 'package:arcane/arcane.dart';
import 'package:occult_gui/screens/wizard_screen.dart';

//  ██████╗  ██████╗ ██████╗██╗   ██╗██╗  ████████╗     ██████╗ ██╗   ██╗██╗
// ██╔═══██╗██╔════╝██╔════╝██║   ██║██║  ╚══██╔══╝    ██╔════╝ ██║   ██║██║
// ██║   ██║██║     ██║     ██║   ██║██║     ██║       ██║  ███╗██║   ██║██║
// ██║   ██║██║     ██║     ██║   ██║██║     ██║       ██║   ██║██║   ██║██║
// ╚██████╔╝╚██████╗╚██████╗╚██████╔╝███████╗██║       ╚██████╔╝╚██████╔╝██║
//  ╚═════╝  ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝        ╚═════╝  ╚═════╝ ╚═╝
//
// Occult GUI - Visual project creation wizard for Arcane Templates

void main() {
  runApp("occult_gui", const OccultGuiApp());
}

class OccultGuiApp extends StatefulWidget {
  const OccultGuiApp({super.key});

  @override
  State<OccultGuiApp> createState() => _OccultGuiAppState();
}

class _OccultGuiAppState extends State<OccultGuiApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = switch (_themeMode) {
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
        ThemeMode.system => ThemeMode.light,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return ArcaneApp(
      debugShowCheckedModeBanner: false,
      theme: ArcaneTheme(
        scheme: ContrastedColorScheme(
          light: ColorSchemes.violet(ThemeMode.light),
          dark: ColorSchemes.orange(ThemeMode.dark),
        ),
        themeMode: _themeMode,
      ),
      home: const WizardScreen(),
    );
  }
}

extension OccultGuiAppContext on BuildContext {
  void toggleTheme() {
    final _OccultGuiAppState? state = findAncestorStateOfType<_OccultGuiAppState>();
    state?._toggleTheme();
  }

  ThemeMode get currentThemeMode {
    final _OccultGuiAppState? state = findAncestorStateOfType<_OccultGuiAppState>();
    return state?._themeMode ?? ThemeMode.system;
  }
}
