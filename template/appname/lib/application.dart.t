import 'package:appname/screen/home.dart';
import 'package:arcane/arcane.dart';
import 'package:arcane_auth/arcane_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class CareMapApplication extends StatefulWidget {
  const CareMapApplication({super.key});

  @override
  State<CareMapApplication> createState() => _CareMapApplicationState();
}

class _CareMapApplicationState extends State<CareMapApplication> {
  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => AuthenticatedArcaneApp(
        home: HomeScreen(),
        title: "AppName",
        loginScreenBuilder: (context, methods) => LoginScreen(
            authMethods: methods,
            header: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ArcaneArtsLogo(
                  size: 24,
                ),
                Gap(4),
                Text("AppName")
              ],
            )),
        theme: ArcaneTheme(
            themeMode: ThemeMode.system,
            scheme: ContrastedColorScheme.fromScheme(ColorSchemes.violet)),
        authMethods: [
          AuthMethod.emailPassword,
        ],
      );
}
