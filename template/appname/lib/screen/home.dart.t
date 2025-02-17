import 'package:arcane/arcane.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => ArcaneScreen(
      child:
          Center(child: PrimaryButton(child: Text("Ping"), onPressed: () {})));
}
