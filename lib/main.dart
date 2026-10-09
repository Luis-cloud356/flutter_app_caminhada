import 'package:flutter/material.dart';

import 'pages/splash.dart';
import 'pages/home.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const CaminhadasApp());
}

class CaminhadasApp extends StatefulWidget {
  const CaminhadasApp({super.key});

  @override
  State<CaminhadasApp> createState() => _CaminhadasAppState();
}

class _CaminhadasAppState extends State<CaminhadasApp> {
  final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  ThemeMode _themeMode = ThemeMode.light;

  void alterarTema(bool escuro) {
    setState(() {
      _themeMode = escuro ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Caminhadas',

      theme: AppTheme.temaClaro,
      darkTheme: AppTheme.temaEscuro,
      themeMode: _themeMode,

      home: Splash(
        onFinalizado: () {
          _navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(
              builder: (_) => Home(
                temaEscuro: _themeMode == ThemeMode.dark,
                onTemaAlterado: alterarTema,
              ),
            ),
          );
        },
      ),
    );
  }
}