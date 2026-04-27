import 'package:flutter/material.dart';

import 'features/home/presentation/home_screen.dart';

class GymTrainerApp extends StatelessWidget {
  const GymTrainerApp({super.key});

  // Paleta principal
  static const _navy = Color(0xFF0F2747);
  static const _blue = Color(0xFF1363DF);
  static const _cyan = Color(0xFF20C5D9);
  static const _pearl = Color(0xFFF4F7FB);
  static const _cardBorder = Color(0xFFDDE6F0);

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _navy,
      brightness: Brightness.light,
    ).copyWith(
      primary: _navy,
      onPrimary: Colors.white,
      secondary: _cyan,
      onSecondary: const Color(0xFF042B32),
      tertiary: const Color(0xFFFFB347),
      surface: Colors.white,
      surfaceContainerHighest: const Color(0xFFE9F0F8),
      outlineVariant: _cardBorder,
      error: const Color(0xFFC62828),
    );

    // Tipografía profesional usando la fuente del sistema con pesos calibrados
    const headStyle = TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.18,
    );
    const bodyStyle = TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.45,
    );

    final textTheme = TextTheme(
      headlineLarge: headStyle.copyWith(fontSize: 32, color: _navy),
      headlineSmall: headStyle.copyWith(fontSize: 24, color: _navy),
      titleLarge: headStyle.copyWith(fontSize: 20, color: _navy),
      titleMedium: headStyle.copyWith(
          fontSize: 15, color: _navy, letterSpacing: 0),
      titleSmall: headStyle.copyWith(
          fontSize: 13, color: _navy, letterSpacing: 0),
      bodyLarge: bodyStyle.copyWith(fontSize: 16, color: const Color(0xFF2A3A52)),
      bodyMedium:
          bodyStyle.copyWith(fontSize: 14, color: const Color(0xFF4A5D75)),
      bodySmall: bodyStyle.copyWith(
          fontSize: 12,
          color: const Color(0xFF7A8FA6),
          fontWeight: FontWeight.w400),
      labelLarge: headStyle.copyWith(
          fontSize: 14, letterSpacing: 0.3, color: _navy),
      labelSmall: headStyle.copyWith(
          fontSize: 11,
          letterSpacing: 0.5,
          color: const Color(0xFF7A8FA6),
          fontWeight: FontWeight.w600),
    );

    return MaterialApp(
      title: 'Gym Trainer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: textTheme,
        scaffoldBackgroundColor: _pearl,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: _navy,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: textTheme.titleLarge,
          iconTheme: const IconThemeData(color: _navy),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: _cardBorder),
          ),
          margin: EdgeInsets.zero,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          indicatorColor: const Color(0xFFDEEBFB),
          elevation: 0,
          shadowColor: Colors.transparent,
          labelTextStyle: WidgetStatePropertyAll(
            textTheme.labelLarge?.copyWith(fontSize: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FBFF),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: textTheme.bodyMedium,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _blue, width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _navy,
            foregroundColor: Colors.white,
            textStyle: textTheme.labelLarge,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _navy,
            elevation: 0,
            textStyle: textTheme.labelLarge,
            side: const BorderSide(color: _cardBorder),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          side: const BorderSide(color: _cardBorder),
          selectedColor: const Color(0xFFD8E9FB),
          checkmarkColor: _blue,
          backgroundColor: const Color(0xFFF4F8FE),
          labelStyle: textTheme.bodyMedium,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        ),
        dividerTheme: const DividerThemeData(
          color: _cardBorder,
          thickness: 1,
          space: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _navy,
          contentTextStyle:
              textTheme.bodyMedium?.copyWith(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

