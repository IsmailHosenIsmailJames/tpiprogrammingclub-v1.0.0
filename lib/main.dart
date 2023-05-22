import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tpiprogrammingclub/authentication/login.dart';
import 'package:tpiprogrammingclub/pages/contents/contents.dart';
import 'package:tpiprogrammingclub/pages/contributors/contributors.dart';
import 'package:tpiprogrammingclub/pages/home/home_page.dart';
import 'package:tpiprogrammingclub/widget/search.dart';
import 'package:url_strategy/url_strategy.dart';
import 'firebase_options.dart';

void main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static const String title = 'TPI Programming Club';

  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        drawerTheme: const DrawerThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        "/": (context) => const HomePage(),
        "/login": (context) => const Login(),
        "/home": (context) => const HomePage(),
        "/search": (context) => const Search(),
        "/contributors": (context) => const Contributors(),
      },
      onGenerateRoute: (settings) {
        String url = settings.name!;
        return MaterialPageRoute(
          builder: (context) => Contents(path: url),
          settings: settings,
          allowSnapshotting: true,
          maintainState: true,
        );
      },
    );
  }
}

Gradient gradiantOfcontaner = const RadialGradient(
  colors: [
    Color.fromARGB(255, 232, 242, 255),
    Color.fromARGB(255, 255, 216, 204)
  ],
  center: Alignment(0.6, -0.3),
  focal: Alignment(0.3, -0.1),
  focalRadius: 1.0,
);
