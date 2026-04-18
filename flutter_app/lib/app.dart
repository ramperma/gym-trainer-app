import 'package:flutter/material.dart';

import 'features/home/presentation/home_screen.dart';

class GymTrainerApp extends StatelessWidget {
  const GymTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2F6BFF);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    ).copyWith(
      surface: Colors.white,
      surfaceContainerHighest: const Color(0xFFE8EEF9),
      outlineVariant: const Color(0xFFD7DDE8),
    );

    return MaterialApp(
      title: 'Gym Trainer App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF3F6FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF10233F),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
