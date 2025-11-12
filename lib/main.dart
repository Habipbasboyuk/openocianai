import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:hack_the_future_starter/features/chat/view/chat_screen.dart';
import 'package:hack_the_future_starter/l10n/app_localizations.dart';
import 'package:hack_the_future_starter/core/theme/theme_notifier.dart';
import 'package:logging/logging.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure GenUI logging
  configureGenUiLogging(level: Level.ALL);

  // Configure app-wide logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print(
      '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}',
    );
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeNotifier.isDarkMode,
      builder: (context, dark, _) {
        return MaterialApp(
          // App title (used by OS / browser tab). Set to CookedCodersAi per request.
          onGenerateTitle: (context) => 'CookedCodersAi',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: dark ? _buildDarkTheme() : _buildLightTheme(),
          home: const ChatScreen(),
        );
      },
    );
  }

  ThemeData _buildDarkTheme() {
    // Ocean kleuren - dark mode
    const oceanBlue = Color(0xFF006994);
    const deepOcean = Color(0xFF003554);
    const seafoam = Color(0xFF4ECDC4);
    const coral = Color(0xFFFF6B6B);

    return ThemeData(
      useMaterial3: true,

      // Basis kleuren
      colorScheme: ColorScheme.fromSeed(
        seedColor: oceanBlue,
        primary: oceanBlue,
        secondary: seafoam,
        surface: const Color(0xFF2A6577), // Donkere teal voor surfaces
        error: coral,
        brightness: Brightness.dark, // Dark theme
      ),

      // AppBar styling
      appBarTheme: const AppBarTheme(
        backgroundColor: oceanBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),

      // Card styling - donker
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF2A6577), // Donkere teal
      ),

      // Input field styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2A6577), // Donkere teal
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: oceanBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: seafoam, width: 2),
        ),
      ),

      // Button styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: oceanBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: deepOcean,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: deepOcean),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: seafoam,
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData _buildLightTheme() {
    // Ocean kleuren - light mode
    const oceanBlue = Color(0xFF006994);
    const lightBlue = Color(0xFF4A9FBF);
    const seafoam = Color(0xFF4ECDC4);
    const sand = Color(0xFFFFF4E6);
    const coral = Color(0xFFFF6B6B);

    return ThemeData(
      useMaterial3: true,

      // Basis kleuren
      colorScheme: ColorScheme.fromSeed(
        seedColor: oceanBlue,
        primary: oceanBlue,
        secondary: seafoam,
        surface: Colors.white,
        error: coral,
        brightness: Brightness.light,
      ),

      scaffoldBackgroundColor: sand,

      // AppBar styling
      appBarTheme: AppBarTheme(
        backgroundColor: oceanBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),

      // Card styling - licht
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),

      // Input field styling
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: seafoam, width: 2),
        ),
      ),

      // Button styling
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: oceanBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: oceanBlue,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: seafoam,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// View is now provided by features/chat/presentation/views/chat_screen.dart
