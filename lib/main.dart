import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  runApp(const Earn249App());
}

class Earn249App extends StatefulWidget {
  const Earn249App({super.key});
  @override
  State<Earn249App> createState() => _Earn249AppState();
}

class _Earn249AppState extends State<Earn249App> {
  Locale _locale = const Locale('ar');
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'EARN249', debugShowCheckedModeBanner: false,
    locale: _locale, supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF101411), colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF20C76A), brightness: Brightness.dark), appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF101411), elevation: 0), inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: const Color(0xFF1B241E), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
    home: AuthScreen(onLocaleChanged: (v) => setState(() => _locale = v)),
  );
}
