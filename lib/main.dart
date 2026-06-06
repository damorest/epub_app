import 'package:flutter/material.dart';
import 'screens/library_screen.dart';

void main() => runApp(const EpubApp());

class EpubApp extends StatelessWidget {
  const EpubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Моя бібліотека',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFc8a96e),
          brightness: Brightness.dark,
          surface: const Color(0xFF16213e),
        ),
        scaffoldBackgroundColor: const Color(0xFF1a1a2e),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF16213e),
          foregroundColor: Color(0xFFc8a96e),
          elevation: 0,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF16213e),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: const LibraryScreen(),
    );
  }
}
